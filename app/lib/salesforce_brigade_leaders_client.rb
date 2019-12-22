class SalesforceBrigadeLeadersClient
  include Enumerable

  SOQL_QUERY = <<~SOQL.freeze
    SELECT
      Id,
      npe5__Contact__r.Id,
      npe5__Contact__r.Name,
      npe5__Contact__r.Email,
      npe5__Contact__r.Brigade_Email__c,
      npe5__Contact__r.npe01__AlternateEmail__c,
      npe5__Contact__r.npe01__HomeEmail__c,
      npe5__Contact__r.npe01__PreferredEmail__c,
      npe5__Contact__r.npe01__WorkEmail__c,
      npe5__Organization__r.Name
    FROM npe5__Affiliation__c
    WHERE Captain_Co_Captain__c = TRUE
      AND npe5__Status__c <> 'Former'
  SOQL

  def initialize(oauth2_token)
    @oauth2_token = oauth2_token
  end

  def each(&block)
    next_url = '/services/data/v47.0/query'
    next_params = { q: SOQL_QUERY }

    loop do
      response = @oauth2_token.get(next_url, params: next_params).parsed

      response['records']
        .each(&block)

      break if response['done']

      next_url = response['nextRecordsUrl']
      next_params = {}
    end
  end
end
