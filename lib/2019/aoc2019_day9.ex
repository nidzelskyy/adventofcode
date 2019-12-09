defmodule Aoc2019Day9 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end
  #Aoc2019Day9.part_one
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
    File.read!("inputs/2019/input9.txt")
    |> String.split(~r/\,/)
    |> Enum.map(fn x -> Integer.parse(x, 10) |> (fn {i, _} -> i end).() end)
  end
end
