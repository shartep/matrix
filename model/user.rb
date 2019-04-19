User = Struct.new(:id, :name, :password, :admin, keyword_init: true) do
  NotAuthenticated = Class.new(StandardError)
  NotAuthorized    = Class.new(StandardError)

  def self.authorize!(name:, password:, **_)
    user = UserStorage::LIST.detect(&U.eq(:name, name))
    fail NotAuthenticated if user.blank?
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
end
