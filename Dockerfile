FROM elixir
COPY . /app
WORKDIR /app
RUN mix compile
RUN mix test
CMD ["mix", "run"]
