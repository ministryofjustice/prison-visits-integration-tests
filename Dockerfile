FROM ruby:2.4.1

WORKDIR /app

# Install qt & xvfb (virtual X) for capybara-webkit
RUN apt-get update -y; true && apt-get install -y xvfb iceweasel

# Bundle before copying the app so that we make use of the Docker cache
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development

COPY . .

# This is a hack for the container's broken locale settings and can be removed
# if a better solution is found
ENV RUBYOPT="-KU -E utf-8:utf-8"

ENTRYPOINT ["./run.sh"]
