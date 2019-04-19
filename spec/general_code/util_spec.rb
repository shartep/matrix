# frozen_string_literal: true

RSpec.describe Util do
  describe '#eq' do
    subject { described_class.eq(method, val).call(object) }

    let(:method) { :name }
    let(:val)    { 'neo' }
    let(:object) { Struct.new(:name, keyword_init: true).new(name: val) }

    it 'returns correct proc' do
      is_expected.to be_truthy
    end
  end
end
