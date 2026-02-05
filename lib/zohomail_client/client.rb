module ZohomailClient
  class Client
    BASE_URL = "https://mail.zoho.com/api"

    def initialize(access_token:, account_id:)
      @access_token = access_token
      @account_id = account_id
    end

    def list_messages(folder_id: nil, limit: 10)
      url = "#{BASE_URL}/accounts/#{@account_id}/messages/view?limit=#{limit}"
      url += "&folderId=#{folder_id}" if folder_id
      perform_get(url)
    end

    def list_folders
      url = "#{BASE_URL}/accounts/#{@account_id}/folders"
      perform_get(url)
    end

    def get_message_content(folder_id, message_id)
      url = "#{BASE_URL}/accounts/#{@account_id}/folders/#{folder_id}/messages/#{message_id}/content"
      perform_get(url)
    end

    def send_email(to:, subject:, content:, from: nil, mail_format: "plaintext")
      url = "#{BASE_URL}/accounts/#{@account_id}/messages"
      payload = {
        fromAddress: from,
        toAddress: to,
        subject: subject,
        content: content,
        mailFormat: mail_format
      }
      payload.delete(:fromAddress) if from.nil?

      perform_post(url, payload)
    end

    private

    def perform_get(url)
      curl = Curl::Easy.new(url) do |c|
        c.headers["Authorization"] = "Zoho-oauthtoken #{@access_token}"
        c.headers["Accept"] = "application/json"
      end
      curl.perform
      handle_response(curl)
    rescue JSON::ParserError
      raise Error, "Failed to parse API response as JSON: #{curl.body_str}"
    rescue => e
      raise Error, "Network or API error: #{e.message}"
    end

    def perform_post(url, payload)
      curl = Curl::Easy.new(url) do |c|
        c.headers["Authorization"] = "Zoho-oauthtoken #{@access_token}"
        c.headers["Content-Type"] = "application/json"
        c.headers["Accept"] = "application/json"
      end
      curl.http_post(payload.to_json)
      handle_response(curl)
    rescue JSON::ParserError
      raise Error, "Failed to parse API response as JSON: #{curl.body_str}"
    rescue => e
      raise Error, "Network or API error: #{e.message}"
    end

    def handle_response(curl)
      case curl.response_code
      when 200..299
        JSON.parse(curl.body_str)
      else
        begin
          body = JSON.parse(curl.body_str)
          desc = body.dig("status", "description") || "Unknown error"
          code = body.dig("status", "code") || curl.response_code
          raise Error, "Zoho API Error #{code}: #{desc} (URL: #{curl.url})"
        rescue JSON::ParserError
          raise Error, "Zoho API Error #{curl.response_code}: #{curl.body_str}"
        end
      end
    end
  end
end
