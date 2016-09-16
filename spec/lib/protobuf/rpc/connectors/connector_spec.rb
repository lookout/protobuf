require 'spec_helper'

shared_examples "a Protobuf Connector" do
  subject{ described_class.new({}) }

  context "API" do
    # Check the API
    specify{ expect(subject.respond_to?(:send_request, true)).to be true }
    specify{ expect(subject.respond_to?(:post_init, true)).to be true }
    specify{ expect(subject.respond_to?(:close_connection, true)).to be true }
    specify{ expect(subject.respond_to?(:error?, true)).to be true }
  end
end
