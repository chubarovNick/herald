require 'thunderer/view_helpers'
require 'thunderer/publish_changes'
require 'thunderer/controller_additions'
module Thunderer
  class Engine < ::Rails::Engine

    initializer 'thunderer.config' do
      path = Rails.root.join('config/thunderer.yml')
      Thunderer.load_config(path, Rails.env) if path.exist?
    end

    initializer :assets do |config|
      Rails.application.config.assets.paths << File.join(
          Gem.loaded_specs['faye'].full_gem_path, 'lib')
    end

    initializer 'thunderer.view_helpers' do
      ActionView::Base.send :include, ViewHelpers
    end

    # initializer 'thunderer.controller' do
    #   ActiveSupport.on_load(:action_controller) do
    #     include Thunderer::ControllerAdditions
    #   end
    # end
    #
    # initializer 'thunderer.active_record' do
    #   ActiveSupport.on_load(:active_record) do
    #     include Thunderer::PublishChanges
    #   end
    # end

  end
end
