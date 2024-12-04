require 'toml-rb'

module Sync
  class Config
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
