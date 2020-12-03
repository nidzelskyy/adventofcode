defmodule Aoc2020Day2 do
  @moduledoc false

  @quest_file "input2.txt"
  @test_quest_file "input2_test.txt"

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    parse_file(mode)
    |> Enum.filter(fn {min, max, symbol, password} ->
        upd_passwd = String.replace(password, symbol, "")
        len = String.length(password) - String.length(upd_passwd)
        len >= min && len <= max
      end)
    |> Enum.count()
  end

  def part_two(mode) do
    parse_file(mode)
    |> Enum.filter(fn {first, second, symbol, password} ->
      char = String.codepoints(password)
      f = get_at_position(char, first - 1)
      s = get_at_position(char, second - 1)

      f != s && (f == symbol || s == symbol)
    end)
    |> Enum.count()
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/2020/#{file_name(mode)}")
    |> Enum.map(fn line ->
      [_, min, max, symbol, password] = Regex.run(~r/(\d+)\-(\d+)\s([a-z])\:\s(.*)\s?/, line)
      {String.to_integer(min), String.to_integer(max), String.trim(symbol), String.trim(password)}
    end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  defp get_at_position(list, position) do
    case Enum.fetch(list, position) do
      {:ok, c} -> c
      _ -> nil
    end
  end
end
