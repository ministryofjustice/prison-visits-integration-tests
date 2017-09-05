require 'spec_helper'
require 'securerandom'

RSpec.feature 'booking a visit', type: :feature do
  let(:prisoner) do
    # Trivia: George Best spent 7 days imprisoned in Pentonville for driving
    # under alcohol and assault [wikipedia]
    Prisoner.new(
      'George', 'Best', Date.parse('1960-06-01'), 'A1410AE', 'Leicester'
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
    start_page = 'http://pvb-public:4000/en/request'

    # Fixing typo (checks nomis API is working): Step 0 (prisoner)
    visit start_page
    expect(page).to have_content 'Who are you visiting?'

    fill_in_prisoner_step(prisoner)

    # Booking: Step 1 (prisoner)
    fill_in 'Prisoner number', with: prisoner.number
    # click_button 'Continue'

    # # Booking: Step 2 (pick 1 slot)
    # expect(page).to have_css 'h1', text: 'When do you want to visit?'
    # select_first_available_date_and_slot
    # click_link 'No more to add'

    # # Booking: Step 3 (visitors)
    # expect(page).to have_content 'Visitor details'
    # fill_in_visitor_step(visitor)
    # click_button 'Continue'

    # # Booking: Step 4 (summary)
    # expect(page).to have_content 'Check your visit details'
    # click_button 'Send visit request'

    # # Redirect to visit show page
    # expect(page).to have_content 'Visit request sent'
  end
end
