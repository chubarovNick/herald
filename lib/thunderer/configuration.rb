require 'yaml'
module Thunderer
  class Configuration
    attr_writer :environment
    attr_accessor :queue_adapter
    attr_accessor :server
    attr_accessor :local_server_url
    attr_accessor :async
    attr_accessor :secret_token
    attr_accessor :signature_expiration

    def initialize
      @config_file_path = ''
      @queue_adapter = nil
      @server = nil
      @secret_token = nil
      @signature_expiration = 3600
      @local_server_url = nil
      @async = false
      @environment = nil
    end

    def config_file_path=(value)
      load_configuration(value, @environment)
    end

    private

    def load_configuration(path, environment)
      config_yaml = YAML.load_file(path)[environment]
      raise ArgumentError, "The #{environment} environment dose not exist" unless config_yaml
      config_yaml.each do |k, v|
        self.public_send("#{k}=",v)
      end
    end

  end
end