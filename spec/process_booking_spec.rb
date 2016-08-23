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
      'Swansea'
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

  let(:prison_email) { 'socialvisits.swansea@hmps.gsi.gov.uk' }

  before do
    make_booking(prisoner, visitor)
  end

  scenario 'accept booking, then visitor cancels' do
    prison_start_page = ENV.fetch('PRISON_START_PAGE')

    visit prison_start_page

    fill_in 'Email', with: ENV.fetch('EMAIL')
    fill_in 'Password', with: ENV.fetch('PASSWORD')
    click_button 'Sign in'

    # The most recent requested visit
    all('table:last-child tbody tr:not(.hidden-row)').last.click_link('View')

    expect(page).to have_content(prisoner_first_name)
    expect(page).to have_content(prisoner_last_name)

    expect(page).to have_content('Peter')
    expect(page).to have_content('Sellers')

    find('#booking_response_selection_slot_0').click
    fill_in 'Reference number', with: '12345678'

    click_button 'Send email'

    expect(page).to have_content('Thank you for processing the visit')

    confirmation_email = retry_for(120, ->(email) { email }) {
      visitor_emails = Mailtrap.instance.search_messages(visitor.email)

      # Log messages returned by the API to aid debugging
      puts "Matched email subjects: #{visitor_emails.map(&:subject)}"

      visitor_emails.find { |email| email.subject =~ /^Visit confirmed/ }
    }

    cancel_url = email_link_href(confirmation_email, 'you can cancel this visit')
    visit cancel_url
    expect(page).to have_content('Your visit has been confirmed')
    check 'Yes, I want to cancel this visit'
    click_button 'Cancel visit'
    expect(page).to have_content('Your visit is cancelled')

    retry_for(10, ->(email) { email }) {
      Mailtrap.instance.search_messages(prison_email).find do |email|
        email.subject =~ /\ACANCELLED: Visit for #{prisoner_first_name} #{prisoner_last_name}/
      end
    }
  end
end
