class MailtrapEmail

  attr_reader :to_name, :to_email, :subject, :txt_path, :html_path

  def initialize(to_name:, to_email:, subject:, txt_path:, html_path:)
    self.to_name = to_name
    self.to_email = to_email
    self.subject = subject
    self.txt_path = txt_path
    self.html_path = html_path
  end

  def capybara
    Capybara.string(get_message_body)
  end

  private
  attr_writer :to_name, :to_email, :subject, :txt_path, :html_path

  def get_message_body
    Mailtrap.instance.message_body(html_path)
  end
end
