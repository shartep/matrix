# frozen_string_literal: true

# this class encapsulate different helpful utils
module Util
  # returns predicate method, which compare ojects specific attribute value with val,
  # useful for methods like :detect, :select, :find, etc.
  def self.eq(method, val)
    Proc.new do |object|
      object.public_send(method) == val
    end
  end
end

U = Util
