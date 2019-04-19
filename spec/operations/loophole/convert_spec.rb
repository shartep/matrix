# frozen_string_literal: true

RSpec.describe Loophole::Convert do
  let(:user) { User.authorize!(name: 'neo', password: 'knok_knok') }
  let(:stream) do
    {
      routes: File.open('./spec/factories/loopholes/routes.json', 'r'),
      node_pairs: File.open('./spec/factories/loopholes/node_pairs.json', 'r'),
    }
  end

  describe '#call' do
    subject { described_class.new(user, stream).call }

    let(:result) do
      [
        {
          end_node: 'theta',
          end_time: '2030-12-31T13:00:05',
          start_node: 'gamma',
          start_time: '2030-12-31T13:00:04'
        },
        {
          end_node: 'lambda',
          end_time: '2030-12-31T13:00:06',
          start_node: 'theta',
          start_time: '2030-12-31T13:00:05'
        },
        {
          end_node: 'theta',
          end_time: '2030-12-31T13:00:06',
          start_node: 'beta',
          start_time: '2030-12-31T13:00:05'
        },
        {
          end_node: 'lambda',
          end_time: '2030-12-31T13:00:07',
          start_node: 'theta',
          start_time: '2030-12-31T13:00:06'
        }
      ]
    end

    it 'returns correct result' do
      expect(subject).to eq(result)
    end
  end
end
