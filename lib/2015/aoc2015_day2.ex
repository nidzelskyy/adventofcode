defmodule Aoc2015Day2 do
  @moduledoc false

  @input_file "inputs/2015/input2.txt"

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    parse_file()
    |> Enum.reduce(0, fn {[l, w, h], _}, acc ->
      l = String.to_integer(l)
      w = String.to_integer(w)
      h = String.to_integer(h)

      first  = l * w
      second = w * h
      third  = h * l

      min  = Enum.min([first, second, third])

      acc = acc +  2 * first + 2 * second + 2 * third + min
    end)
  end

  def part_two() do
    parse_file()
    |> Enum.reduce(0, fn {[l, w, h], _}, acc ->
        l = String.to_integer(l)
        w = String.to_integer(w)
        h = String.to_integer(h)

        [first, second, _] = Enum.sort([l, w, h])

        ribbon = 2 * first + 2 * second
        bow = l * w * h

        ribbon = ribbon + bow

        acc + ribbon
      end)
  end

  def parse_file() do
    File.stream!(@input_file)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "x"))
    |> Enum.with_index
  end
end
