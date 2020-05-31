# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_30_235027) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_objects", force: :cascade do |t|
    t.string "type"
    t.string "object_id"
    t.jsonb "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "brigade_leaders", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.bigint "brigade_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brigade_id"], name: "index_brigade_leaders_on_brigade_id"
  end

  create_table "brigade_projects", force: :cascade do |t|
    t.string "name"
    t.string "code_url"
    t.string "link_url"
    t.bigint "brigade_id"
    t.datetime "last_modified_at"
    t.datetime "last_pushed_at"
    t.index ["brigade_id"], name: "index_brigade_projects_on_brigade_id"
  end

  create_table "brigades", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_url"
    t.string "meetup_url"
    t.string "slug"
    t.index ["slug"], name: "index_brigades_on_slug", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "metric_snapshots", force: :cascade do |t|
    t.string "metric_name"
    t.decimal "metric_value"
    t.datetime "created_at"
    t.string "related_object_type"
    t.bigint "related_object_id"
    t.datetime "sent_to_mixpanel_at"
    t.index ["metric_name", "created_at"], name: "index_metric_snapshots_on_metric_name_and_created_at"
    t.index ["related_object_type", "related_object_id"], name: "idx_metric_snapshots_related_object"
  end

  create_table "oauth_identities", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "user_id"
    t.json "token_hash", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "service_user_id", null: false
    t.string "service_username", null: false
    t.index ["type", "user_id"], name: "index_oauth_identities_on_type_and_user_id", unique: true
    t.index ["user_id"], name: "index_oauth_identities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_salesforce_account"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end


  create_view "brigade_projects_search_fields", materialized: true, sql_definition: <<-SQL
      WITH contributors_by_repo AS (
           SELECT repo_details_1.object_id,
              string_agg(contributor.login, '|'::text) AS contributors
             FROM api_objects repo_details_1,
              LATERAL jsonb_to_recordset((repo_details_1.body -> 'contributors'::text)) contributor(login text)
            WHERE (((repo_details_1.type)::text = 'ApiObject::GithubRepoDetails'::text) AND ((repo_details_1.body ->> 'contributors'::text) <> ''::text))
            GROUP BY repo_details_1.object_id
          ), languages_by_repo AS (
           SELECT repo_details_1.object_id,
              string_agg(languages.key, '|'::text) AS languages
             FROM api_objects repo_details_1,
              LATERAL jsonb_each_text((repo_details_1.body -> 'languages'::text)) languages(key, value)
            WHERE (((repo_details_1.type)::text = 'ApiObject::GithubRepoDetails'::text) AND ((repo_details_1.body ->> 'languages'::text) <> ''::text))
            GROUP BY repo_details_1.object_id
          ), topics_by_repo AS (
           SELECT api_objects.object_id,
              string_agg(topics.name, '|'::text) AS topics
             FROM api_objects,
              LATERAL jsonb_to_recordset((api_objects.body -> 'topics'::text)) topics(name text)
            WHERE (((api_objects.type)::text = 'ApiObject::GithubRepo'::text) AND ((api_objects.body ->> 'topics'::text) <> ''::text))
            GROUP BY api_objects.object_id
          )
   SELECT brigade_projects.id AS brigade_project_id,
      (repo.body ->> 'name'::text) AS github_repo_name,
      (repo.body ->> 'description'::text) AS github_repo_description,
      array_to_string(xpath('//xhtml:h1[1]/descendant-or-self::text()'::text, ((repo_details.body ->> 'readme_html'::text))::xml, ARRAY[ARRAY['xhtml'::text, 'http://www.w3.org/1999/xhtml'::text]]), ''::text) AS github_readme_title,
      array_to_string(xpath('//xhtml:p[1]/descendant-or-self::text()'::text, ((repo_details.body ->> 'readme_html'::text))::xml, ARRAY[ARRAY['xhtml'::text, 'http://www.w3.org/1999/xhtml'::text]]), ''::text) AS github_readme_first_paragraph,
      contributors_by_repo.contributors AS github_contributors,
      languages_by_repo.languages AS github_languages,
      topics_by_repo.topics AS github_topics,
      array_to_string(xpath('//xhtml:*/descendant-or-self::text()'::text, ((repo_details.body ->> 'readme_html'::text))::xml, ARRAY[ARRAY['xhtml'::text, 'http://www.w3.org/1999/xhtml'::text]]), ''::text) AS github_readme_text
     FROM (((((brigade_projects
       JOIN api_objects repo ON ((((repo.object_id)::text = (brigade_projects.code_url)::text) AND ((repo.type)::text = 'ApiObject::GithubRepo'::text))))
       JOIN api_objects repo_details ON ((((repo_details.object_id)::text = (brigade_projects.code_url)::text) AND ((repo_details.type)::text = 'ApiObject::GithubRepoDetails'::text))))
       LEFT JOIN contributors_by_repo ON (((contributors_by_repo.object_id)::text = (repo.object_id)::text)))
       LEFT JOIN languages_by_repo ON (((languages_by_repo.object_id)::text = (repo.object_id)::text)))
       LEFT JOIN topics_by_repo ON (((topics_by_repo.object_id)::text = (repo.object_id)::text)));
  SQL
  create_view "brigade_projects_searches", materialized: true, sql_definition: <<-SQL
      SELECT brigade_projects_search_fields.brigade_project_id,
      (((((((setweight(to_tsvector(COALESCE(brigade_projects_search_fields.github_repo_name, ''::text)), 'A'::"char") || setweight(to_tsvector(COALESCE(brigade_projects_search_fields.github_repo_description, ''::text)), 'A'::"char")) || setweight(to_tsvector(COALESCE(brigade_projects_search_fields.github_readme_title, ''::text)), 'B'::"char")) || setweight(to_tsvector(COALESCE(brigade_projects_search_fields.github_readme_first_paragraph, ''::text)), 'B'::"char")) || setweight(to_tsvector(COALESCE(brigade_projects_search_fields.github_contributors, ''::text)), 'A'::"char")) || setweight(to_tsvector(COALESCE(brigade_projects_search_fields.github_languages, ''::text)), 'A'::"char")) || setweight(to_tsvector(COALESCE(brigade_projects_search_fields.github_topics, ''::text)), 'A'::"char")) || setweight(to_tsvector(COALESCE(brigade_projects_search_fields.github_readme_text, ''::text)), 'C'::"char"))
     FROM brigade_projects_search_fields;
  SQL
end
