require 'spec_helper'
require 'protobuf/socket'

RSpec.describe Protobuf::Rpc::Connectors::Socket do
  subject { described_class.new({}) }

  it_behaves_like "a Protobuf Connector"
  specify{ subject.respond_to?(:post_init, true).should be true }

  context "#read_response" do
    let(:data) { "New data" }

    it "fills the buffer with data from the socket" do
      socket = StringIO.new("#{data.bytesize}-#{data}")
      subject.instance_variable_set(:@socket, socket)
      subject.instance_variable_set(:@stats, OpenStruct.new)
      expect(subject).to receive(:parse_response).and_return(true)

      subject.__send__(:read_response)
      expect(subject.instance_variable_get(:@response_data)).to eq(data)
    end
  end
end
