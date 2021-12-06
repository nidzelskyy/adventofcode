defmodule Aoc2021Day2 do
  @moduledoc false

  @quest_file "input2.txt"
  @test_quest_file "input2_test.txt"

  @needle 2021

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2021Day2.part_one(:prod)
  def part_one(mode) do
    {forward, depth} =
      parse_file(mode)
      |> Enum.reduce({0, 0}, &parse_result/2)
      |> IO.inspect()
    forward * depth
  end

  def part_two(mode) do
    {forward, depth, aim} =
      parse_file(mode)
      |> Enum.reduce({0, 0, 0}, &parse_result/2)
      |> IO.inspect()
    forward * depth
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(&String.trim(&1))
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def parse_result("forward " <> value, {forward, depth}), do: {forward + String.to_integer(value), depth}
  def parse_result("up " <> value, {forward, depth}), do: {forward, depth - String.to_integer(value)}
  def parse_result("down " <> value, {forward, depth}), do: {forward, depth + String.to_integer(value)}
  def parse_result(_, {forward, depth}), do: {forward, depth}

  def parse_result("forward " <> value, {forward, depth, aim}), do: {forward + String.to_integer(value), depth + aim * String.to_integer(value), aim}
  def parse_result("up " <> value, {forward, depth, aim}), do: {forward, depth, aim - String.to_integer(value)}
  def parse_result("down " <> value, {forward, depth, aim}), do: {forward, depth, aim + String.to_integer(value)}
  def parse_result(_, {forward, depth, aim}), do: {forward, depth, aim}
end
