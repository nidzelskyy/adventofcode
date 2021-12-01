defmodule Aoc2021Day1 do
  @moduledoc false

  @quest_file "input1.txt"
  @test_quest_file "input1_test.txt"

  @needle 2021
  @number_agent :number_agent

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2021Day1.part_one(:prod)
  def part_one(mode) do
    parse_file(mode)
    |> Enum.reduce({nil, 0}, fn {_i, num}, {prev, counter} ->
      case prev do
        nil -> {num, counter}
        _ ->
          counter =
            if(num > prev) do
              counter + 1
            else
              counter
            end
          {num, counter}
      end
    end)
    |> IO.inspect()
  end

  def part_two(mode) do
    map =
      parse_file(mode)
      |> Map.new()

    Enum.reduce(0..(Enum.count(map) - 3), {nil, 0}, fn index, {prev, counter} ->
      sum = Map.get(map, index) + Map.get(map, index + 1) + Map.get(map, index + 2)
      case prev do
        nil -> {sum, counter}
        _ ->
          counter =
            if(sum > prev) do
              counter + 1
            else
              counter
            end
          {sum, counter}
      end
    end)
    |> IO.inspect()
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.with_index()
    |> Enum.map(fn {x, index} ->
      x =
        Integer.parse(x, 10)
        |> (fn {i, _} -> i end).()
      {index, x}
    end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
end
