require_relative '../spec_helper'
require 'securerandom'
require 'faker'

RSpec.feature 'process a booking', type: :feature do
  let(:prisoner_first_name) { Faker::Name.first_name }
  let(:prisoner_last_name)  { Faker::Name.last_name }

  let(:visitor_first_name) { ENV.fetch('LEAD_VISITOR_FIRST_NAME', 'Peter') }
  let(:visitor_last_name)  { ENV.fetch('LEAD_VISITOR_LAST_NAME', 'Selers') }
  let(:visitor_dob)        { ENV.fetch('LEAD_VISITOR_DOB', '1925-09-08') }

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
      visitor_first_name,
      visitor_last_name,
      Date.parse(visitor_dob),
      "#{SecureRandom.uuid}@email.prisonvisits.service.gov.uk",
      '079 00112233'
    )
  end

  describe 'accept booking' do

    context 'with book to nomis disabled' do
      scenario 'then visitor cancels' do
        make_booking(prisoner, visitor)

        login_as_staff
        select_prison_for_processing
        expect(page).to have_css('tr:not(.hidden-row)')

        # The most recent requested visit
        all('tr:not(.hidden-row)').last.click_link('View')

        expect(page).to have_css('.bold-small', text: [prisoner_first_name, prisoner_last_name].join(' '))
        expect(page).to have_css('.name', text: "#{visitor_first_name} #{visitor_last_name}")

        # NOMIS CHECKS
        expect(page).to have_css('.notice', text: 'The prisoner date of birth, prisoner number and prison name have been verified.')
        expect(page).to have_css('.column-one-quarter', text: "Prisoner D.O.B #{prisoner.dob.strftime('%d/%m/%Y')} NOMIS verified")
        expect(page).to have_css('.column-one-quarter', text: "Prisoner no. #{prisoner.number} NOMIS verified")

        within '.choose-date' do
          first('label.date-box__label').click
        end
        fill_in 'Reference number', with: '12345678'

        within '.visitor-contact-list' do
          all('option:not([disabled]')[1].select_option
        end

        click_button 'Process'

        expect(page).to have_css('p.notification', text: 'Thank you for processing the visit')

        confirmation_email = retry_for(180, ->(email) { email }) do
          visitor_emails = Mailtrap.instance.search_messages(visitor.email)

          visitor_emails.find { |email| email.subject =~ /^Visit confirmed/ }
        end

        cancel_url = email_link_href(confirmation_email, 'you can cancel this visit')
        visit cancel_url
        expect(page).to have_content('Your visit has been confirmed')
        check_yes_cancel
        click_button 'Cancel visit'
        expect(page).to have_content('Your visit is cancelled')

        # Give time to GA to do its indexing
        sleep(1)
        expect(google_analytics.pvb2_url_count('/visit-requested')).to be > (0)
      end
    end
  end

  describe 'clean up inboxes' do
    before do
      login_as_staff
      select_prison_for_processing
    end

    scenario 'Clean All of the Cancelled visits' do

      while submit_button = page.first('table tbody td form input:not([disabled])[type="submit"]')
        submit_button.click
        expect(page).to have_css('h3.heading-medium', text: 'Cancellations')
      end
    end

    scenario 'Clean All of the requested visits' do

      while view_link = page.first('table tbody td[aria-label="Actions"] a')
        view_link.click
        choose('None of the chosen times are available')
        click_button 'Process'
        expect(page).to have_css('h1.heading-large', text: 'Requested visits')
      end
    end
  end
end
