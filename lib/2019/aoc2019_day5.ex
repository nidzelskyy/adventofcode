defmodule Aoc2019Day5 do
  @moduledoc false

  @position_mode 0
  @immediate_mode 1

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    parse_file()
    |> Intcode.run()
    "See the result in console!"
  end

  def part_two() do
    parse_file()
    |> Intcode.run()
    "See the result in console!"
  end

  def parse_file() do
    File.read!("inputs/2019/input5.txt")
    |> String.split(~r/\,/)
    |> Enum.map(fn x -> Integer.parse(x, 10) |> (fn {i, _} -> i end).() end)
  end
end
