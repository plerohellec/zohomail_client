# ZohomailClient

A simple Ruby gem to interact with the Zoho Mail API using OAuth2 and Curb.

## Requirements

Create a Zoho "Self client" app from https://api-console.zoho.com/ to get you client id and secret.
Generate a grant token (aka "Code") with scopes ZohoMail.accounts.READ, ZohoMail.folders.READ, ZohoMail.messages.ALL.

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
ZOHOMAIL_CACHE_FILE_PATH=./zoho_cache.json
```

The `cache_file_path` is used to store folder IDs mapped to their names. This avoids fetching the full list of folders from Zoho on every request when using `folder_name` instead of `folder_id`.

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
  config.cache_file_path = ENV['ZOHOMAIL_CACHE_FILE_PATH'] # Optional: Path to store folder ID cache
  config.allow_send_mail = false  # Set to true to allow sending emails; false forces all emails as drafts (default: false)
end

# Refreshes the access token using the configuration and returns a client
client = ZohomailClient.client
```

Alternatively, you can provide the access token and user ID manually to create a client without a refresh token cycle:

```ruby
client = ZohomailClient::Client.new(
  access_token: 'your_access_token',
  account_id: 'your_account_id',
  cache_file_path: './zoho_cache.json' # Optional
)
```

### 2. Listing Messages

```ruby
# List messages (default: 10 messages from Inbox)
response = client.list_messages

# List messages with options
response = client.list_messages(folder_name: "Inbox", limit: 5)

response["data"].each do |message|
  puts "Subject: #{message['subject']}"
  puts "From: #{message['sender']}"
  puts "ID: #{message['messageId']}"
  puts "---"
end
```

### 3. Searching Messages

```ruby
# Search for messages using Zoho Mail search syntax
# See https://www.zoho.com/mail/help/search-syntax.html for search syntax details

# Search for emails from a specific sender
response = client.search_messages("sender:john@example.com", limit: 10)

# Search for emails with specific subject
response = client.search_messages("subject:meeting", limit: 10)

# Search for emails with attachments
response = client.search_messages("has:attachment", limit: 10)

# Search with multiple criteria
response = client.search_messages("from:john@example.com subject:project", limit: 10)

# Search for exact phrase
response = client.search_messages('entire:"Hello world"', limit: 10)

response["data"].each do |message|
  puts "Subject: #{message['subject']}"
  puts "From: #{message['sender']}"
  puts "ID: #{message['messageId']}"
  puts "---"
end
```

### 4. Fetching Message Content

```ruby
# Fetch content using folder_name and message_id
response = client.get_message_content("Inbox", "987654321")

puts "Content: #{response['data']['content']}"
```

### 5. Sending an Email

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

### 6. Sending an Email Reply

```ruby
# Reply to a message
response = client.send_reply(
  folder_name: "Inbox",
  message_id: "987654321",
  content: "Thank you for your email."
)

# Reply with options
response = client.send_reply(
  folder_name: "Inbox",
  message_id: "987654321",
  content: "Thank you for your email.",
  mail_format: "html",
  is_draft: true
)

# Reply with custom recipient
response = client.send_reply(
  folder_name: "Inbox",
  message_id: "987654321",
  content: "Thank you for your email.",
  to: "custom@example.com"
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
- `--folder-name NAME`: Folder name to fetch from (e.g. Inbox)
- `--format FORMAT`: Output format: text or json (default: text)
- `--help`: Show help

Examples:
```bash
./bin/zohomail-list
./bin/zohomail-list --limit 20 --folder-name "Trash"
./bin/zohomail-list --format json
```

### 4. Search Emails

```bash
./bin/zohomail-search [options] <search_key>
```

Options:
- `--limit LIMIT`: Number of emails to fetch (default: 10)
- `--format FORMAT`: Output format: text or json (default: text)
- `--help`: Show help

Search Key Examples:
- `sender:john@example.com` - Search by sender
- `subject:meeting` - Search by subject
- `has:attachment` - Emails with attachments
- `has:flags` - Flagged emails
- `entire:"Hello world"` - Exact phrase search
- `from:john@example.com subject:project` - Multiple criteria

Examples:
```bash
./bin/zohomail-search "sender:john@example.com"
./bin/zohomail-search --limit 20 "subject:meeting"
./bin/zohomail-search --format json "has:attachment"
./bin/zohomail-search 'entire:"Hello world"'
```

See https://www.zoho.com/mail/help/search-syntax.html for more search syntax details.

### 5. Fetch Email Content

```bash
./bin/zohomail-get [options] <message_id>
```

Options:
- `--folder-name NAME`: Folder name (e.g. Inbox)
- `--format FORMAT`: Output format: text or json (default: text)
- `--help`: Show help

Examples:
```bash
./bin/zohomail-get --folder-name Inbox 987654321
./bin/zohomail-get --folder-name "Sent" 987654321
./bin/zohomail-get --format json --folder-name Inbox 987654321
```

### 6. Send Email

```bash
./bin/zohomail-send [options]
```

Options:
- `-t, --to EMAIL`: Recipient email address (required)
- `--cc EMAIL`: CC recipient email address (comma separated for multiple)
- `-s, --subject SUBJECT`: Email subject (required unless replying)
- `-c, --content CONTENT`: Email content (interprets \n as newline, required)
- `-f, --from EMAIL`: Sender email address (required)
- `--format FORMAT`: Email format: html or plaintext (default: plaintext)
- `--skip-draft`: Skip creating a draft and send immediately
- `--reply-to ID`: Reply to a specific message ID
- `-h, --help`: Show help

Examples:
```bash
./bin/zohomail-send -t recipient@example.com -s "Hello" -c "Test email" -f sender@example.com
./bin/zohomail-send -t recipient@example.com --cc cc1@example.com,cc2@example.com -s "Hello" -c "Test email" -f sender@example.com --format html
```

### 7. Reply to Email

```bash
./bin/zohomail-reply [options] <message_id>
```

Options:
- `-c, --content CONTENT`: Reply content (interprets \n as newline)
- `--cc EMAIL`: CC recipient email address (comma separated for multiple)
- `--folder-name NAME`: Folder name of the original message
- `--to EMAIL`: Recipient email address (optional, defaults to original sender)
- `--format FORMAT`: Email format: html or plaintext (default: plaintext)
- `--skip-draft`: Skip creating a draft and send immediately
- `-h, --help`: Show help

Examples:
```bash
./bin/zohomail-reply --folder-name Inbox -c "Thank you for your email." 987654321
./bin/zohomail-reply --folder-name Inbox --cc cc@example.com -c "Thank you for your email." 987654321
./bin/zohomail-reply --folder-name "Sent" -c "Thank you for your email." 987654321
./bin/zohomail-reply --format html --skip-draft -c "<p>Thank you for your email.</p>" 987654321
./bin/zohomail-reply --to custom@example.com --folder-name Inbox -c "Thank you for your email." 987654321
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/plerohellec/zohomail_client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
