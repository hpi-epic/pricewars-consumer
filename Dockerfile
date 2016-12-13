FROM ruby:2.3.2

RUN apt-get update -qq && apt-get install -y build-essential

# for a JS runtime
RUN apt-get install -y nodejs

ENV APP_HOME /consumer
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
