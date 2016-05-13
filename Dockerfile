FROM ruby:2.3.1

WORKDIR /app

# Install phantomjs
RUN set -ex \
	&& wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2 \
	&& tar -xvf phantomjs-1.9.8-linux-x86_64.tar.bz2 \
	&& mv phantomjs-1.9.8-linux-x86_64/bin/phantomjs /usr/local/bin/. \
	&& rm -rf phantomjs-1.9.8-linux-x86_64 \
	&& rm phantomjs-1.9.8-linux-x86_64.tar.bz2

# Bundle before copying the app so that we make use of the Docker cache
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development

COPY . .

# This is a hack for the container's broken locale settings and can be removed 
# if a better solution is found
ENV RUBYOPT="-KU -E utf-8:utf-8"

CMD ["rspec"]
