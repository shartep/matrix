# frozen_string_literal: true

RSpec.describe TaggedLogger do
  let(:out) { StringIO.new }
  let!(:logger) { Logger.new(out) }
  let!(:tagged1) { described_class.new(logger, 'tag1') }
  let!(:tagged2) { described_class.new(tagged1, 'tag2') }

  it 'adds tags' do
    expect { logger.info 'foo'  }.to change(out, :string).to match(/: foo\n\z/)
    expect { tagged1.info 'foo' }.to change(out, :string).to match(/: \[tag1\] foo\n\z/)
    expect { tagged2.info 'foo' }.to change(out, :string).to match(/: \[tag1\] \[tag2\] foo\n\z/)
  end

  describe 'extra data formatting' do
    subject { tagged1.method(:info) }

    its_call('Test', response: {foo: 'bar'}) {
      is_expected.to change(out, :string).to end_with(%{: [tag1] Test (response: {:foo=>"bar"})\n})
    }

    exception = KeyError.new('Message').tap { |e| e.set_backtrace(%w[test.rb:1 foo.rb:2]) }
    its_call('Test', exception, response: {foo: 'bar'}) {
      is_expected.to change(out, :string).to end_with(
                                               %{: [tag1] Test (response: {:foo=>"bar"}). Exception: Message (KeyError)\n} +
                                                 "\ttest.rb:1\n\tfoo.rb:2\n"
                                             )
    }
  end
end
