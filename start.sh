docker build --tag elixir-shell .
docker run -p 0.0.0.0:6667:6667 -it --rm elixir-shell