require 'spec_helper'
require 'securerandom'
require 'faker'

RSpec.feature 'process a booking', type: :feature do
  let(:prisoner_first_name) { Faker::Name.first_name }
  let(:prisoner_last_name) { Faker::Name.last_name }

  let(:prisoner) do
    Prisoner.new(
      prisoner_first_name, prisoner_last_name,
      Date.parse('1970-01-01'), # Actually 1946-05-22
      'A1234BC',
      'Pentonville'
    )
  end

  let(:visitor) do
    Visitor.new(
      'Peter', 'Sellers',
      Date.parse('1925-09-08'),
      "#{SecureRandom.uuid}@email.prisonvisits.service.gov.uk",
      '0123456789'
    )
  end

  let(:prison_email) { 'socialvisits.pentonville@hmps.gsi.gov.uk' }

  before do
    make_booking(prisoner, visitor)
  end

  scenario 'accept booking, then visitor cancels' do
    prison_start_page = ENV.fetch('PRISON_START_PAGE')

    visit prison_start_page
    click_link 'Pentonville'

    # The most recent requested visit
    within 'tbody tr:last-child' do
      click_link 'Process booking'
    end
    expect(page).to have_content(prisoner_first_name)
    expect(page).to have_content(prisoner_last_name)

    expect(page).to have_content('Peter')
    expect(page).to have_content('Sellers')

    find('#booking_response_selection_slot_0').click
    fill_in 'Reference number', with: '12345678'

    click_button 'Send email'

    # The step below the sleep fails interminently, attempt to fix this with a
    # hard sleep as I have already increased the retries from 10s to 20s.
    sleep(1)
    confirmation_email = retry_for(20, ->(email) { email }) {
      # Log how many messages the API is returning to help debugging intermitent
      # issues.
      STDOUT.puts "Matched messages: #{Mailtrap.instance.search_messages(visitor.email)}"
      Mailtrap.instance.search_messages(visitor.email).find do |email|
        email.subject =~ /^Visit confirmed/
      end
    }

    cancel_url = email_link_href(confirmation_email, 'you can cancel this visit')
    visit cancel_url
    expect(page).to have_content('Your visit has been confirmed')
    check 'Yes, I want to cancel this visit'
    click_button 'Cancel visit'
    expect(page).to have_content('You cancelled this visit')

    retry_for(10, ->(email) { email }) {
      Mailtrap.instance.search_messages(prison_email).find do |email|
        email.subject =~ /\ACANCELLED: Visit for #{prisoner_first_name} #{prisoner_last_name}/
      end
    }
  end
end
