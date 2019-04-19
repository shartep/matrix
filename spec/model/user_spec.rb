# frozen_string_literal: true

RSpec.describe User do
  let(:user) { described_class.new(name: 'neo', admin: true) }

  describe '#authorize!' do
    subject { described_class.authorize!(name: name, password: password, admin: admin) }
    let(:name)     { nil }
    let(:password) { nil }
    let(:admin)    { nil }

    context 'admin user' do
      let(:name)     { 'neo' }
      let(:password) { 'knok_knok' }
      let(:admin)    { true }

      it 'return correct user instance' do
        expect(subject.name).to eq(name)
      end
    end

    context 'regular user' do
      let(:name)     { 'trinity' }

      it 'return correct user instance' do
        expect(subject.name).to eq(name)
      end
    end

    context 'wrong name' do
      let(:name)     { 'donald' }

      it 'raise NotAuthenticated' do
        expect { subject }.to raise_error(NotAuthenticated)
      end
    end

    context 'wrong password' do
      let(:name)     { 'neo' }
      let(:password) { 'knok' }
      let(:admin)    { true }

      it 'raise NotAuthorized' do
        expect { subject }.to raise_error(NotAuthorized)
      end
    end
  end

  describe '#admin?' do
    subject { user.admin? }

    it 'return true when user is admin' do
      is_expected.to be_truthy
    end
  end

  describe '#to_s' do
    subject { user.to_s }

    it 'return correct string' do
      is_expected.to eq('name: neo, admin: true')
    end
  end
end
