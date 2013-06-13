module Oauth
  def self.included(klass)
    klass.class_eval do
      use OmniAuth::Builder do
        config = YAML::load_file("config/oauth.yml")[ENV['RACK_ENV']]
        provider :vkontakte, config[:vkontakte][:app_id], config[:vkontakte][:app_secret], scope: config[:vkontakte][:app_permissions], display: 'page', provider_ignores_state: true
      end
    end
  end
end
