# config/initializers/sidekiq.rb


redis_url = "redis://redis:6379/10"

Sidekiq.configure_server do |config|
  config.redis = {
      url:       redis_url,
      namespace: 'gdzqueue'
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
      url:       redis_url,
      namespace: 'gdzqueue'
  }
end
