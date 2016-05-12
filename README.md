## Setup instructions

PhantomJS must be installed

	brew install phantomjs

Run the tests

	bundle install
	bundle exec rspec spec/**/*_spec.rb

### Running locally

These tests run fine locally. The only change to the default development configuration is to redirect email to mailtrap.

When configuring SMTP (get the credentials by logging into mailtrap), note that the MoJ network blocks outgoing requests on port 2525, so use port 465 instead of the default copy-paste config.

1. Configure mailtrap (in `prison-visits-2 - development.rb`)
2. Start PVB2 (app & sidekiq)
3. Start PVB Public (app)
4. Run tests

## Test Configuration

I recommend copying `.env.example` to `.env` and using direnv to automatically load these configuration variables (`brew install direnv`).

### `MAILTRAP_API_TOKEN`
API token for Mailtrap, used to fetch email via the API.

### `START_PAGE`
This should be the start page for creating a new booking. In development this would be set to `http://localhost:4000/en/request`.
