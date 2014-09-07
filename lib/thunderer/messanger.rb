module Thunderer
  module Messanger
    class ConfigurationError < StandardError; end

    class << self
      attr_reader :config

      def reset_config
        @config = {}
      end

      def configure url
        reset_config
        uri = URI.parse(url)
        @config['uri'] = uri
        @config['use_ssl'] = uri.scheme == 'https'
      end

      def post( message )
        raise ConfigurationError if not_configured?

        form = build_form
        form.set_form_data(:message => message.to_json)
        protocol.start { |h| h.request(form) }
      end

      private

      def build_form
        uri = @config['uri']
        Net::HTTP::Post.new(uri.path.empty? ? '/' : uri.path)
      end

      def protocol
        uri = @config['uri']
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = @config['use_ssl']
        if @config['use_ssl']
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http
      end

      def not_configured?
        @config == {}
      end

    end
  end
end
