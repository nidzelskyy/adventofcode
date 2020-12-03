defmodule Aoc2020Day3 do
  @moduledoc false

  @quest_file "input3.txt"

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
  end

  def part_one() do
    parse_file()
    |> Enum.filter(fn {index, list} ->
        case index > 0 do
          true ->
            length = Enum.count(list)
            {x, _y} = {rem(index * 3, length), index}
            case Enum.fetch(list, x) do
              {:ok, char} ->
                char == "#"
              _ ->
                IO.inspect("Index #{x} error")
                false
            end
          false ->
            false
        end
      end)
    |> Enum.count()
  end

  def part_two() do
    input = parse_file()
    #[{x_coef, y_coef}]
    rules = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

    trees_count_list =
      rules
      |> Enum.reduce([], fn {x_coef, y_coef}, acc ->
          trees_count =
            Enum.filter(input, fn {index, list} ->
              case index > 0 && rem(index, y_coef) == 0 do
                true ->
                  length = Enum.count(list)
                  {x, _y} = {rem(div(index, y_coef) * x_coef, length), index}
                  case Enum.fetch(list, x) do
                    {:ok, char} ->
                      char == "#"
                    _ ->
                      IO.inspect("Index #{x} error")
                      false
                  end
                false ->
                  false
              end
            end)
            |> Enum.count()

          acc ++ [trees_count]
        end)
      |> IO.inspect()

    Enum.reduce(trees_count_list, 1, fn count, acc -> acc * count end)
  end

  def parse_file() do
    File.stream!("inputs/2020/#{@quest_file}")
    |> Stream.with_index()
    |> Enum.map(fn {line, index} ->
      list = String.trim(line) |> String.codepoints()
      {index, list}
    end)
    |> Map.new()
    |> Enum.sort()
  end
end
