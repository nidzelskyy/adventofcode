defmodule Aoc2015Day3 do
  @moduledoc false

  @input_file "inputs/2015/input3.txt"

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    {path, _} =
      parse_file()
      |> Enum.reduce({%{{0,0} => 1}, {0, 0}}, fn char, {path, {x, y}} ->
        {x2, y2} =
          case char do
            "^" -> {x + 1, y}
            ">" -> {x, y + 1}
            "v" -> {x - 1, y}
            "<" -> {x, y - 1}
          end
        upd_path =
          Map.put(path, {x2, y2}, Map.get(path, {x2, y2}, 0) + 1)

        {upd_path, {x2, y2}}
      end)

    path
    |> Enum.count()
  end

  def part_two() do
    {path, _, _, _} =
      parse_file()
      |> Enum.reduce({%{{0,0} => 2}, {0, 0}, {0, 0}, :santa}, fn char, {path, santa, robot, curr} ->
        {x, y} =
          case curr == :santa do
            true -> santa
            false -> robot
          end

        {x2, y2} =
          case char do
            "^" -> {x + 1, y}
            ">" -> {x, y + 1}
            "v" -> {x - 1, y}
            "<" -> {x, y - 1}
          end

        upd_path =
          Map.put(path, {x2, y2}, Map.get(path, {x2, y2}, 0) + 1)

        case curr == :santa do
          true -> {upd_path, {x2, y2}, robot, :robot}
          false -> {upd_path, santa, {x2, y2}, :santa}
        end
      end)

    path
    |> Enum.count()
  end

  def parse_file() do
    File.stream!(@input_file)
    |> Enum.fetch!(0)
    |> String.trim()
    |> String.codepoints
  end
end
