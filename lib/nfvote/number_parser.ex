defmodule Kandires.NumberParser do
  def parse_int(str) do
    str
    |> String.reverse()
    |> do_parse_int(0, [])
  end

  def do_parse_int(<<char::utf8>> <> rest, index, cache) do
    new_part = ascii_to_digit(char) * round(:math.pow(10, index))

    do_parse_int(
      rest,
      index + 1,
      [new_part | cache]
    )
  end

  def do_parse_int("", _, cache) do
    cache
    |> Enum.reduce(0, &Kernel.+/2)
  end

  @float_regex ~r/^(?<int>\d+)(\.(?<dec>\d+))?$/

  def parse_float(str) do
    %{"int" => int_str, "dec" => decimal_str} = Regex.named_captures(@float_regex, str)

    decimal_length = String.length(decimal_str)

    parse_int(int_str) + parse_int(decimal_str) * :math.pow(10, -decimal_length)
  end

  def ascii_to_digit(ascii) when ascii >= 48 and ascii < 58 do
    ascii - 48
  end

  def ascii_to_digit(_), do: raise(ArgumentError)
end
