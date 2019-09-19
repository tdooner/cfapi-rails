Rails.application.config.github_client =
  Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])

stack = Faraday::RackBuilder.new do |builder|
  builder.use Faraday::HttpCache, serializer: Marshal, shared_cache: false
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack
