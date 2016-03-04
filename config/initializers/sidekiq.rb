# config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.redis = {
      url: 'redis://192.168.99.100:6379/10',
      namespace: 'gdzqueue'
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
      url: 'redis://192.168.99.100:6379/10',
      namespace: 'gdzqueue'
  }
end
