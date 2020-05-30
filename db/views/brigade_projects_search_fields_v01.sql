WITH contributors_by_repo AS (
  SELECT
    repo_details.object_id,
    string_agg(contributor.login, '|') as contributors
  FROM
    api_objects AS repo_details,
    jsonb_to_recordset(repo_details.body->'contributors') AS contributor(login text)
  WHERE type = 'ApiObject::GithubRepoDetails'
    AND repo_details.body->>'contributors' <> ''
  GROUP BY repo_details.object_id
),
languages_by_repo AS (
  SELECT
    object_id,
    string_agg(languages.key, '|') as languages
  FROM
    api_objects AS repo_details,
    jsonb_each_text(repo_details.body->'languages') AS languages
  WHERE type = 'ApiObject::GithubRepoDetails'
    AND repo_details.body->>'languages' <> ''
  GROUP BY object_id
),
topics_by_repo AS (
  SELECT
    object_id,
    string_agg(topics.name, '|') AS topics
  FROM
    api_objects,
    jsonb_to_recordset(api_objects.body->'topics') as topics (name text)
  WHERE type = 'ApiObject::GithubRepo'
    AND body->>'topics' <> ''
  GROUP BY object_id
)
SELECT
  brigade_projects.id as brigade_project_id,
  repo.body->>'name' as github_repo_name,
  repo.body->>'description' as github_repo_description,
  -- First <h1> in the README.md
  array_to_string(xpath('//xhtml:h1[1]/descendant-or-self::text()',
      (repo_details.body->>'readme_html')::text::xml,
      ARRAY[ARRAY['xhtml', 'http://www.w3.org/1999/xhtml']]
  ), '') as github_readme_title,
  -- First <p> in the README.md
  array_to_string(xpath('//xhtml:p[1]/descendant-or-self::text()',
      (repo_details.body->>'readme_html')::text::xml,
      ARRAY[ARRAY['xhtml', 'http://www.w3.org/1999/xhtml']]
  ), '') as github_readme_first_paragraph,
  contributors_by_repo.contributors as github_contributors,
  languages_by_repo.languages as github_languages,
  topics_by_repo.topics as github_topics,
  -- TODO: Add civic_json / publiccode_yml contents
  -- All README.md contents
  array_to_string(xpath('//xhtml:*/descendant-or-self::text()',
      (repo_details.body->>'readme_html')::text::xml,
      ARRAY[ARRAY['xhtml', 'http://www.w3.org/1999/xhtml']]
  ), '') as github_readme_text
FROM brigade_projects
INNER JOIN api_objects
  AS repo
  ON repo.object_id = brigade_projects.code_url
  AND repo.type = 'ApiObject::GithubRepo'
INNER JOIN api_objects
  AS repo_details
  ON repo_details.object_id = brigade_projects.code_url
  AND repo_details.type = 'ApiObject::GithubRepoDetails'
LEFT OUTER JOIN contributors_by_repo
  ON contributors_by_repo.object_id = repo.object_id
LEFT OUTER JOIN languages_by_repo
  ON languages_by_repo.object_id = repo.object_id
LEFT OUTER JOIN topics_by_repo
  ON topics_by_repo.object_id = repo.object_id
