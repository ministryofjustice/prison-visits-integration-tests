require_relative '../spec_helper'
require 'pry'
require 'securerandom'

RSpec.feature 'booking a visit', type: :feature do

  INVALID_PRISONER_NUMBER = 'Z0000AA'.freeze

  let(:invalid_prisoner) do
    Prisoner.new(
        'Bobby',
        'Brown',
        Date.parse('1980-04-03'),
        INVALID_PRISONER_NUMBER,
        'Leeds'
    )
  end

  scenario 'for a prisoner that does not exist' do
    start_page = 'http://localhost:4000'

    visit start_page

    expect(page).to have_content 'Who are you visiting?'

    fill_in_prisoner_step(invalid_prisoner)
    fill_in 'Prisoner number', with: INVALID_PRISONER_NUMBER
    click_button 'Continue'

    expect(page).to have_css(
                        'fieldset span.error-message',
                        text: 'No prisoner matches the details you’ve supplied, please ask the prisoner to check your details are correct',
                        visible: false)
  end
end