docker build --tag elixir-shell .
docker run -p 127.0.0.1:6667:6667 -it --rm elixir-shell