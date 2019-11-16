defmodule Format do
  @separator " "

  def pop_left(str, sep) do
    [ head | tail ] = String.split(str, sep)
    [head, Enum.join(tail, sep)]
  end

  def pop_left(str), do: left_pop(str, @separator)
end
