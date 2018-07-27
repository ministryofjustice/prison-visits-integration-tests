Prisoner = Struct.new(:first_name, :last_name, :dob, :number, :prison)
Visitor = Struct.new(:first_name, :last_name, :dob, :email, :phone)

def prison_start_page
  @prison_start_page ||= ENV.fetch('PRISON_START_PAGE') do
    raise ArgumentError.new('Please provide a PRISON_START_PAGE environment variable')
  end
end

def login_as_staff
  # Visiting prison inbox redirects to Sign On page
  visit prison_start_page

  return if page.all('form input[type="submit"][value="Sign out"]').any?

  expect(page).to have_css('a.header__menu__proposition-name',
                           text: 'Ministry of Justice Sign On')

  fill_in 'Email',    with: ENV.fetch('SSO_EMAIL')
  fill_in 'Password', with: ENV.fetch('SSO_PASSWORD')
  click_button 'Sign in'
end

def select_prison_for_processing
  expect(page).to have_css('#estate_ids_chosen li.search-field')
  first('#estate_ids_chosen li.search-field input.chosen-search-input').click
  prison_li = all('.chosen-drop ul.chosen-results li').detect do |li|
    li.text == ENV.fetch('PRISON') do
      raise ArgumentError.new('Please provide a PRISON environment variable')
    end
  end

  prison_li.click
  click_button 'Update'
end

def make_booking(prisoner, visitor)
  start_page = ENV.fetch('START_PAGE')

  visit start_page
  fill_in_prisoner_step(prisoner)
  fill_in 'Prisoner number', with: prisoner.number
  fill_in 'Prison name', with: ENV.fetch('PRISON')
  page.execute_script('$("input[value=\"Continue\"]").trigger("click")')

  expect(page).to have_css('h1', text: 'When do you want to visit?')
  select_first_available_date_and_slot
  click_link 'No more to add'
  fill_in_visitor_step(visitor)
  click_button 'Continue'
  click_button 'Send visit request'
  expect(page).to have_content 'Visit request sent'
end

def fill_in_prisoner_step(prisoner)
  fill_in 'Prisoner first name', with: prisoner.first_name
  fill_in 'Prisoner last name',  with: prisoner.last_name
  fill_in 'Day',                 with: prisoner.dob.day.to_s
  fill_in 'Month',               with: prisoner.dob.month.to_s
  fill_in 'Year',                with: prisoner.dob.year.to_s
  select_prison prisoner.prison
end

def select_prison(name)
  fill_in 'Prison name', with: name
  find('.ui-autocomplete a', text: name).click
end

def fill_in_visitor_step(visitor)
  fill_in 'First name',             with: visitor.first_name
  fill_in 'Last name',              with: visitor.last_name
  fill_in 'Day',                    with: visitor.dob.day.to_s
  fill_in 'Month',                  with: visitor.dob.month.to_s
  fill_in 'Year',                   with: visitor.dob.year.to_s
  fill_in 'Email address',          with: visitor.email
  fill_in 'Confirm email address',  with: visitor.email
  fill_in 'Phone number',           with: visitor.phone
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

def select_first_available_date_and_slot
  first('table.booking-calendar td.available a').click
  first('#js-slotAvailability label').click
end

def check_yes_cancel
  check 'Yes, I want to cancel this visit', visible: false
end
