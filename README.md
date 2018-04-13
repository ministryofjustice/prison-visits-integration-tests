# Integration & Smoke Tests for the Prison Visits Booking Service

Integration and smoke tests are run by Jenkins.
 
*Integration tests* ...
- run every 30 minutes and when application branches are merged to master
- *staging* environment only

*Smoke tests* ...
- run every 30 minutes and when application branches are merged to master
- *production* environment only
 
Both test suites are run against the Firefox browser.


## Setup instructions

### Running tests

    bundle install
    bundle exec rspec spec/integration   # Integration tests only
    bundle exec rspec spec/smoke         # Smoke tests only

### Running tests locally

These tests run fine locally. The only change to the default development configuration is to redirect email to mailtrap.

When configuring SMTP (get the credentials by logging into mailtrap), note that the MoJ network blocks outgoing requests on port 2525, so use port 465 instead of the default copy-paste config.

1. Configure mailtrap (in `prison-visits-2 - development.rb`)
2. Start PVB2 (app & sidekiq)
3. Start PVB Public (app)
4. Run tests

*NOTE* - It is recommended you run using Firefox browser <= 57.0.4 as more recent versions can cause issues with Capybara and clicking button elements.

## Test Configuration

I recommend copying `.env.example` to `.env` and using direnv to automatically load these configuration variables (`brew install direnv`).

See `.env.example` for default development configuration.

### `MAILTRAP_API_TOKEN`
API token for Mailtrap, used to fetch email via the API.

### `START_PAGE`
This should be the start page for creating a new booking.

### `PRISON_START_PAGE`
This should be the index page of prisons used by staff.

### `EMAIL` & `PASSWORD`
Staff login details (for single sign on).

## Docker build

    docker build -t pvb-integration .
    docker run --env-file=.env pvb-integration
