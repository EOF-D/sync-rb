require 'async'
require 'async/http/faraday'
require 'json'
require_relative 'queries'

module Sync
  class ProjectMigrator
    def initialize(config, access_token)
      @config = config
      @access_token = access_token
      @client = Faraday.new(url: 'https://api.github.com/graphql') do |faraday|
        faraday.headers['Authorization'] = "Bearer #{@access_token}"
        faraday.headers['Content-Type'] = 'application/json'
      end
    end

    def fetch_full_project_details
      Async do
        project_details_query = {
          query: GithubQueries::PROJECT_QUERY,
          variables: {
            organization: @config.github_org,
            number: @config.github_project_id.to_i
          }
        }

        response = @client.post do |req|
          req.body = project_details_query.to_json
        end

        project_details_data = JSON.parse(response.body)
        project_details_data.dig('data', 'organization', 'projectV2')
      end
    end
  end
end

