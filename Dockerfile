FROM ruby:2.3.2

ENV APP_HOME /consumer
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME
RUN bundle install

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
