# # frozen_string_literal: true
#
# require 'logger'
# require 'forwardable'
#
# # A bit better logger! Usage:
# #
# # ```ruby
# # logger = TaggedLogger.new(Rails.logger, 'mytag')
# # logger.info 'foo'
# # # outputs to log: [mytag] foo
# # logger.info 'foo', exception, bar: "baz"
# # # outputs: [mytag] foo (bar: "baz"). Exception: Some message (SomeClass)\nbacktrace
# # ```
# class TaggedLogger
#   extend Forwardable
#
#   def_delegators :@internal, :add, :log,
#                  :formatter, :formatter=
#
#   def initialize(logger, tag)
#     @internal = logger.dup
#     original = @internal.formatter || Logger::Formatter.new
#     @internal.formatter = proc { |severity, datetime, progname, msg|
#       original.call(severity, datetime, progname, "[#{tag}] #{msg}")
#     }
#   end
#
#   def initialize_dup(other)
#     @internal = other.internal.dup
#   end
#
#   %i[info error warn fatal debug unknown].each do |meth|
#     define_method(meth) do |msg, exception = nil, **payload|
#       @internal.send meth, "#{msg}#{render_payload(payload)}#{render_exception(exception)}"
#     end
#   end
#
#   protected
#
#   attr_reader :internal
#
#   private
#
#   def render_payload(payload)
#     return if payload.empty?
#     payload.map(&'%s: %p'.method(:%)).join(', ').then(&' (%s)'.method(:%))
#   end
#
#   def render_exception(exception)
#     return unless exception
#     bt = exception.backtrace&.map(&"\t%s".method(:%))&.join("\n")
#     ". Exception: #{exception.message} (#{exception.class})\n#{bt}"
#   end
# end
puts 'TAGGED LOGGR'
