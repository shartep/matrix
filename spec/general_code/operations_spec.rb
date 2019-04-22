# frozen_string_literal: true

RSpec.describe Operations::Base do
  let(:user) { instance_double('User') }

  describe '#performer' do
    subject(:performer) { operation.performer }

    let(:operation) { described_class.new(user) }

    it { is_expected.to eq user }

    context 'when doen\'t pass as param' do
      let(:operation) { described_class.new }

      before do
        allow(Operations).to receive(:system).and_return(user)
      end

      it { is_expected.to eq user }
    end
  end

  describe '.subject' do
    class SampleWithSubject < Operations::Base; subject :user; end

    subject { SampleWithSubject.new(user: user).subject }

    it { is_expected.to eq user }

    context 'when absent subject param' do
      subject { SampleWithSubject.new.subject }

      its_block { is_expected.to raise_error(ArgumentError, 'user is missing') }
    end

    context 'when subject param nil' do
      let(:user) { nil }

      its_block { is_expected.to raise_error(ArgumentError, 'user attrs is not present') }
    end
  end

  describe '.param' do
    class SampleWithParam < Operations::Base; param :price; end

    subject { SampleWithParam.new(price: price).price }

    let(:price) { 10 }

    it { is_expected.to eq price }

    context 'when absent param' do
      subject { SampleWithParam.new.price }

      its_block { is_expected.to raise_error(ArgumentError, 'No price attr') }
    end

    context 'with default' do
      class SampleWithParamWithDefault < Operations::Base; param :price, default: 5; end

      subject { SampleWithParamWithDefault.new(price: price).price }

      let(:price) { 10 }

      it { is_expected.to eq price }

      context 'when absent param' do
        subject { SampleWithParamWithDefault.new.price }

        it { is_expected.to eq 5 }
      end
    end
  end

  describe '#call' do
    class EmptyOp < Operations::Base; def _call; end; end

    subject(:call) { operation.call }

    let(:operation) { EmptyOp.new }

    it 'checks rights' do
      expect(operation).to receive(:allowed?).and_call_original
      call
    end

    it 'validates' do
      expect(operation).to receive(:validate!).and_call_original
      call
    end

    it 'invokes call implementation' do
      expect(operation).to receive(:_call).and_call_original
      call
    end
  end
end
