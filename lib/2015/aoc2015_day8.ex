defmodule Aoc2015Day8 do
  @moduledoc false

  @year 2015
  @quest_file "input8.txt"
  @test_quest_file "input8_test.txt"

  #Aoc2015Day8.run(:test)
  #Aoc2015Day8.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2015Day8.part_one(:test)
  #Aoc2015Day8.part_one(:prod)
  def part_one(mode) do
    parse_file(mode)
    |> Enum.reduce(0, fn str, acc ->
        full_length = String.length(str)
        codes_length =
          str
          |> String.trim("\"")
          |> (fn str -> Regex.replace(~r/\\\\/, str, "\\") end).()
          |> (fn str -> Regex.replace(~r/\\\"/, str, "\"") end).()
          |> (fn str -> Regex.replace(~r/\\x[0-9a-f]{2}/, str, "\'") end).()
          |> String.length()

        acc + (full_length - codes_length)
      end)
    |> IO.inspect()
  end

  #Aoc2015Day8.part_two(:test)
  #Aoc2015Day8.part_two(:prod)
  def part_two(mode) do
    parse_file(mode)
    |> Enum.reduce(0, fn str, acc ->
         full_length = String.length(str)
         codes_length =
           str
           |> (fn str -> Regex.replace(~r/\\x[0-9a-f]{2}/, str, "\\a27") end).()
           |> (fn str -> Regex.replace(~r/\\/, str, "\\\\\\\\") end).()
           |> (fn str -> Regex.replace(~r/\"/, str, "\\\\\"") end).()
           |> (fn str -> Regex.replace(~r/\\\"/, str, "\\\\\"") end).()
           |> String.length()
           |> (fn x -> x + 2 end).()

         acc + (codes_length - full_length)
       end)
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/#{@year}/#{file_name(mode)}")
    |> Stream.map(&String.trim(&1))
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def replace_double_quote(string) do

  end
end
