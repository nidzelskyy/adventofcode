defmodule Aoc2020Day4 do
  @moduledoc false

  @quest_file "input4.txt"
  @test_quest_file "input4_test.txt"

  @all_fields ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"]
  @required_fields ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    parse_file(mode)
    |> Enum.filter(fn info -> validate_required_fields(info) end)
    |> Enum.count()
  end

  def part_two(mode) do
    parse_file(mode)
    |> Enum.filter(fn info -> validate_required_fields(info) end)
    |> Enum.filter(fn info ->
        Enum.reduce(info, true, fn {key, value}, acc -> acc && validate(key, value) end)
      end)
    |> Enum.count()
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/2020/#{file_name(mode)}")
    |> Stream.with_index()
    |> Enum.reduce({[], []}, fn {line, index}, {acc, tmp_acc} ->
        line = String.trim(line)
        case String.length(line) == 0 do
          true ->
            {acc ++ [tmp_acc |> Map.new()], []}
          false ->
            splitted_line =
              String.split(line)
              |> Enum.map(fn subline ->
                  [key, value] = String.split(subline, ":")
                  {String.trim(key), String.trim(value)}
                end)
            {acc, tmp_acc ++ splitted_line}
        end
      end)
    |> (fn ({acc, tmp_acc}) -> acc ++ [tmp_acc |> Map.new()] end).()
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  defp validate_required_fields(info) do
    missed_fields = @required_fields -- Map.keys(info)
    Enum.count(missed_fields) == 0 || ["cid"] == missed_fields
  end

  defp validate("byr", value), do: validate_number_diapason(value, 1920, 2002)
  defp validate("iyr", value), do: validate_number_diapason(value, 2010, 2020)
  defp validate("eyr", value), do: validate_number_diapason(value, 2020, 2030)
  defp validate("hgt", value) do
    case Regex.run(~r/^(\d+)(in|cm)$/, value) do
      [_, hgt, type] -> validate("hgt_#{type}", hgt)
      _ -> false
    end
  end
  defp validate("hgt_in", value), do: validate_number_diapason(value, 59, 76)
  defp validate("hgt_cm", value), do: validate_number_diapason(value, 150, 193)
  defp validate("hcl", value), do: Regex.match?(~r/^\#([0-9a-f]{6})$/, value)
  defp validate("ecl", value), do: value in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
  defp validate("pid", value), do: Regex.match?(~r/^(\d{9})$/, value)
  defp validate("cid", value), do: true
  defp validate(_name, _value), do: false

  defp validate_number_diapason(value, min, max) do
    with {number, _} <- Integer.parse("#{value}") do
      number >= min and number <= max
    else
      _ -> false
    end
  end
end
