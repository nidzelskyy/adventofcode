defmodule Aoc2019Day1 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
  end

  def part_one() do
    parse_file()
    |> Enum.reduce(0, fn x, acc -> x + acc end)
  end

  def part_two() do
    parse_file()
    |> Enum.reduce([], fn x, acc -> recursive_mass_sum(x, acc) end)
    |> Enum.reduce(0, fn x, acc -> x + acc end)
  end

  def parse_file() do
    File.stream!("inputs/2019/input.txt")
    |> Enum.map(fn x ->
      Integer.parse(x, 10)
      |> (fn {i, _} -> div(i, 3) - 2 end).()
    end)
  end

  def recursive_mass_sum(mass, acc) when mass <= 0 do
    acc
  end
  def recursive_mass_sum(mass, acc) do
    recursive_mass_sum(div(mass, 3) - 2, [mass | acc])
  end

end
