# ZohomailClient

A simple Ruby gem to interact with the Zoho Mail API using OAuth2 and Curb.

## Requierements

Create a Zoho "Self client" app from https://api-console.zoho.com/ to get you client id, secret and grant token.

## Installation

This gem is for internal use. To set up dependencies:

```bash
bundle install
```

## Configuration

Create a `.env` file in the root directory (see `.env.example`):

```bash
ZOHOMAIL_CLIENT_ID=your_client_id
ZOHOMAIL_CLIENT_SECRET=your_client_secret
ZOHOMAIL_ACCOUNT_ID=your_account_id
ZOHOMAIL_REFRESH_TOKEN=your_refresh_token
ZOHOMAIL_INBOX_FOLDER_ID=your_default_folder_id
```

## Library Usage

### 1. Creating the Client

First, configure the gem with your Zoho credentials:

```ruby
require 'zohomail_client'

ZohomailClient.configure do |config|
  config.client_id = ENV['ZOHOMAIL_CLIENT_ID']
  config.client_secret = ENV['ZOHOMAIL_CLIENT_SECRET']
  config.refresh_token = ENV['ZOHOMAIL_REFRESH_TOKEN']
  config.account_id = ENV['ZOHOMAIL_ACCOUNT_ID']
end

# Refreshes the access token using the configuration and returns a client
client = ZohomailClient.client
```

Alternatively, you can provide the access token and user ID manually to create a client without a refresh token cycle:

```ruby
client = ZohomailClient::Client.new(
  access_token: 'your_access_token',
  account_id: 'your_account_id'
)
```

### 2. Listing Messages

```ruby
# List messages (default: 10 messages from Inbox)
response = client.list_messages

# List messages with options
response = client.list_messages(folder_id: "123456789", limit: 5)

response["data"].each do |message|
  puts "Subject: #{message['subject']}"
  puts "From: #{message['sender']}"
  puts "ID: #{message['messageId']}"
  puts "---"
end
```

### 3. Fetching Message Content

```ruby
# Fetch content using folder_id and message_id
response = client.get_message_content("123456789", "987654321")

puts "Content: #{response['data']['content']}"
```

### 4. Sending an Email

```ruby
# Send a new email
client.send_email(
  to: "recipient@example.com",
  subject: "Hello from Ruby",
  content: "This is a test email sent via Zoho Mail API."
)

# Send with additional options
client.send_email(
  to: "recipient@example.com",
  subject: "Hello from Ruby",
  content: "This is a test email sent via Zoho Mail API.",
  from: "sender@example.com",
  mail_format: "html",
  is_draft: true
)
```

### 5. Sending an Email Reply

```ruby
# Reply to a message
response = client.send_reply(
  folder_id: "123456789",
  message_id: "987654321",
  content: "Thank you for your email."
)

# Reply with options
response = client.send_reply(
  folder_id: "123456789",
  message_id: "987654321",
  content: "Thank you for your email.",
  mail_format: "html",
  is_draft: true
)
```

## Command Line Usage

### 1. Authentication

First, you need a grant token from the Zoho Developer Console (Self-Client).

```bash
./bin/zohomail-auth <grant_token>
```

This will exchange the grant token for a refresh token and store it in your `.env` file.

### 2. List Folders

To see your folders and their IDs:

```bash
./bin/zohomail-folders
```

### 3. List Recent Emails

```bash
./bin/zohomail-list [options]
```

Options:
- `--limit LIMIT`: Number of emails to fetch (default: 10)
- `--folder-id FOLDER_ID`: Folder ID to fetch from (default: from ZOHOMAIL_INBOX_FOLDER_ID env)
- `--format FORMAT`: Output format: text or json (default: text)
- `--help`: Show help

Examples:
```bash
./bin/zohomail-list
./bin/zohomail-list --limit 20 --folder-id 123456789
./bin/zohomail-list --format json
```

### 4. Fetch Email Content

```bash
./bin/zohomail-get [options] <message_id>
```

Options:
- `--folder-id FOLDER_ID`: Folder ID (default: from ZOHOMAIL_INBOX_FOLDER_ID env)
- `--format FORMAT`: Output format: text or json (default: text)
- `--help`: Show help

Examples:
```bash
./bin/zohomail-get 987654321
./bin/zohomail-get --folder-id 123456789 987654321
./bin/zohomail-get --format json 987654321
```

### 5. Send Email

```bash
./bin/zohomail-send [options]
```

Options:
- `-t, --to EMAIL`: Recipient email address (required)
- `-s, --subject SUBJECT`: Email subject (required unless replying)
- `-c, --content CONTENT`: Email content (interprets \n as newline, required)
- `-f, --from EMAIL`: Sender email address
- `--format FORMAT`: Email format: html or plaintext (default: plaintext)
- `--draft`: Save as draft
- `--reply-to ID`: Reply to a specific message ID
- `-h, --help`: Show help

Examples:
```bash
./bin/zohomail-send -t recipient@example.com -s "Hello" -c "Test email"
./bin/zohomail-send -t recipient@example.com -s "Hello" -c "Test email" -f sender@example.com --format html
```

### 6. Reply to Email

```bash
./bin/zohomail-reply [options] <message_id>
```

Options:
- `-c, --content CONTENT`: Reply content (interprets \n as newline)
- `--folder-id ID`: Folder ID of the original message
- `--format FORMAT`: Email format: html or plaintext (default: plaintext)
- `--draft`: Save as draft
- `-h, --help`: Show help

Examples:
```bash
./bin/zohomail-reply -c "Thank you for your email." 987654321
./bin/zohomail-reply --folder-id 123456789 -c "Thank you for your email." 987654321
./bin/zohomail-reply --format html --draft -c "<p>Thank you for your email.</p>" 987654321
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/plerohellec/zohomail_client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
