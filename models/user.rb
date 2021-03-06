# frozen_string_literal: true

# this class represent User, in case this app will be integrated to rails app, it can be ActiveRecord,
# but now I used Struct as base class it is enough for basic functionality
User = Struct.new(:id, :name, :password, :admin, keyword_init: true) do
  NotAuthenticated = Class.new(StandardError)
  NotAuthorized    = Class.new(StandardError)

  def self.authorize!(name:, password: nil, **_)
    puts "USER: #{UserStorage::LIST}"
    user = UserStorage::LIST.detect(&U.eq(:name, name))
    if user.blank?
      fail NotAuthenticated
    end
    fail NotAuthorized if user.admin? && user.password != password
    user
  end

  def admin?
    admin
  end

  def to_s
    "name: #{name}, admin: #{admin}"
  end
end

class UserStorage
  LIST = JSON.parse(ENV['USERS'], symbolize_names: true).map { |user_attr| User.new(user_attr) }

  puts "USER StoRAGE: #{LIST}"
end
