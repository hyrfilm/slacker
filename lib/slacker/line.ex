defmodule Line do
  @eol "\r\n"

  def parse(data) do
    data |> String.trim(@eol) |> Str.pop_left
  end

  def format(data) do
    data ++ @eol
  end
end
