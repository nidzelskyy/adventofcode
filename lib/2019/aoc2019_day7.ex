defmodule Aoc2019Day7 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    input = parse_file()
    elements = 0..4
    comb = for a <- elements, b <- elements, c <- elements, d <- elements, e <- elements, a != b && a != c && a != d && a != e && b != c && b != d && b != e && c != d && c != e && d != e, do: [a, b, c, d, e]
    Enum.reduce(comb, [], fn x, acc ->
      res = Intcode.run_cycle_program(input, 1, x)
      [res | acc]
    end)
    |> Enum.max()
  end

  def part_two() do
    input = parse_file()
    elements = 5..9
    comb = for a <- elements, b <- elements, c <- elements, d <- elements, e <- elements, a != b && a != c && a != d && a != e && b != c && b != d && b != e && c != d && c != e && d != e, do: [a, b, c, d, e]
    Enum.reduce(comb, [], fn x, acc ->
      res = Intcode.run_cycle_program(input, 1, x)
      [res | acc]
    end)
    |> Enum.max()
  end

  def parse_file() do
    File.read!("inputs/2019/input7.txt")
    |> String.split(~r/\,/)
    |> Enum.map(fn x -> Integer.parse(x, 10) |> (fn {i, _} -> i end).() end)
  end
end
