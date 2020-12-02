defmodule Aoc2020Day2 do
  @moduledoc false

  @quest_file "input2.txt"

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
  end

  def part_one() do
    parse_file()
    |> Enum.filter(fn {min, max, symb, password} ->
        upd_passwd = String.replace(password, symb, "")
        len = String.length(password) - String.length(upd_passwd)
        len >= min && len <= max
      end)
    |> Enum.count()
  end

  def part_two() do
    parse_file()
    |> Enum.filter(fn {first, second, symb, password} ->
      char = String.codepoints(password)
      f =
        case Enum.fetch(char, first - 1) do
          {:ok, c} -> c
          _ -> nil
        end
      s =
        case Enum.fetch(char, second - 1) do
          {:ok, c} -> c
          _ -> nil
        end

      f != s && (f == symb || s == symb)
    end)
    |> Enum.count()
  end

  def parse_file() do
    File.stream!("inputs/2020/#{@quest_file}")
    |> Enum.map(fn line ->
      [diap, symb, password] = String.split(line)
      [min, max] = String.split(diap, "-")
      min = String.to_integer(min)
      max = String.to_integer(max)
      symb = String.trim(symb, ":")
      password = String.trim(password)
      {min, max, symb, password}
    end)
  end
end
