class MeetupGroupInfoClient
  def initialize(oauth2_token)
    @oauth2_token = oauth2_token
  end

  def groups(&block)
    return to_enum(:groups) unless block_given?

    @oauth2_token
      .get('/pro/brigade/groups')
      .parsed
      .each(&block)
  end

  def group_members(group_id, &block)
    return to_enum(:group_members, group_id) unless block_given?

    @oauth2_token
      .get('/pro/brigade/members', params: { chapters: group_id })
      .parsed
      .each(&block)
  end
end
