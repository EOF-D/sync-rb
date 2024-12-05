#!/usr/bin/env ruby

require 'optparse'
require 'async'
require_relative '../lib/sync/version'
require_relative '../lib/sync/config'
require_relative '../lib/sync/auth'
require_relative '../lib/sync/migrator'

class SyncApp
  def self.run
    options = parse_options
    config = Sync::Config.new(options[:config])

    Async do
      cached_token = config.retrieve_access_token
      if cached_token
        access_token = cached_token

      else
        authenticator = Sync::Authenticator.new(config)
        access_token = authenticator.authenticate.wait
        config.store_access_token(access_token)
      end

      migrator = Sync::ProjectMigrator.new(config, access_token)
      project = migrator.fetch_full_project_details.wait

      puts project
    end

    Async::Reactor.run
  end

  def self.parse_options
    options = { config: 'config.toml' }

    OptionParser.new do |opts|
      opts.banner = 'Usage: sync.rb [options]'

      opts.on('-c', '--config PATH', 'Path to config file') do |path|
        options[:config] = path
      end

      opts.on('-v', '--version', 'Show version') do
        puts "sync-rb version: #{Sync::VERSION}"
        exit
      end

      opts.on('--clear-token', 'Clear stored access token') do
        config = Sync::Config.new
        config.clear_access_token
        puts 'Cached access token cleared.'
        exit
      end
    end.parse!

    options
  end
end

SyncApp.run

