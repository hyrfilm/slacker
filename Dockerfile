FROM elixir:1.9.4-alpine
COPY . /app
WORKDIR /app
RUN mix compile
RUN mix test
CMD ["mix", "run"]
