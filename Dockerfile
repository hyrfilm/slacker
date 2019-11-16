FROM elixir
COPY . /app
WORKDIR /app
RUN mix compile
WORKDIR _build/dev/lib/slacker/ebin
CMD ["/bin/bash"]