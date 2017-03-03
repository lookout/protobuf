require 'spec_helper'

shared_examples "a Protobuf Connector" do
  subject { described_class.new({}) }

  context "API" do
    # Check the API
    specify { subject.respond_to?(:send_request, true).should be true }
    specify { subject.respond_to?(:close_connection, true).should be true }
    specify { subject.respond_to?(:error?, true).should be true }
  end
end
