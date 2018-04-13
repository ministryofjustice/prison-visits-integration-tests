require 'spec_helper'
require 'securerandom'

RSpec.feature 'booking a visit', type: :feature do
  let(:prisoner) do
    # Trivia: George Best spent 7 days imprisoned in Pentonville for driving
    # under alcohol and assault [wikipedia]
    Prisoner.new(
      'George', 'Best',
      Date.parse(ENV['PRISONER_DOB']), # Actually 1946-05-22
      ENV['PRISONER_NUMBER'],
      ENV['PRISON']
    )
  end

  let(:visitor) do
    Visitor.new(
      'Peter', 'Sellers',
      Date.parse('1925-09-08'),
      "#{SecureRandom.uuid}@email.prisonvisits.service.gov.uk",
      '079 00112233'
    )
  end

  scenario 'fixing prisoner number typo, making a booking, then cancelling it immediately' do
    start_page = ENV.fetch('START_PAGE')

    # Fixing typo (checks nomis API is working): Step 0 (prisoner)
    visit start_page
    expect(page).to have_content 'Who are you visiting?'

    fill_in_prisoner_step(prisoner)

    if ENV['PUBLIC_PRISONER_CHECK'] == 'true'
      fill_in 'Prisoner number', with: 'Z0000AA'
      click_button 'Continue'
      expect(page).to have_css('fieldset span.error-message', text: 'No prisoner matches the details you’ve supplied, please ask the prisoner to check your details are correct')
    end

    # Booking: Step 1 (prisoner)
    fill_in 'Prisoner number', with: prisoner.number
    click_button 'Continue'

    # Booking: Step 2 (pick 1 slot)
    expect(page).to have_css 'h1', text: 'When do you want to visit?'
    select_first_available_date_and_slot
    click_link 'No more to add'

    # Booking: Step 3 (visitors)
    expect(page).to have_content 'Visitor details'
    fill_in_visitor_step(visitor)
    click_button 'Continue'

    # Booking: Step 4 (summary)
    expect(page).to have_content 'Check your visit details'
    click_button 'Send visit request'

    # Redirect to visit show page
    expect(page).to have_content 'Visit request sent'
    expect(page).to have_content prisoner.prison

    # Fetch 'booking requested' email sent to prisoner
    # Tends to take ~ 2s locally for emails to be delivered and available via
    # API, so being generous to avoid false positives
    emails = retry_for(100, ->(mailbox) { mailbox.any? }) do
      Mailtrap.instance.search_messages(visitor.email)
    end
    # Since the email is unique only a single email should have been returned
    expect(emails.size).to eq(1)
    email = emails.first
    status_url = email.capybara.find_link('visit status page')[:href]

    # Status page
    visit status_url
    expect(page).to have_content 'Your visit is not booked yet'
    within('#cancel-visit-section') do
      find('.summary').click
    end

    check_yes_cancel
    click_button 'Cancel visit'
    expect(page).to have_content 'You cancelled this visit request'

    # Visit status page again and expect cancellation text
    visit status_url
    expect(page).to have_content 'You cancelled this visit request'

    # Give time to GA to do its indexing
    sleep(1)
    expect(google_analytics.public_url_count(status_url)).to be > (0)
  end
end
