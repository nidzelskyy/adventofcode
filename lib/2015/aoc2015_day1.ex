defmodule Aoc2015Day1 do
  @moduledoc false

  @input_file "inputs/2015/input1.txt"

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    parse_file()
    |> Enum.reduce(0, fn char, acc ->
      case char == "(" do
        true -> acc + 1
        false -> acc - 1
      end
    end)
  end

  def part_two() do
    {_, _, pos} =
      parse_file()
      |> Enum.reduce({0, 1, nil}, fn char, {acc, index, pos} ->
          upd_acc =
            case char == "(" do
              true -> acc + 1
              false -> acc - 1
            end
          case pos == nil && upd_acc == -1 do
            true -> {upd_acc, index + 1, index}
            false -> {upd_acc, index + 1, pos}
          end
        end)

    pos
  end

  def parse_file() do
    File.stream!(@input_file)
    |> Enum.fetch!(0)
    |> String.trim()
    |> String.codepoints
  end
end
