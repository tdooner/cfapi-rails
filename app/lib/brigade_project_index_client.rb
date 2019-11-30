require 'tomlrb'
require 'zip'

class BrigadeProjectIndexClient
  ZIP_URL = URI('https://codeload.github.com/codeforamerica/brigade-project-index/zip/index/v1')
  FILE_TYPES = {
    organization: %r{/organizations/(?<org_name>[^/\.]+)\.toml},
    project: %r{/projects/(?<org_name>[^/\.]+)/.*\.toml},
  }

  def initialize
  end

  def projects_by_organization(&block)
    return to_enum(:projects_by_organization) unless block_given?

    @organizations = {}
    @projects_by_organization = {}

    Tempfile.create('brigade-project-index', encoding: 'ascii-8bit') do |f|
      f.write Net::HTTP.get(ZIP_URL)
      f.close

      Zip::File.open(f.path) do |zip|
        zip.each do |entry|
          next unless entry.ftype == :file
          next unless entry.name.end_with?('.toml')

          file_type = FILE_TYPES.detect { |_, regex| regex.match(entry.name) }&.first
          next unless file_type

          org_name = $LAST_MATCH_INFO[:org_name]
          file_contents = entry.get_input_stream.read.force_encoding('utf-8')

          case file_type
          when :organization
            @organizations[org_name] = Tomlrb.parse(file_contents)
          when :project
            @projects_by_organization[org_name] ||= []
            @projects_by_organization[org_name] << Tomlrb.parse(file_contents)
          end
        end
      end
    end

    @projects_by_organization.each do |organization_name, projects|
      organization = @organizations[organization_name]
      block.call(organization, projects)
    end
  end
end
