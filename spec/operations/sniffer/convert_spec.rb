# frozen_string_literal: true

RSpec.describe Sniffer::Convert do
  let(:user) { User.authorize!(name: 'neo', password: 'knok_knok') }
  let(:stream) do
    {
      routes: File.open('./spec/factories/sniffers/routes.csv', 'r'),
      sequences: File.open('./spec/factories/sniffers/sequences.csv', 'r'),
      node_times: File.open('./spec/factories/sniffers/node_times.csv', 'r'),
    }
  end

  describe '#call' do
    subject { described_class.new(user, stream).call }

    let(:result) do
      [
        {
          end_node: 'tau',
          end_time: '2030-12-31T13:00:07',
          start_node: 'lambda',
          start_time: '2030-12-31T13:00:06'
        },
        {
          end_node: 'psi',
          end_time: '2030-12-31T13:00:07',
          start_node: 'tau',
          start_time: '2030-12-31T13:00:06'
        },
        {
          end_node: 'omega',
          end_time: '2030-12-31T13:00:07',
          start_node: 'psi',
          start_time: '2030-12-31T13:00:06'
        },
        {
          end_node: 'psi',
          end_time: '2030-12-31T13:00:08',
          start_node: 'lambda',
          start_time: '2030-12-31T13:00:07'
        },
        {
          end_node: 'omega',
          end_time: '2030-12-31T13:00:08',
          start_node: 'psi',
          start_time: '2030-12-31T13:00:07'
        }
      ]
    end

    it 'returns correct result' do
      expect(subject).to eq(result)
    end
  end
end
