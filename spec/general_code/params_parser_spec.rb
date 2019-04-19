# frozen_string_literal: true

RSpec.describe ParamsParser do
  describe '#current_user' do
    subject { described_class.current_user }

    it 'returns regular user' do
      ARGV = ['-u', 'trinity']
      expect(subject.admin?).to be_falsey
    end

    it 'returns admin user' do
      ARGV = ['-u', 'neo', '-p', 'knok_knok']
      expect(subject.admin?).to be_truthy
    end

    it 'raise exception when user name absent' do
      ARGV = ['-u']
      expect{subject}.to raise_error
    end
  end
end
