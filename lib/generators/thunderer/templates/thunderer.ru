# Run with: rackup thunderer.ru -s thin -E production
require 'bundler/setup'
require 'yaml'
require 'faye'
require 'thunderer'

Faye::WebSocket.load_adapter('thin')

Thunderer.load_config(File.expand_path('../config/thunderer.yml', __FILE__), ENV['RAILS_ENV'] || 'development')
run Thunderer.faye_app