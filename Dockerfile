FROM ruby:2.4.2

ENV APP_HOME /app
WORKDIR $APP_HOME

# Install qt & xvfb (virtual X) for capybara-webkit
RUN apt-get update -y; true && apt-get install -y xvfb iceweasel netcat
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.18.0/geckodriver-v0.18.0-linux64.tar.gz \
         -O /tmp/geckodriver-v0.18.0-linux64.tar.gz && \
         tar -xvzf /tmp/geckodriver-v0.18.0-linux64.tar.gz && \
         mv geckodriver /usr/local/bin/ && \
         rm -f /tmp/geckodriver-v0.18.0-linux64.tar.gz

# Bundle before copying the app so that we make use of the Docker cache
ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development

COPY . .

# This is a hack for the container's broken locale settings and can be removed
# if a better solution is found
ENV RUBYOPT="-KU -E utf-8:utf-8"

ENTRYPOINT ["./run.sh"]
