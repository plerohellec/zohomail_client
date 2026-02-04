require "curb"
require "json"
require "dotenv"
require_relative "zohomail_client/version"
require_relative "zohomail_client/auth"
require_relative "zohomail_client/client"

module ZohomailClient
  class Error < StandardError; end

  def self.client_from_env
    Dotenv.load
    client_id = ENV["ZOHOMAIL_CLIENT_ID"]
    client_secret = ENV["ZOHOMAIL_CLIENT_SECRET"]
    refresh_token = ENV["ZOHOMAIL_REFRESH_TOKEN"]
    user_id = ENV["ZOHOMAIL_USER_ID"]

    unless client_id && client_secret && refresh_token && user_id
      raise Error, "Missing required environment variables (ZOHOMAIL_CLIENT_ID, ZOHOMAIL_CLIENT_SECRET, ZOHOMAIL_REFRESH_TOKEN, ZOHOMAIL_USER_ID)"
    end

    auth = Auth.new(client_id: client_id, client_secret: client_secret)
    token_resp = auth.refresh_access_token(refresh_token)

    if token_resp["access_token"]
      Client.new(access_token: token_resp["access_token"], user_id: user_id)
    else
      raise Error, "Error refreshing access token: #{token_resp}"
    end
  end
end
