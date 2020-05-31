class ProjectsController < ApplicationController
  SearchResult = Struct.new(:brigade, :project, :search_properties) do
  end

  def index
  end

  def search
    # turn the query into a tsquery
    words = params[:q].scan(/"[\w ]+"|\w+/)
    words[-1] = words[-1] + ":*"
    q = words.join(' & ')

    @results = BrigadeProject.connection.execute(BrigadeProject.sanitize_sql([<<-SQL.strip_heredoc, q, q])).map(&:to_h)
      SELECT
        brigade_projects_searches.brigade_project_id,
        ts_rank_cd(keywords, to_tsquery(?)) as rank,
        brigade_projects.*
      FROM brigade_projects_searches
      INNER JOIN brigade_projects
        ON brigade_projects.id = brigade_project_id
      INNER JOIN brigade_projects_search_fields
        ON brigade_projects_search_fields.brigade_project_id = brigade_projects_searches.brigade_project_id
      WHERE ts_rank_cd(keywords, to_tsquery(?)) > 0
      ORDER BY rank DESC
      LIMIT 15;
    SQL

    ids = @results.map { |r| r['brigade_project_id'] }
    @search_properties = BrigadeProject.connection.execute(BrigadeProject.sanitize_sql([<<-SQL.strip_heredoc, ids])).index_by { |r| r['brigade_project_id'] }
      SELECT *
      FROM brigade_projects_search_fields
      WHERE brigade_project_id IN (?)
    SQL

    @brigades = Brigade.where(id: @results.map { |r| r['brigade_id'] }).index_by(&:id)

    respond_to do |format|
      format.json { render json: @results.map { |r| SearchResult.new(@brigades[r['brigade_id']], r, @search_properties[r['brigade_project_id']]) } }
    end
  end
end
