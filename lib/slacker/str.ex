defmodule Str do
  @separator " "
  @eol "\r\n"

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

  def format(list) do
    # pop first & last
    {head, list} = List.pop_at(list, 0)
    {tail, list} = List.pop_at(list, -1)

    # add colons & reassemble
    list = [col(head)] ++ list ++ [col(tail)]

    # remove eventual nil elements
    #list = Enum.filter(list, &!is_nil(&1))

    list
    |> Enum.filter(&!is_nil(&1)) # remove eventual nil elements
    |> Enum.join(" ")            # join list into string
    |> eol                       # append eol
  end

  defp col(str) when str==nil do
    nil
  end

  defp col(str) do
    ":#{str}"
  end

  defp eol(str) do
    "#{str}#{@eol}"
  end
end
