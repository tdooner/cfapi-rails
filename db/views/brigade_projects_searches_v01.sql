SELECT
  brigade_project_id,
  setweight(to_tsvector(coalesce(github_repo_name, '')), 'A') ||
  setweight(to_tsvector(coalesce(github_repo_description, '')), 'A') ||
  setweight(to_tsvector(coalesce(github_readme_title, '')), 'B') ||
  setweight(to_tsvector(coalesce(github_readme_first_paragraph, '')), 'B') ||
  setweight(to_tsvector(coalesce(github_contributors, '')), 'A') ||
  setweight(to_tsvector(coalesce(github_languages, '')), 'A') ||
  setweight(to_tsvector(coalesce(github_topics, '')), 'A') ||
  setweight(to_tsvector(coalesce(github_readme_text, '')), 'C')
FROM brigade_projects_search_fields
