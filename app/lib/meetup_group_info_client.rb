class MeetupGroupInfoClient
  def initialize(oauth2_token)
    @oauth2_token = oauth2_token
  end

  def groups(&block)
    return to_enum(:groups) unless block_given?

    ratelimited_request('/pro/brigade/groups')
      .each(&block)
  end

  def group_members(group_id, &block)
    return to_enum(:group_members, group_id) unless block_given?

    ratelimited_request('/pro/brigade/members', params: { chapters: group_id })
      .each(&block)
  end

  def group_events(group_urlname, &block)
    return to_enum(:group_events, group_urlname) unless block_given?

    ratelimited_request(
      format('/%<urlname>s/events', urlname: group_urlname),
      params: { scroll: 'next_upcoming', desc: true }
    ).each(&block)
  end

  private

  def ratelimited_request(url, params: {})
    response = @oauth2_token.get(url, params: params)

    # If less than 10 Meetup requests remain within the rate limit, sleep for a
    # period of time sufficient to let the ratelimit to reset.
    if (remaining = response.headers['x-ratelimit-remaining']) &&
       (reset_in = response.headers['x-ratelimit-reset']) &&
       remaining.to_i < 10
      time_to_delay = (reset_in.to_f / remaining.to_f).ceil(2)
      Rails.logger.info "Delaying #{time_to_delay} sec for Meetup rate limit. " \
        "(Remaining: #{remaining} | Reset: #{reset_in})."
      Kernel.sleep time_to_delay
    end

    response.parsed
  end
end
