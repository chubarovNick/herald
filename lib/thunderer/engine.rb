require 'thunderer/view_helpers'
require 'thunderer/publish_changes'
require 'thunderer/controller_additions'
module Thunderer
  class Engine < ::Rails::Engine

    initializer :assets do |config|
      Rails.application.config.assets.paths << File.join(
          Gem.loaded_specs['faye'].full_gem_path, 'lib')
    end

    initializer 'thunderer.view_helpers' do
      ActionView::Base.send :include, ViewHelpers
    end

  end
end
