class BrigadeInformationClient
  JSON_URL = 'https://raw.githubusercontent.com/codeforamerica/brigade-information/master/organizations.json'.freeze
  SUPPORTED_KEYS = %i[
    city projects_list_url events_url latitude longitude name rss
    social_profiles tags type website
  ].freeze

  def initialize(url = JSON_URL)
    @url = URI(url)
  end

  def each(&block)
    return to_enum(&:each) unless block_given?

    JSON
      .parse(Net::HTTP.get(@url))
      .map(&:symbolize_keys)
      .map { |b| b.slice(*SUPPORTED_KEYS).transform_values(&:presence) }
      .each(&block)
  end
end
