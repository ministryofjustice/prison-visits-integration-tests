require 'spec_helper'
require 'securerandom'
require 'faker'

RSpec.feature 'process a booking', type: :feature do
  let(:prisoner_first_name) { Faker::Name.first_name }
  let(:prisoner_last_name) { Faker::Name.last_name }

  let(:prisoner) do
    Prisoner.new(
      prisoner_first_name, prisoner_last_name,
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

  before do
    make_booking(prisoner, visitor)
  end

  scenario 'accept booking, then visitor cancels' do
    prison_start_page = ENV.fetch('PRISON_START_PAGE')

    # Visiting prison inbox redirects to Sign On page
    visit prison_start_page
    expect(page).to have_content('Sign On')
    fill_in 'Email', with: ENV.fetch('SSO_EMAIL')
    fill_in 'Password', with: ENV.fetch('SSO_PASSWORD')
    click_button 'Sign in'

    select ENV['PRISON'], from: 'estate_ids', visible: false
    click_button 'Update'
    # The most recent requested visit
    all('tr:not(.hidden-row)').last.click_link('View')

    expect(page).to have_content(prisoner_first_name)
    expect(page).to have_content(prisoner_last_name)

    expect(page).to have_content('Peter')
    expect(page).to have_content('Sellers')

    # NOMIS CHECKS
    expect(page).to have_css('.notice', text: 'The prisoner date of birth and number have been verified.')
    expect(page).to have_css('.column-one-quarter', text: "Prisoner D.O.B #{prisoner.dob.strftime('%d/%m/%Y')} Verified")
    expect(page).to have_css('.column-one-quarter', text: "Prisoner no. #{prisoner.number} Verified")

    within '.choose-date' do
      all('label.date-box').first.click
    end

    fill_in 'Reference number', with: '12345678'

    click_button 'Process'

    expect(page).to have_content('Thank you for processing the visit')

    confirmation_email = retry_for(180, ->(email) { email }) {
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
  end
end
