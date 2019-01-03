module SolidusAffirm
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'solidus_affirm'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    config.autoload_paths += %W(#{config.root}/lib)

    config.after_initialize do
      versions_without_api_custom_source_templates = Gem::Requirement.new('< 2.6')
      if versions_without_api_custom_source_templates.satisfied_by?(SolidusSupport.solidus_gem_version)
        require_dependency 'solidus_affirm/backward_compatibility_hacks/api_template'
      end
    end

    initializer "spree.solidus_affirm.environment", before: :load_config_initializers do |_app|
      SolidusAffirm::Config = SolidusAffirm::Configuration.new
    end

    initializer "register_solidus_affirm_gateway", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << SolidusAffirm::Gateway
    end

    initializer 'spree.solidus_affirm.action_controller' do |_app|
      ActiveSupport.on_load :action_controller do |klass|
        next if klass.name == "ActionController::API"

        helper AffirmHelper
      end
    end

    if SolidusSupport.api_available?
      paths["app/views"] << "lib/views/api"
    end
  end
end
