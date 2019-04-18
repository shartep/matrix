# frozen_string_literal: true

# Small foundation for all business operations classes.
#
# Typical definition of operation class will go like this (subject to change!):
#
# ```ruby
# class Model::DoSomething < Operations::Base
#   subject :subject_name
#   param :param1, default: 5, &:to_i
#   param(:param2) { |val| convert_somehow(val) }
#   param :param3 # no converter block, just passed as is
#
#   # this DSL will auto-define initialize looking like this:
#   #
#   #   def initialize(performer, subject_name:, param1: 5, param2: nil, param3: nil)
#   #
#   # ..and will run the converting blocks where they are defined
#
#   private
#
#   def allowed?
#     performer.admin? || performer.something_else? # if this will not be matched, ValidationError is raise
#   end
#
#   def validate!
#     invalid(param1: 'Explanation') if something
#   end
#
#   def _call
#     # do the real work
#   end
# end
#
# # usage of this class:
# Model::DoSomething.new(current_user, subject_name: something, param1_name: something, param2_name: something).call
# # or
# Model::DoSomething.new(current_user, params.to_unsafe_hash.symbolize_keys).call
# ```
#
# **Performer** of operation should be "current user" where it makes sense, or `Operations.system`
# (currently it is just a synonym for `nil` performer, but better use this synonym) if the operation
# is called by internal logic.
#
module Operations
  # Permissions error
  class NotAllowed < RuntimeError
    def initialize(user)
      @user = user
      super("Operation is not allowed for #{user.roles.join('/')}")
    end
  end

  def self.system
    nil # for now! in future, it could be special object
  end

  # Base for all the operations. See {Operations} module docs for usage.
  class Base
    extend Memoist

    attr_reader :performer

    def initialize(performer = Operations.system, **attrs)
      @performer = performer

      initialize_subject(attrs)
      initialize_attrs(attrs)
    end

    def subject
      fail 'No subject declared' unless self.class._subject
      instance_variable_get "@#{self.class._subject}"
    end

    def call
      check_rights!
      validate!
      _call
    rescue StandardError => e
      logger.error e.message, backtrace: e.backtrace
      raise
    end

    class_attribute :_subject, instance_accessor: false
    class_attribute :_params, instance_accessor: false
    # Rails 5.1 doen't have :default options for class_attribute method
    self._subject = nil
    self._params = {}

    class << self
      # DSL for spcify subject and params and automatically declare attr accessors and assign params to it

      def subject(name)
        self._subject = name.to_sym
        attr_reader name.to_sym
      end

      def param(name, **options, &converter)
        options[:converter] = converter if block_given?

        attr_reader name.to_sym
        # Replace _params because we need to invoke class attribute setter
        # If we are use .update we will have one params instance for all child classes.
        self._params = _params.merge(name.to_sym => options)
      end
    end

    private

    def _subject
      self.class._subject
    end

    def initialize_subject(attrs)
      return if _subject.blank?

      value = attrs.fetch(_subject) { fail ArgumentError, "#{_subject} is missing" }
      fail ArgumentError, "#{_subject} attrs is not present" if value.blank?
      instance_variable_set "@#{_subject}", value
    end

    def initialize_attrs(attrs)
      self.class._params.each do |name, options|
        unless attrs.key?(name)
          fail ArgumentError, "No #{name} attr" unless options.key?(:default)
        end
        value = attrs.fetch(name, options[:default])
        value = instance_exec(value, &options[:converter]) if options[:converter]
        instance_variable_set "@#{name}", value
      end
    end

    memoize def logger
      TaggedLogger.new(Logger.new(STDOUT), self.class.name)
    end

    def check_rights!
      fail Operations::NotAllowed, performer unless allowed?
    end

    def validate!; end

    def allowed?
      true
    end

    def system?
      performer.nil?
    end

    def _call
      fail NotImplementedError
    end

    def invalid(**errors)
      fail Operations::ValidationError, errors
    end
  end
end
