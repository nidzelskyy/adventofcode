defmodule Aoc2019Day4 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
  end

  def part_one() do
    Enum.filter(158126..624574, fn x ->
      [a,b,c,d,e,f] = digits =
        String.codepoints("#{x}")
        |> Enum.map(& String.to_integer(&1))

      digits == Enum.sort(digits) && (a == b || b == c || c == d || d == e || e == f)
    end)
    |> length()
  end

  def part_two() do
    Enum.filter(158126..624574, fn x ->
      [a,b,c,d,e,f] = digits =
        String.codepoints("#{x}")
        |> Enum.map(& String.to_integer(&1))

      digits == Enum.sort(digits) && (a == b || b == c || c == d || d == e || e == f) && (
        (a == b && b != c) ||
          (b == c && a != b && c != d) ||
          (c == d && b != c && d != e) ||
          (d == e && c != d && e != f) ||
          (e == f && e != d)
        )
    end)
    |> length()
  end
end
