require 'spec_helper'
require 'protobuf/rpc/servers/http/server'

# require 'rack/mock'
require 'rack/test'

# A simple service:
require 'protobuf/message'
require 'protobuf/rpc/service'

module ReverseModule
  class ReverseRequest < ::Protobuf::Message
    required :string, :input, 1
  end
  class ReverseResponse < ::Protobuf::Message
    required :string, :reversed, 1
  end
  class ReverseService < ::Protobuf::Rpc::Service
    rpc :reverse, ReverseRequest, ReverseResponse
    rpc :test_fail, ReverseRequest, ReverseResponse

    def reverse
      respond_with :reversed => request.input.reverse
    end

    def test_fail
      raise 'this fails'
    end
  end
end

describe Protobuf::Rpc::Http::Server do
  subject { described_class.new }

  before do
    load 'protobuf/http.rb'
  end

  describe '#call' do
    client = nil
    before do
      client = Rack::MockRequest.new(subject)
    end

    it 'should return the correct response for ReverseModule::ReverseService.reverse' do
      response = client.post "/ReverseModule%3A%3AReverseService/reverse", :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode()
      response.status.should eq 200
      response.headers['content-type'].should eq "application/x-protobuf"
      response.headers['x-protobuf-error'].should be_nil
      response.headers['x-protobuf-error-reason'].should be_nil
      response.body.should eq ReverseModule::ReverseResponse.new(:reversed => "hello world".reverse).encode()
    end

    it 'should return METHOD_NOT_FOUND for ReverseModule::ReverseService.bobloblaw' do
      response = client.post "/ReverseModule%3A%3AReverseService/bobloblaw", :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode()
      response.status.should eq 404
      response.headers['content-type'].should eq "application/x-protobuf"
      response.headers['x-protobuf-error'].should eq "ReverseModule::ReverseService#bobloblaw is not a defined RPC method."
      response.headers['x-protobuf-error-reason'].should eq Protobuf::Socketrpc::ErrorReason::METHOD_NOT_FOUND.to_s
      response.body.should eq ""
    end

    it 'should return SERVICE_NOT_FOUND for Bar::ReverseService.reverse' do
      response = client.post "/Bar%3A%3AReverseService/reverse", :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode()
      response.status.should eq 404
      response.headers['content-type'].should eq "application/x-protobuf"
      response.headers['x-protobuf-error'].should eq "Service class Bar::ReverseService is not defined."
      response.headers['x-protobuf-error-reason'].should eq Protobuf::Socketrpc::ErrorReason::SERVICE_NOT_FOUND.to_s
      response.body.should eq ""
    end

    it 'should return RPC_FAILED on exception' do
      response = client.post "/ReverseModule%3A%3AReverseService/test_fail", :input => ""
      response.status.should eq 500
      response.headers['content-type'].should eq "application/x-protobuf"
      # response.headers['x-protobuf-error'].should eq "Service class Bar::ReverseService is not defined."
      response.headers['x-protobuf-error-reason'].should eq Protobuf::Socketrpc::ErrorReason::RPC_FAILED.to_s
      response.body.should eq ""
    end

    it 'should return INVALID_REQUEST_PROTO for invalid URL' do
      response = client.post "/foo/bar/baz", :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode()
      response.status.should eq 400
      response.headers['content-type'].should eq "application/x-protobuf"
      # response.headers['x-protobuf-error'].should eq "Service class Bar::ReverseService is not defined."
      response.headers['x-protobuf-error-reason'].should eq Protobuf::Socketrpc::ErrorReason::INVALID_REQUEST_PROTO.to_s
      response.body.should eq ""
    end
  end

  describe '.running?' do
    it 'returns true if running' do
      subject.instance_variable_set(:@running, true)
      subject.running?.should be(true)
    end

    it 'returns false if not running' do
      subject.instance_variable_set(:@running, false)
      subject.running?.should be(false)
    end
  end
end
