defmodule Aoc2015Day5 do
  @moduledoc false

  @year 2015
  @quest_file "input5.txt"
  @test_quest_file "input5_test.txt"

  #Aoc2015Day5.run(:test)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  def part_one(mode) do
    parse_file(mode)
    |> Stream.filter(&filter_by_vowels/1)
    |> Stream.filter(&filter_by_double_char/1)
    |> Stream.filter(&filter_by_bad_combo/1)
    |> Enum.count()
  end

  def part_two(mode) do
    :second
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/#{@year}/#{file_name(mode)}")
    |> Stream.with_index()
    |> Stream.map(fn {line, index} -> {index, String.trim(line) |> String.codepoints()} end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def filter_by_vowels({_, string_list}) do
      string_list
      |> Enum.filter(fn x -> x in ["a", "e", "i", "o", "u"] end)
      |> (fn list_vowels -> Enum.count(list_vowels) > 2 end).()
  end

  def filter_by_double_char({_, string_list}) do
    map = codepoints_to_map(string_list)

    Enum.reduce(map, false, fn {index, codepoint}, acc -> acc || Map.get(map, index + 1) == codepoint end)
  end

  def filter_by_bad_combo({num, string_list}) do
    map = codepoints_to_map(string_list)

    Enum.reduce(map, true, fn {index, codepoint}, acc ->
      case codepoint <> Map.get(map, index + 1, "") in ["ab", "cd", "pq", "xy"] do
        true -> false
        false -> acc
      end
    end)
  end

  defp codepoints_to_map(string_list) do
    string_list
    |> Stream.with_index()
    |> Stream.map(fn {codepoint, index} -> {index, codepoint} end)
    |> Map.new()
  end
end
