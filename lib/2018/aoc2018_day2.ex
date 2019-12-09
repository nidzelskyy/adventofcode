defmodule Aoc2018Day2 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    parse_file()
    |> Enum.map(fn code_list ->
      code_list
      |> Enum.group_by(fn x -> x end)
      |> Enum.reduce(%{2 => 0, 3 => 0}, fn {x, list}, acc ->
          case length(list) > 1 do
            true -> Map.put(acc, length(list), 1)
            false -> acc
          end
        end)
    end)
    |> Enum.reduce(%{2 => 0, 3 => 0}, fn code_info, %{2 => two_count, 3 => three_count} ->
        %{2 => two_count + Map.get(code_info, 2, 0), 3 => three_count + Map.get(code_info, 3, 0)}
      end)
    |> (fn %{2 => two_count, 3 => three_count} -> two_count * three_count end).()
  end

  def part_two() do
    all_strings =
      parse_file()
      |> Enum.map(&Enum.with_index/1)

    for(str <- all_strings, str2 <- all_strings, length(str -- str2) == 1, do: {str, str2})
    |> hd()
    |> (fn {str, str2} ->
          Enum.reduce(0..(length(str)-1), "", fn index, acc ->
            {character_a, _} = Enum.at(str, index)
            {character_b, _} = Enum.at(str2, index)
            case character_a == character_b do
              true -> acc <> character_a
              false -> acc
            end
          end)
        end).()
  end

  def parse_file() do
    File.stream!("inputs/2018/input2.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.map(fn code ->
      String.codepoints(code)
    end)
  end
end
