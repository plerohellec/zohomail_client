module ZohomailClient
  class Auth
    TOKEN_URL = "https://accounts.zoho.com/oauth/v2/token"

    def initialize(client_id:, client_secret:)
      @client_id = client_id
      @client_secret = client_secret
    end

    def get_tokens_from_grant(grant_token)
      fields = {
        code: grant_token,
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "authorization_code"
      }.map { |k, v| Curl::PostField.content(k.to_s, v) }

      curl = Curl::Easy.http_post(TOKEN_URL, *fields)
      JSON.parse(curl.body_str)
    end

    def refresh_access_token(refresh_token)
      fields = {
        refresh_token: refresh_token,
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "refresh_token"
      }.map { |k, v| Curl::PostField.content(k.to_s, v) }

      curl = Curl::Easy.http_post(TOKEN_URL, *fields)
      JSON.parse(curl.body_str)
    end
  end
end
