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

  describe 'accept booking' do
    before do
      make_booking(prisoner, visitor)

      login_as_staff
      select_prison_for_processing
    end

    scenario 'then visitor cancels' do

      # The most recent requested visit
      all('tr:not(.hidden-row)').last.click_link('View')

      expect(page).to have_css('.bold-small', text: [prisoner_first_name, prisoner_last_name].join(' '))
      expect(page).to have_css('.font-xsmall', text: 'Peter Sellers')

      # NOMIS CHECKS
      expect(page).to have_css('.notice', text: 'The prisoner date of birth and number have been verified.')
      expect(page).to have_css('.column-one-quarter', text: "Prisoner D.O.B #{prisoner.dob.strftime('%d/%m/%Y')} Verified")
      expect(page).to have_css('.column-one-quarter', text: "Prisoner no. #{prisoner.number} Verified")

      within '.choose-date' do
        all('label.date-box').first.click
      end

      fill_in 'Reference number', with: '12345678'

      click_button 'Process'

      expect(page).to have_css('p.notification', text: 'Thank you for processing the visit')

      confirmation_email = retry_for(180, ->(email) { email }) {
        visitor_emails = Mailtrap.instance.search_messages(visitor.email)

        # Log messages returned by the API to aid debugging
        puts "Matched email subjects: #{visitor_emails.map(&:subject)}"

        visitor_emails.find { |email| email.subject =~ /^Visit confirmed/ }
      }

      cancel_url = email_link_href(confirmation_email, 'you can cancel this visit')
      visit cancel_url
      expect(page).to have_content('Your visit has been confirmed')
      check_yes_cancel
      click_button 'Cancel visit'
      expect(page).to have_content('Your visit is cancelled')
    end
  end

  describe 'clean up inboxes' do
    before do
      make_booking(prisoner, visitor)

      login_as_staff
      select_prison_for_processing
    end

    scenario 'Clean All of the Cancelled visits' do
      page.all('table tbody td form input[type="commit"]').each do |submit_button|
        click_button submit_button
        expect(page).to have_css('h3.heading-medium', text: 'Cancellations')
      end
    end
  end
end
