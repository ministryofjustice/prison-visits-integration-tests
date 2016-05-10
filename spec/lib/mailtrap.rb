require 'excon'
require 'json'

class Mailtrap
  class << self
    def instance
      @instance ||= begin
        api_token = ENV.fetch('MAILTRAP_API_TOKEN')
        new(api_token: api_token)
      end
    end
  end

  Email = Struct.new(:to_name, :to_email, :subject, :text_body, :html_body) do
    def self.parse(hash)
      new(*hash.values_at('to_name', 'to_email', 'subject', 'text_body', 'html_body'))
    end

    def capybara
      Capybara.string(html_body)
    end
  end

  def initialize(api_token:)
    @connection = Excon.new('https://mailtrap.io/', {
      persistent: true,
      headers: {
        'Api-Token' => api_token
      },
    })
  end

  def inbox_messages(query = {})
    response = @connection.get({
      path: '/api/v1/inboxes/106414/messages',
      query: query,
      expects: [200]
    })
    messages = JSON.parse(response.body)
    emails = messages.map { |e| Email.parse(e) }
  end

  # The search API is rather limited: AFAICT it's something like a prefix match
  # on to, from, subject
  def search_messages(search)
    inbox_messages(search: search)
  end

  # This is not supported by the API, so this is inefficient!
  def search_body(search_regexp)
    emails = inbox_messages
    emails.find_all { |e| e.text_body =~ search_regexp }
  end
end

if __FILE__ == $0
  maildrop = Mailtrap.instance
  emails = maildrop.search_messages('Visit')
  puts emails.map(&:subject)
end
