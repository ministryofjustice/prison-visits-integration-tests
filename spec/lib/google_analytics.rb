# frozen_string_literal: true

require 'singleton'
require 'google/apis/analytics_v3'

class GoogleAnalytics
  include Singleton

  def public_url_count(url)
    ga_data = fetch_view_counts(public_view_id)

    parse_ga_counts(ga_data, URI.parse(url).path)
  end

  def pvb2_url_count(path)
    ga_data = fetch_view_counts(pvb2_view_id)

    parse_ga_counts(ga_data, path)
  end

  private

  def public_view_id
    ENV.fetch('GA_VIEW_ID_PVBPUBLIC')
  end

  def pvb2_view_id
    ENV.fetch('GA_VIEW_ID_PVB2')
  end

  def parse_ga_counts(ga_data, path)
    url_count_pair = ga_data.rows.find { |r| r.first == path }

    if url_count_pair
      url_count_pair[1].to_i
    else
      0
    end
  end

  def fetch_view_counts(view_id)
    analytics.get_realtime_data(
      view_id,
      'rt:pageviews',
      dimensions: 'rt:pagePath'
    )
  end

  def analytics
    @analytics ||=
      begin
        # This is needed because CircleCI escapes new lines
        ENV['GOOGLE_PRIVATE_KEY'] = ENV['GOOGLE_PRIVATE_KEY'].gsub('\\n', "\n")

        Google::Apis::AnalyticsV3::AnalyticsService.new.tap do |obj|
          obj.authorization = google_auth
        end
      end
  end

  def google_auth
    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      scope: 'https://www.googleapis.com/auth/analytics.readonly'
    )

    credentials.fetch_access_token!({})['access_token']
  end
end
