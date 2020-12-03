defmodule Aoc2020Day3 do
  @moduledoc false

  @quest_file "input3.txt"
  @test_quest_file "input3_test.txt"

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    input = parse_file(mode)
    #[{x_coef, y_coef}]
    rules = [{3, 1}]

    calculate_trees_by_rules(rules, input)
    |> Enum.reduce(1, fn count, acc -> acc * count end)
  end

  def part_two(mode) do
    input = parse_file(mode)
    #[{x_coef, y_coef}]
    rules = [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}]

    calculate_trees_by_rules(rules, input)
    |> Enum.reduce(1, fn count, acc -> acc * count end)
  end

  def calculate_trees_by_rules(rules, input) do
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
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/2020/#{file_name(mode)}")
    |> Stream.with_index()
    |> Enum.map(fn {line, index} ->
      list = String.trim(line) |> String.codepoints()
      {index, list}
    end)
    |> Map.new()
    |> Enum.sort()
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
end
