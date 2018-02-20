FROM ruby:2.4.3

ENV APP_HOME /app
ENV FIREFOX_VERSION 57.0.4
WORKDIR $APP_HOME

# Install qt & xvfb (virtual X) for capybara-webkit
RUN apt-get update -y; true && apt-get install -y libgtk-3-0 ibgtk3.0-cil-dev libasound2 libasound2 libdbus-glib-1-2 libdbus-1-3  xvfb
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.19.1/geckodriver-v0.19.1-linux64.tar.gz \
         -O /tmp/geckodriver-v0.19.1-linux64.tar.gz && \
         tar -xvzf /tmp/geckodriver-v0.19.1-linux64.tar.gz && \
         mv geckodriver /usr/local/bin/ && \
         rm -f /tmp/geckodriver-v0.19.1-linux64.tar.gz

RUN wget -L https://ftp.mozilla.org/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 -O firefox-$FIREFOX_VERSION.tar.bz2 && \
          tar xjf firefox-$FIREFOX_VERSION.tar.bz2 && \
          mv firefox /opt/ && \
          ln -sf /opt/firefox/firefox /usr/bin/firefox

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
