class GithubRepoDetailFetcher
  def initialize(client, repo_name)
    @client = client
    @repo_name = repo_name
  end

  def fetch_everything
    {
      'readme' => fetch_readme,
      'languages' => fetch_languages,
      'civic_json' => fetch_civic_json,
      'contributors' => fetch_contributors,
      'publiccode_yaml' => fetch_publiccode_yaml,
    }
  end

  def fetch_readme
    @client.readme(@repo_name)
  rescue Octokit::NotFound
    nil
  end

  def fetch_languages
    @client.languages(@repo_name)
  end

  def fetch_contributors
    @client.contributors(@repo_name)
  end

  def fetch_civic_json
    @client.contents(@repo_name, path: 'civic.json')
  rescue Octokit::NotFound
    nil
  end

  def fetch_publiccode_yaml
    @client.contents(@repo_name, path: 'publiccode.yml')
  rescue Octokit::NotFound
    nil
  end
end
