require "curb"
require "json"
require_relative "zohomail_client/version"
require_relative "zohomail_client/auth"
require_relative "zohomail_client/client"

module ZohomailClient
  class Error < StandardError; end

  class Configuration
    attr_accessor :client_id, :client_secret, :refresh_token, :account_id, :allow_send_mail

    def initialize
      @client_id = nil
      @client_secret = nil
      @refresh_token = nil
      @account_id = nil
      @allow_send_mail = false
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client
      client_id = configuration.client_id
      client_secret = configuration.client_secret
      refresh_token = configuration.refresh_token
      account_id = configuration.account_id

      unless client_id && client_secret && refresh_token && account_id
        raise Error, "ZohomailClient is not configured. Please use ZohomailClient.configure to set client_id, client_secret, refresh_token, and account_id."
      end

      auth = Auth.new(client_id: client_id, client_secret: client_secret)
      token_resp = auth.refresh_access_token(refresh_token)

      if token_resp["access_token"]
        Client.new(access_token: token_resp["access_token"], account_id: account_id, allow_send_mail: configuration.allow_send_mail)
      else
        raise Error, "Error refreshing access token: #{token_resp}"
      end
    end
  end
end
