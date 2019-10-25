class SalesforceBrigadeLeadersClient
  include Enumerable

  SOQL_QUERY = <<~SOQL.freeze
    SELECT
      Id,
      npe5__Contact__r.Id,
      npe5__Contact__r.Name,
      npe5__Contact__r.Email,
      npe5__Organization__r.Name
    FROM npe5__Affiliation__c
    WHERE Captain_Co_Captain__c = TRUE
      AND npe5__Status__c <> 'Former'
  SOQL

  def initialize(oauth2_token)
    @oauth2_token = oauth2_token
  end

  def each(&block)
    # TODO: Handle pagination here
    @oauth2_token
      .get('/services/data/v47.0/query', params: { q: SOQL_QUERY })
      .parsed['records']
      .each(&block)
  end
end
