FROM ruby:2.3-onbuild

RUN mkdir -p /app
WORKDIR /app

COPY . /app

CMD ["bundle", "exec", "ruby", "main.rb"]
