defmodule Aoc2021Day7 do
  @moduledoc false

  @quest_file "input7.txt"
  @test_quest_file "input7_test.txt"

  @needle 2021

  #Aoc2021Day7.run(:test)
  #Aoc2021Day7.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    input = parse_file(mode)

    median = get_median(input)
    calculate_align_fuel(input, median)
  end

  def part_two(mode) do
    input = parse_file(mode)

    min = Enum.min(input)
    max = Enum.max(input)
    Enum.reduce(min..max, %{}, fn x, acc ->
      align_fuel = calculate_align_fuel2(input, x)
      Map.put(acc, x, align_fuel)
    end)
    |> Enum.sort(fn {i, x}, {i2, x2} -> x < x2 end)
    |> hd()
  end

  def part_one_full(input) do
    min = Enum.min(input)
    max = Enum.max(input)

    Enum.reduce(min..max, %{}, fn x, acc ->
      align_fuel = calculate_align_fuel(input, x)
      Map.put(acc, x, align_fuel)
    end)
    |> Enum.sort(fn {i, x}, {i2, x2} -> x < x2 end)
    |> hd()
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(fn str ->
      String.trim(str)
      |> String.split(",")
      |> Enum.map(&String.to_integer(&1))
    end)
    |> Enum.map(&(&1))
    |> List.flatten()
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def get_median(input) do
    sorted =
      input
      |> Enum.sort()
    count_elem = Enum.count(input)
    medium = div(count_elem, 2)

    case rem(count_elem, 2) do
      0 -> div(Enum.at(sorted, medium) + Enum.at(sorted, medium - 1), 2)
      _ -> Enum.at(sorted, medium + 1)
    end
  end

  def calculate_align_fuel(input, align_number) do
    Enum.reduce(input, 0, fn x, acc ->
      acc + abs(x - align_number)
    end)
  end

  def calculate_align_fuel2(input, align_number) do
    Enum.reduce(input, 0, fn x, acc ->
      val = abs(x - align_number)
      sum = div(val * (val + 1), 2)
      acc + sum
    end)
  end
end
