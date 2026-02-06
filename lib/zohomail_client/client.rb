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

    def get_message_meta_data(folder_id, message_id)
      url = "#{BASE_URL}/accounts/#{@account_id}/folders/#{folder_id}/messages/#{message_id}/details"
      perform_get(url)
    end

    def send_email(to:, content:, subject: nil, from: nil, mail_format: "plaintext", is_draft: false, reply_to_message_id: nil)
      payload = {
        toAddress: to,
        content: content,
        mailFormat: mail_format
      }

      # If replying AND drafting, we must use the generic endpoint to ensure it's saved as draft
      # instead of sent immediately. The 'reply' action on the message ID endpoint triggers sending.
      if reply_to_message_id
        url = "#{BASE_URL}/accounts/#{@account_id}/messages/#{reply_to_message_id}"

        payload[:action] = "reply"
        if is_draft
          payload[:isSchedule] = 'true'
          payload[:scheduleType] = 2
          payload[:timeZone] = Time.now.getlocal.zone
        end
      else
        url = "#{BASE_URL}/accounts/#{@account_id}/messages"

        if is_draft
          payload[:mode] = "draft"
        end
      end

      # Normalize newlines to CRLF for plaintext as recommended by Zoho API
      content = content.gsub(/\r?\n/, "\r\n") if mail_format == "plaintext"

      payload[:fromAddress] = from if from
      payload[:subject] = subject if subject

      perform_post(url, payload)
    end

    def send_reply(folder_id:, message_id:, content:, from: nil, mail_format: "plaintext", is_draft: false)
      metadata = get_message_meta_data(folder_id, message_id)
      data = metadata["data"]

      subject = data["subject"]
      subject = "Re: #{subject}" unless subject.downcase.start_with?("re:")

      to = data["fromAddress"]

      send_email(
        to: to,
        from: from,
        content: content,
        subject: subject,
        mail_format: mail_format,
        is_draft: is_draft,
        reply_to_message_id: message_id
      )
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
      raise Error, "Network or API error: #{e.message} - #{curl.body_str}"
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
      raise Error, "Network or API error: #{e.message} - #{curl.body_str}"
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
