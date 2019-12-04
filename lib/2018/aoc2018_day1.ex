defmodule Aoc2018Day1 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    parse_file()
    |> Enum.sum()
  end

  def part_two() do
    :second
  end

  def parse_file() do
    File.stream!("inputs/2018/input1.txt")
    |> Enum.map(fn x ->
      Integer.parse(x, 10)
      |> (fn {i, _} -> i end).()
    end)
  end
end
