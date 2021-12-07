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
    parse_file(mode)
    :one
  end

  def part_two(mode) do
    parse_file(mode)
    :second
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
end
