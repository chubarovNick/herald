module Thunderer
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def self.source_root
        File.dirname(__FILE__) + '/templates'
      end

      def copy_files
        template 'thunderer.yml', 'config/thunderer.yml'
        if ::Rails.version < '3.1'
          copy_file '../../../../app/assets/javascripts/thunderer.js', 'public/javascripts/thunderer.js'
          copy_file '../../../../app/assets/javascripts/thunderer_interceptor.js', 'public/javascripts/thunderer_interceptor.js'
          copy_file '../../../../app/assets/javascripts/thunderer_subscription_service.js', 'public/javascripts/thunderer_subscription_service.js'
        end
        copy_file 'thunderer.ru', 'thunderer.ru'
        copy_file 'thunderer.rb', 'app/config/initializers/thunderer.rb'
      end
    end
  end
end
