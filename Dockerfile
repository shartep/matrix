FROM ruby:2.6

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /app

RUN gem install bundler
COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY . /app/
RUN cp .env.example .env

CMD bundle exec ruby app.rb -u neo -p knok_knok
