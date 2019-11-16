defmodule Str do
  @separator " "

  def pop_left(str, sep) do
    [ head | tail ] = String.split(str, sep)
    [head, Enum.join(tail, sep)]
  end

  def pop_left(str), do: pop_left(str, @separator)
end
