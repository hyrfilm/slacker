defmodule Str do
  @separator " "

  def pop_left(str, sep) do
    [ head | tail ] = String.split(str, sep)
    [head, Enum.join(tail, sep)]
  end

  def pop_left(str), do: pop_left(str, @separator)

  def parse(str) do
    # eg ":dude PRIVMSG #swecan :legalize it!"

    # first split the string into the parts that is prefixed by colons (eg ["dude PRIVMSG #swecan", "legalize it")
    [head | tail] = String.split(str, ":", trim: true)
    # then split the first part of those parts by space [eg "dude", "PRIVMSG", "#swecan"]
    heads = String.split(head, " ", trim: true)
    # combine and flatten them (eg "dude", "PRIVMSG", "#swecan", "legalize it")
    List.flatten([heads | tail])
  end
end
