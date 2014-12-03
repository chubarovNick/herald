module Thunderer
  module Messages
    class Base

      def initialize(message)
        @message = message
      end

      def deliver
        form = build_form
        form.set_form_data(message: @message.to_json)
        protocol.start { |h| h.request(form) }
      end

      private

      def build_form
        Net::HTTP::Post.new(uri.path.empty? ? '/' : uri.path)
      end

      def protocol
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = use_ssl?
        if use_ssl?
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http
      end

      def uri
        @uri ||= URI.parse(Thunderer.config.local_server_url || Thunderer.config.server)
      end

      def use_ssl?
        uri.scheme == 'https'
      end
    end

  end
end