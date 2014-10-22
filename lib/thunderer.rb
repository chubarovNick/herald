require 'thunderer/version'
require 'thunderer/parser'
require 'thunderer/messanger'
require 'thunderer/faye_extension'
require 'digest/sha1'
require 'yaml'
require 'thunderer/engine' if defined? Rails

module Thunderer
  class Error < StandardError; end

  class << self
    attr_reader :config
    attr_reader :messanger

    def reset_config
     @config = {}
    end

    def load_config filename, environment
      reset_config
      config_yaml = YAML.load_file(filename)[environment]
      raise ArgumentError, "The #{environment} environment dose not exist" unless config_yaml
      config_yaml.each { |k,v| config[k.to_sym] = v }
      Thunderer::Messanger.configure( config[:local_server_url] || config[:server])
      @messanger = Thunderer::Messanger

    end

    def publish_to channel, data
      publish_message(message(channel, data))
    end

    def publish_message(message)
      raise Error, 'No server specified, ensure thunderer.yml was loaded properly.' unless config[:server]
      url = URI.parse(config[:server])
      messanger.post(message)
    end

    def message(channel, data)
      {:channel => channel,
       :data => {
         :channel => channel,
         :data => data},
       :ext => {:thunderer_secret_token => config[:secret_token]}}
    end

    def subscription(options = {})
      sub = {:server => config[:server], :timestamp => (Time.now.to_f * 1000).round}.merge(options)
      sub[:signature] = Digest::SHA1.hexdigest([config[:secret_token], sub[:channel], sub[:timestamp]].join)
      sub
    end

    def signature_expired?(timestamp)
      timestamp < ((Time.now.to_f - config[:signature_expiration])*1000).round if config[:signature_expiration]
    end

    def faye_app(options = {})
      options = {mount: '/faye', timeout: 45, extensions: [FayeExtension.new] }.merge(options)
      Faye::RackAdapter.new(options)
    end
  end
end
