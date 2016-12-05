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

    if ENV['PUBLIC_PRISONER_CHECK'] == 'true'
      fill_in_prisoner_step(prisoner)
      fill_in 'Prisoner number', with: 'Z0000AA'
      click_button 'Continue'
      expect(page).to have_css('fieldset', text: /No prisoner matches the details you’ve supplied, please ask the prisoner to check your details are correct/)
    end

    # Booking: Step 1 (prisoner)
    fill_in_prisoner_step(prisoner)
    click_button 'Continue'

    # Booking: Step 2 (visitors)
    expect(page).to have_content 'Your details'
    fill_in_visitor_step(visitor)
    click_button 'Continue'

    # Booking: Step 3 (pick slots)
    expect(page).to have_content 'When do you want to visit?'
    fill_in_slots_step
    click_button 'Continue'

    # Booking: Step 4 (summary)
    expect(page).to have_content 'Check your request'
    click_button 'Send request'

    # Redirect to visit show page
    expect(page).to have_content 'Your request is being processed'
    expect(page).to have_content prisoner.prison

    # Fetch 'booking requested' email sent to prisoner
    # Tends to take ~ 2s locally for emails to be delivered and available via
    # API, so being generous to avoid false positives
    emails = retry_for(10, ->(emails) { emails.any? }) {
      Mailtrap.instance.search_messages(visitor.email)
    }
    # Since the email is unique only a single email should have been returned
    expect(emails.size).to eq(1)
    email = emails.first
    status_url = email.capybara.find_link('visit status page')[:href]

    # Extract visit_id for use later
    visit_id = status_url.split('/').last

    # Status page
    visit status_url
    expect(page).to have_content 'Your visit is not booked yet'
    check 'Yes, I want to cancel this visit'
    click_button 'Cancel visit'
    expect(page).to have_content 'You cancelled this visit request'

    # Visit status page again and expect cancellation text
    visit status_url
    expect(page).to have_content 'You cancelled this visit request'
  end
end
