require 'spec_helper'
require 'securerandom'
require 'faker'

RSpec.feature 'booking a visit', type: :feature do
  INVALID_PRISONER_NUMBER = 'Z0000AA'
  PRISON = 'Leeds'

  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:date_of_birth) { Faker::Date.birthday }

  let(:invalid_prisoner) do
    Prisoner.new(
      first_name,
      last_name,
      date_of_birth,
      INVALID_PRISONER_NUMBER,
      PRISON
    )
  end

  scenario 'for a prisoner that does not exist' do
    start_page = ENV.fetch('START_PAGE')

    visit start_page

    expect(page).to have_content 'Who are you visiting?'

    fill_in_prisoner_step(invalid_prisoner)
    fill_in 'Prisoner number', with: INVALID_PRISONER_NUMBER

    click_button 'Continue'

    expect(page).to have_css(
      'fieldset span.error-message',
      text: 'No prisoner matches the details you’ve supplied, please ask the prisoner to check your details are correct',
      visible: false
    )
  end
end
