require 'spec_helper'
require 'protobuf/rpc/servers/http/server'

# A simple service:
require 'protobuf/message'
require 'protobuf/rpc/service'

module ReverseModule
  class ReverseRequest < ::Protobuf::Message
    required :string, :input, 1
  end
  class ReverseResponse < ::Protobuf::Message
    required :string, :reversed, 1
    optional :string, :some_header, 2
  end
  class ReverseService < ::Protobuf::Rpc::Service
    rpc :reverse, ReverseRequest, ReverseResponse
    def reverse
      respond_with :reversed => request.input.reverse,
                   :some_reversed_header => if env.parent_env.key?('X-SOME-HEADER')
                                              env.parent_env['X-SOME-HEADER'].reverse
                                            end
    end
  end
end

describe Protobuf::Rpc::Http::Server do
  subject { described_class.new }

  describe '#call' do
    client = nil
    before do
      client = Rack::MockRequest.new(subject)
    end

    it 'should return the correct response for ReverseModule::ReverseService.reverse' do
      response = client.post "/ReverseModule%3A%3AReverseService/reverse", :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode
      expect(response.status).to eq 200
      expect(response.headers['content-type']).to eq "application/x-protobuf"
      expect(response.headers['x-protobuf-error']).to be_nil
      expect(response.headers['x-protobuf-error-reason']).to be_nil
      expect(response.body).to eq ReverseModule::ReverseResponse.new(:reversed => "hello world".reverse).encode
    end

    it 'should return the correct response for ReverseModule::ReverseService.reverse when some header is passed' do
      response = client.post "/ReverseModule%3A%3AReverseService/reverse",
                             :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode,
                             "X-SOME-HEADER" => "yes i am"
      expect(response.status).to eq 200
      expect(response.headers['content-type']).to eq "application/x-protobuf"
      expect(response.headers['x-protobuf-error']).to be_nil
      expect(response.headers['x-protobuf-error-reason']).to be_nil
      expect(response.body).to eq ReverseModule::ReverseResponse.new(
        :reversed             => "hello world".reverse,
        :some_reversed_header => "yes i am".reverse
      ).encode
    end

    it 'should return METHOD_NOT_FOUND for ReverseModule::ReverseService.bobloblaw' do
      response = client.post "/ReverseModule%3A%3AReverseService/bobloblaw", :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode
      expect(response.status).to eq 404
      expect(response.headers['content-type']).to eq "application/x-protobuf"
      expect(response.headers['x-protobuf-error']).to eq "ReverseModule::ReverseService#bobloblaw is not a defined RPC method."
      expect(response.headers['x-protobuf-error-reason']).to eq Protobuf::Socketrpc::ErrorReason::METHOD_NOT_FOUND.to_s
      expect(response.body).to eq ""
    end

    it 'should return SERVICE_NOT_FOUND for Bar::ReverseService.reverse' do
      response = client.post "/Bar%3A%3AReverseService/reverse", :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode
      expect(response.status).to eq 404
      expect(response.headers['content-type']).to eq "application/x-protobuf"
      expect(response.headers['x-protobuf-error']).to eq "Service class Bar::ReverseService is not defined."
      expect(response.headers['x-protobuf-error-reason']).to eq Protobuf::Socketrpc::ErrorReason::SERVICE_NOT_FOUND.to_s
      expect(response.body).to eq ""
    end

    it 'should not return RPC_FAILED for missing input' do
      response = client.post "/ReverseModule%3A%3AReverseService/reverse", :input => ""
      expect(response.status).to eq 200
      expect(response.headers['content-type']).to eq "application/x-protobuf"
      expect(response.headers['x-protobuf-error']).to be_nil
      expect(response.headers['x-protobuf-error-reason']).to be_nil
      expect(response.body).to eq ReverseModule::ReverseResponse.new(:reversed => "".reverse).encode
    end

    it 'should return RPC_ERROR for invalid input' do
      response = client.post "/ReverseModule%3A%3AReverseService/reverse", :input => "\\n\\x03foo"
      expect(response.status).to eq 400
      expect(response.headers['content-type']).to eq "application/x-protobuf"
      expect(response.headers['x-protobuf-error-reason']).to eq Protobuf::Socketrpc::ErrorReason::BAD_REQUEST_DATA.to_s
      expect(response.body).to eq ""
    end

    it 'should return INVALID_REQUEST_PROTO for invalid URL' do
      response = client.post "/foo", :input => ReverseModule::ReverseRequest.new(:input => "hello world").encode
      expect(response.status).to eq 400
      expect(response.headers['content-type']).to eq "application/x-protobuf"
      expect(response.headers['x-protobuf-error']).to eq "Expected path format /CLASS/METHOD"
      expect(response.headers['x-protobuf-error-reason']).to eq Protobuf::Socketrpc::ErrorReason::INVALID_REQUEST_PROTO.to_s
      expect(response.body).to eq ""
    end
  end

  describe '.running?' do
    it 'returns true if running' do
      subject.instance_variable_set(:@running, true)
      expect(subject.running?).to be true
    end

    it 'returns false if not running' do
      subject.instance_variable_set(:@running, false)
      expect(subject.running?).to be false
    end
  end

  describe '.stop' do
    it 'sets running to false' do
      # subject.instance_variable_set(:@workers, [])
      subject.stop
      expect(subject.instance_variable_get(:@running)).to be_falsey
    end
  end
end
