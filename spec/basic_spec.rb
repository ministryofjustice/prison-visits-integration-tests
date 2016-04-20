require 'spec_helper'

describe 'booking a visit', type: :feature do
  let(:prisoner) do
    # Trivia: George Best spent 7 days imprisoned in Pentonville for driving
    # under alcohol and assault [wikipedia]
    Prisoner.new(
      'George', 'Best',
      Date.parse('1970-01-01'), # Actually 1946-05-22
      'A1234BC',
      'Pentonville'
    )
  end

  let(:visitor) do
    Visitor.new(
      'Peter', 'Sellers',
      Date.parse('1925-09-08'),
      'peter@example.com',
      '0123456789'
    )
  end

  it 'is possible to make a booking' do
    visit 'http://localhost:4000/en/request'

    expect(page).to have_content 'visiting'

    fill_in_prisoner_step(prisoner)
    click_button 'Continue'

    expect(page).to have_content 'Your details'

    fill_in_visitor_step(visitor)
    click_button 'Continue'

    expect(page).to have_content 'When do you want to visit?'

    fill_in_slots_step
    click_button 'Continue'

    expect(page).to have_content 'Check your request'

    click_button 'Send request'

    expect(page).to have_content 'Your request is being processed'
    expect(page).to have_content prisoner.prison
    expect(page).to have_content visitor.email

    # Helpful for debugging
    # save_screenshot('confirmation.png')
  end
end
