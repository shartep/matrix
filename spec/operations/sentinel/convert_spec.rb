# frozen_string_literal: true

RSpec.describe Sentinel::Convert do
  let(:user) { User.authorize!(name: 'neo', password: 'knok_knok') }
  let(:stream) do
    {
      routes: File.open('./spec/factories/sentinels/routes.csv', 'r'),
    }
  end

  describe '#call' do
    subject { described_class.new(user, stream).call }

    let(:result) do
      [
        {
          end_node: 'gamma',
          end_time: '2030-12-31T13:00:03',
          start_node: 'beta',
          start_time: '2030-12-31T13:00:02'
        },
        {
          end_node: 'gamma',
          end_time: '2030-12-31T13:00:04',
          start_node: 'beta',
          start_time: '2030-12-31T13:00:03'
        },
      ]
    end

    it 'returns correct result' do
      expect(subject).to eq(result)
    end
  end
end
