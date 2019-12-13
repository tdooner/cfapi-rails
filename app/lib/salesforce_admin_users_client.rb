class SalesforceAdminUsersClient
  include Enumerable

  SOQL_QUERY = <<~SOQL.freeze
    SELECT Department, Email
    FROM User
    WHERE IsActive = TRUE
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
