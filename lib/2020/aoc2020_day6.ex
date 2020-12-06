defmodule Aoc2020Day6 do
  @moduledoc false

  @quest_file "input6.txt"
  @test_quest_file "input6_test.txt"

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    parse_file(mode)
    |> Enum.reduce({[], []}, fn line, {acc, last_list}  ->
      if (String.length(line) == 0) do
        {acc ++ [Enum.uniq(last_list) |> Enum.count()], []}
      else
        {acc, last_list ++ String.codepoints(line)}
      end
    end)
    |> (fn {acc, _} -> acc end).()
    |> Enum.sum()
  end

  def part_two(mode) do
    parse_file(mode)
    |> Enum.reduce({[], []}, fn line, {acc, last_list}  ->
      if (String.length(line) == 0) do
        [hd | tl] = last_list
        count =
          Enum.reduce(tl, hd, fn next, acc ->
            acc -- (acc -- next)
          end)
          |> Enum.count()

        {acc ++ [count], []}
      else
        {acc, last_list ++ [String.codepoints(line)]}
      end
    end)
    |> (fn {acc, _} -> acc end).()
    |> Enum.sum()
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/2020/#{file_name(mode)}")
    |> Enum.map(fn str -> String.trim(str) end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
end
