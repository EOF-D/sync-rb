require 'async'
require 'async/http/faraday'
require 'json'

module Sync
  class Authenticator
    GITHUB_URL = 'https://github.com'.freeze
    GITHUB_DEVICE_URL = 'https://github.com/login/device/code'.freeze
    GITHUB_ACCESS_TOKEN_URL = 'https://github.com/login/oauth/access_token'.freeze
    GITHUB_VERIFY_URL = 'https://github.com/login/device'.freeze

    def initialize(config)
      @config = config
      @client = Faraday.new(url: GITHUB_URL)
    end

    def prompt(user_code)
      puts 'GitHub Authentication Required'
      puts ' -> Go to: https://github.com/login/device'
      puts " -> Enter code: #{user_code}"
      puts 'Waiting for authentication...'
    end

    def authenticate
      response = @client.post(GITHUB_DEVICE_URL) do |req|
        req.headers['Accept'] = 'application/json'
        req.body = {
          client_id: @config.github_client_id,
          scope: 'read:project read:user'
        }
      end

      data = JSON.parse(response.body)
      prompt(data['user_code'])

      poll_token(
        device_code: data['device_code'],
        interval: data['interval']
      )
    end

    def poll_token(device_code:, interval:)
      Async do |task|
        max_attempts = 50
        attempts = 0

        loop do
          response = @client.post(GITHUB_ACCESS_TOKEN_URL) do |req|
            req.headers['Accept'] = 'application/json'
            req.body = {
              client_id: @config.github_client_id,
              device_code: device_code,
              grant_type: 'urn:ietf:params:oauth:grant-type:device_code'
            }
          end

          data = JSON.parse(response.body)
          case data['error']
          when 'authorization_pending'
            attempts += 1
            raise AuthenticationError, 'Authorization timed out' if attempts >= max_attempts

            task.sleep(interval)

          when 'slow_down'
            interval += 5
            task.sleep(interval)

          when nil
            break data['access_token']

          else
            raise AuthenticationError, "Authentication error: #{data['error']}"
          end
        end
      end
    end

    class AuthenticationError < StandardError; end
  end
end
