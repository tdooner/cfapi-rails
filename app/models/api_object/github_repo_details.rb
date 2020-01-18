class ApiObject
  class GithubRepoDetails < ApiObject
    REFETCH_EVERY = 2.days

    def update_if_necessary(client)
      current_version = body&.fetch('version', '1')
      case current_version
      when nil
        # load everything
        update_attributes(body: transform_body(fetch_body(client)))
      when '1'
        # just re-transform the existing body
        update_attributes(body: transform_body(body))
      when '2'
        return if updated_at > REFETCH_EVERY.ago
        update_attributes(body: transform_body(fetch_body(client)))
      end
    end

    def fetch_body(client)
      repo = ApiObject::GithubRepo.find_by(object_id: object_id)
      return unless repo && repo.body.present? && repo.body['owner'].present?

      repo_name = format('%<owner>s/%<repo>s', owner: repo.body['owner']['login'], repo: repo.body['name'])

      GithubRepoDetailFetcher.new(client, repo_name).fetch_everything
    end

    def transform_body(body)
      return unless body.present?

      body.dup.tap do |transformed_body|
        transformed_body['readme_html'] = render_readme
        transformed_body['version'] = '2'
      end
    end

    def render_readme
      return unless body.present? && body['readme'].present?

      markdown = Base64.decode64(Hash[body['readme']]['content'])
      Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(markdown)
    end
  end
end
