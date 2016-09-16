require 'spec_helper'
require 'protobuf/http'
require 'faraday'


RSpec.shared_examples "a Protobuf Connector" do
  subject { described_class.new({}) }

  context "API" do
    # Check the API
    specify { expect(subject.respond_to?(:send_request, true)).to be true }
    specify { expect(subject.respond_to?(:post_init, true)).to be true }
    specify { expect(subject.respond_to?(:close_connection, true)).to be true }
    specify { expect(subject.respond_to?(:error?, true)).to be true }
  end
end

RSpec.describe ::Protobuf::Rpc::Connectors::Http do
  subject { described_class.new({}) }
  
  it_behaves_like "a Protobuf Connector"

  specify{ expect(described_class.include?(Protobuf::Rpc::Connectors::Common)).to be true }

  let(:client_double) do
    Faraday.new do |builder|
      builder.adapter :test do |stub|
        stub.post("/Foo/UserService/find") {[ 200, {}, "\n\n\n\x03foo\x12\x03bar" ]}
        stub.post("/Foo/UserService/foo1") {[ 404, {
          'x-protobuf-error' => "Foo::UserService#foo1 is not a defined RPC method.",
          'x-protobuf-error-reason' => Protobuf::Socketrpc::ErrorReason::METHOD_NOT_FOUND.to_s
        }, "" ]}
        stub.post("/Foo/UserService/foo2") {[ 500, {}, "" ]}
        stub.post("/base/Foo/UserService/foo3") {[ 200, {}, "\n\n\n\x03foo\x12\x03bar" ]}
      end
    end
  end

  describe "#send_data" do
    before do
      allow(subject).to receive_messages(:client => client_double)
      allow(subject).to receive_messages(:parse_response => nil)
    end

    it "handles RPC success correctly" do
      allow(subject).to receive_messages(:request_bytes => "\n\x10Foo::UserService\x12\x04find\x1A\r\n\vfoo@bar.com\"\rabcdefghijklm")
      subject.send(:setup_connection)
      subject.send(:send_data)
      expect(subject.instance_variable_get(:@response_data)).to eq "\n\f\n\n\n\x03foo\x12\x03bar"
    end

    it "handles RPC error correctly" do
      allow(subject).to receive_messages(:request_bytes => "\n\x10Foo::UserService\x12\x04foo1\x1A\r\n\vfoo@bar.com\"\rabcdefghijklm")
      subject.send(:setup_connection)
      subject.send(:send_data)
      expect(subject.instance_variable_get(:@response_data)).to eq "\n\x00\x122Foo::UserService#foo1 is not a defined RPC method. \x03"
    end

    it "handles server error correctly" do
      allow(subject).to receive_messages(:request_bytes => "\n\x10Foo::UserService\x12\x04foo2\x1A\r\n\vfoo@bar.com\"\rabcdefghijklm")
      subject.send(:setup_connection)
      subject.send(:send_data)
      expect(subject.instance_variable_get(:@response_data)).to eq "\n\x00\x12\x1DBad response from the server. \x07"
    end

    it "prepends base path option correctly" do
      allow(subject).to receive_messages(:options => { :base => "/base" })
      allow(subject).to receive_messages(:request_bytes => "\n\x10Foo::UserService\x12\x04foo3\x1A\r\n\vfoo@bar.com\"\rabcdefghijklm")
      subject.send(:setup_connection)
      subject.send(:send_data)
      expect(subject.instance_variable_get(:@response_data)).to eq "\n\f\n\n\n\x03foo\x12\x03bar"
    end
  end
end
