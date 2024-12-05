require 'toml-rb'

module Sync
  class Config
    TOKEN_KEY = 'github-access-token'.freeze
    attr_reader :github_org, :github_project_id, :github_client_id, :config_path

    def initialize(config_path = 'config.toml')
      @config = TomlRB.load_file(config_path)
      @config_path = config_path

      validate_config
    end

    def update_config(section, key, value)
      @config[section] ||= {}
      @config[section][key] = value

      File.open(@config_path, 'w') do |file|
        file.write(TomlRB.dump(@config))
      end
    end

    def store_access_token(token)
      update_config('github', TOKEN_KEY, token)
    end

    def retrieve_access_token
      @config.dig('github', TOKEN_KEY)
    end

    def clear_access_token
      @config['github'].delete(TOKEN_KEY) if @config['github']

      File.open(@config_path, 'w') do |file|
        file.write(TomlRB.dump(@config))
      end
    end

    private

    def validate_config
      @github_org = @config.dig('github', 'org-name')
      @github_project_id = @config.dig('github', 'org-project-id')
      @github_client_id = @config.dig('github', 'client-id')

      raise ArgumentError, 'Invalid configuration: Missing GitHub or Gitea settings' if
        [@github_org, @github_project_id, @github_client_id].any?(&:nil?)
    end
  end
end

