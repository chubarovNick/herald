require 'thunderer/version'
require 'thunderer/channel_parser'
require 'thunderer/faye_extension'
require 'thunderer/messages/async_message'
require 'thunderer/messages/base'
require 'thunderer/configuration'
require 'digest/sha1'
require 'ostruct'
require 'thunderer/engine' if defined? Rails

module Thunderer
  class Error < StandardError;
  end

  class << self
    attr_reader :config

    def reset_config
      @config = Thunderer::Configuration.new
    end

    def config
      @config ||= Thunderer::Configuration.new
    end

    def configure
      yield config if block_given?
    end

    def publish_to channel, data
      publish_message(message(channel, data))
    end

    def publish_message(message)
      raise Error, 'No server specified, ensure thunderer.yml was loaded properly.' unless config.server
      if config.async
        Thunderer::Messages::AsyncMessage.new(message)
      else
        Thunderer::Messages::Base.new(message)
      end.deliver
    end

    def message(channel, data)
      {channel: channel,
       data: {
           channel: channel,
           data: data},
       ext: {thunderer_secret_token: config.secret_token}}
    end

    def subscription(options = {})
      sub = {server: config.server, timestamp: (Time.now.to_f * 1000).round}.merge(options)
      sub[:signature] = Digest::SHA1.hexdigest([config.secret_token, sub[:channel], sub[:timestamp]].join)
      sub
    end

    def signature_expired?(timestamp)
      timestamp < ((Time.now.to_f - config.signature_expiration)*1000).round if config.signature_expiration
    end

    def faye_app(options = {})
      options = {mount: '/faye', timeout: 45, extensions: [FayeExtension.new]}.merge(options)
      Faye::RackAdapter.new(options)
    end
  end
end
