FROM ruby:2.2.5

RUN apt-get update && \
    apt-get install -y libruby aspell-es aspell-en libxml2-dev \
                       libxslt1-dev libmagickcore-dev libmagickwand-dev imagemagick \
                       zlib1g-dev build-essential \
                       libqtwebkit-dev libreadline-dev libsqlite3-dev libssl-dev \
                       libffi-dev

ENV app /usr/src/app

# Create app directory
RUN mkdir -p $app
WORKDIR $app

# Bundle app source
COPY . $app

# Install app dependencies
RUN bundle install

# dumb-init
ADD dumb-init_1.2.0 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "bundle", "exec", "rails", "server" ]
