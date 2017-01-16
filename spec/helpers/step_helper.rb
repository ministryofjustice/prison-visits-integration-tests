Prisoner = Struct.new(:first_name, :last_name, :dob, :number, :prison)
Visitor = Struct.new(:first_name, :last_name, :dob, :email, :phone)

def make_booking(prisoner, visitor)
  start_page = ENV.fetch('START_PAGE')

  visit start_page
  fill_in_prisoner_step(prisoner)
  click_button 'Continue'
  fill_in_slots_step
  click_button 'Continue'
  fill_in_visitor_step(visitor)
  click_button 'Continue'
  expect(page).to have_content 'Check your request'

  click_button 'Send request'
end

def fill_in_prisoner_step(prisoner)
  fill_in 'Prisoner first name', with: prisoner.first_name
  fill_in 'Prisoner last name', with: prisoner.last_name
  fill_in 'Day', with: prisoner.dob.day.to_s
  fill_in 'Month', with: prisoner.dob.month.to_s
  fill_in 'Year', with: prisoner.dob.year.to_s
  fill_in 'Prisoner number', with: prisoner.number
  select_prison prisoner.prison
end

def select_prison(name)
  find('input[data-input-name="prisoner_step[prison_id]"]')
    .set(name)
end

def fill_in_visitor_step(visitor)
  fill_in 'First name', with: visitor.first_name
  fill_in 'Last name', with: visitor.last_name
  fill_in 'Day', with: visitor.dob.day.to_s
  fill_in 'Month', with: visitor.dob.month.to_s
  fill_in 'Year', with: visitor.dob.year.to_s
  fill_in 'Email address', with: visitor.email
  fill_in 'Phone number', with: visitor.phone
end

def fill_in_slots_step
  available_dates_on_calendar.take(3).each do |calendar_date|
    calendar_date.click
    click_first_available_time
  end
end

def available_dates_on_calendar
  all('.BookingCalendar-date--bookable')
end

def click_first_available_time
  all('.SlotPicker-label').first.click
end

def email_link_href(email, link_text)
  email.capybara.find_link(link_text).native.attributes['href'].value
end
