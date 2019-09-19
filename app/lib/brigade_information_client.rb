class BrigadeInformationClient
  JSON_URL = 'https://raw.githubusercontent.com/codeforamerica/brigade-information/master/organizations.json'.freeze

  def initialize(url = JSON_URL)
    @url = URI(url)
  end

  def each(&block)
    return to_enum(&:each) unless block_given?

    JSON
      .parse(Net::HTTP.get(@url))
      .map(&:symbolize_keys)
      .map(&:with_indifferent_access)
      .each(&block)
  end
end
