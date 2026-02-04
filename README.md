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
```

## Usage

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
./bin/zohomail-list [limit] [folder_id]
```

### 4. Fetch Email Content

```bash
./bin/zohomail-get <folder_id> <message_id>
```

### 5. Send Email

```bash
./bin/zohomail-send <to> <subject> <content> [from]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/zohomail_client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
