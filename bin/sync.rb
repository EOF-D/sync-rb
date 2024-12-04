#!/usr/bin/env ruby

require 'optparse'
require 'async'
require_relative '../lib/sync/version'
require_relative '../lib/sync/config'
require_relative '../lib/sync/auth'

class SyncApp
  def self.run
    options = parse_options
    config = Sync::Config.new(options[:config])

    Async do
      authenticator = Sync::Authenticator.new(config)
      access_token = authenticator.authenticate.wait
      puts access_token
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
    end.parse!

    options
  end
end

SyncApp.run
