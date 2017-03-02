require 'date'
require 'time'
require 'protobuf/statsd'

module Protobuf
  module Rpc
    class Stat
      attr_accessor :mode, :start_time, :end_time, :request_size, :dispatcher
      attr_accessor :response_size, :client, :server, :service, :method_name

      MODES = [:SERVER, :CLIENT].freeze

      def initialize(mode = :SERVER)
        @mode = mode
        @request_size = 0
        @response_size = 0
        @success = false
        @failure_code = nil
        start
      end

      attr_writer :client

      def client
        @client || nil
      end

      def elapsed_time
        (start_time && end_time ? "#{(end_time - start_time).round(4)}s" : nil)
      end

      def method_name
        @method_name ||= @dispatcher.try(:service).try(:method_name)
      end

      def server=(peer)
        @server = { :port => peer[0], :ip => peer[1] }
      end

      def server
        @server ? "#{@server[:ip]}:#{@server[:port]}" : nil
      end

      def service
        @service ||= @dispatcher.try(:service).class.name
      end

      def sizes
        if stopped?
          "#{@request_size}B/#{@response_size}B"
        else
          "#{@request_size}B/-"
        end
      end

      def start
        @start_time ||= ::Time.now
      end

      def stop
        start unless @start_time
        @end_time ||= ::Time.now
        call_statsd_client
      end

      def success
        @success = true
      end

      def failure(code)
        @failure_code = code
      end

      def stopped?
        !end_time.nil?
      end

      def rpc
        service && method_name ? "#{service}##{method_name}" : nil
      end

      def server?
        @mode == :SERVER
      end

      def client?
        @mode == :CLIENT
      end

      def to_s
        [
          server? ? "[SRV]" : "[CLT]",
          server? ? client : server,
          trace_id,
          rpc,
          sizes,
          elapsed_time,
          @end_time.try(:iso8601),
        ].compact.join(' - ')
      end

      def trace_id
        ::Thread.current.object_id.to_s(16)
      end

      # Return base path for StatsD metrics
      def statsd_base_path
        "rpc-client.#{service}.#{method_name}".gsub('::', '.').downcase
      end

      # If a StatsD Client has been configured, send stats to it upon
      # completion.
      def call_statsd_client
        path = statsd_base_path
        statsd_client = Protobuf::Statsd.client
        return unless statsd_client

        if @success
          statsd_client.increment("#{path}.success")
        elsif @failure_code
          statsd_client.increment("#{path}.failure.total")
          statsd_client.increment("#{path}.failure.#{@failure_code}")
        end

        if start_time && end_time
          duration = end_time - start_time
          statsd_client.timing("#{path}.time", duration)
        end
      end
      private :call_statsd_client
    end
  end
end
