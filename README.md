# ZohomailClient

A simple Ruby gem to interact with the Zoho Mail API using OAuth2 and Curb.

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
ZOHOMAIL_USER_ID=your_user_id
ZOHOMAIL_REFRESH_TOKEN=your_refresh_token
ZOHOMAIL_FOLDER_ID=your_default_folder_id
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
  config.user_id = ENV['ZOHOMAIL_USER_ID']
end

# Refreshes the access token using the configuration and returns a client
client = ZohomailClient.client
```

Alternatively, you can provide the access token and user ID manually to create a client without a refresh token cycle:

```ruby
client = ZohomailClient::Client.new(
  access_token: 'your_access_token',
  user_id: 'your_user_id'
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
client.send_email(
  to: "recipient@example.com",
  subject: "Hello from Ruby",
  content: "This is a test email sent via Zoho Mail API."
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
- `--folder-id FOLDER_ID`: Folder ID to fetch from (default: from ZOHOMAIL_FOLDER_ID env)
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
- `--folder-id FOLDER_ID`: Folder ID (default: from ZOHOMAIL_FOLDER_ID env)
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
./bin/zohomail-send <to> <subject> <content> [from]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/plerohellec/zohomail_client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
