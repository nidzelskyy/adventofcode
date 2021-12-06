defmodule Aoc2021Day5 do
  @moduledoc false

  @quest_file "input5.txt"
  @test_quest_file "input5_test.txt"

  @needle 2021

  @agent_name :board

  #Aoc2021Day5.run(:test)
  #Aoc2021Day5.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2021Day5.part_one(:test)
  #Aoc2021Day5.part_one(:prod)
  def part_one(mode) do
    input = parse_file(mode)

    search_max_coordinate(input)
    |> init_map_agent()

    Enum.each(input, &add_by_line/1)

    result = calculate_larger_than(2)

    Agent.stop(@agent_name)

    result
  end

  #Aoc2021Day5.part_two(:test)
  #Aoc2021Day5.part_two(:prod)
  def part_two(mode) do
    input = parse_file(mode)

    search_max_coordinate(input)
    |> init_map_agent()

    Enum.each(input, &add_by_line2/1)

    result = calculate_larger_than(2)

    Agent.stop(@agent_name)

    result
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(fn x ->
        str = String.trim(x)
        info = Regex.named_captures(~r/(?<x1>\d{1,4})\,(?<y1>\d{1,4})\s+\-\>\s+(?<x2>\d{1,4})\,(?<y2>\d{1,4})/, str)
        {{String.to_integer(info["x1"]), String.to_integer(info["y1"])}, {String.to_integer(info["x2"]), String.to_integer(info["y2"])}}
      end)
    |> Enum.map(&(&1))
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def search_max_coordinate(input) do
    Enum.reduce(input, 0, fn {{x1, y1}, {x2, y2}}, acc ->
      Enum.max([acc, x1, x2, y1, y2])
    end)
  end

  def init_map_agent(max_coordinate) do
    coordinates = for x <- 0..max_coordinate, y <- 0..max_coordinate, do: {{x, y}, 0}

    coordinates =
      coordinates
      |> Map.new()

    Agent.start(fn -> coordinates end, [name: @agent_name])
  end

  def add_by_line({{x, y1}, {x, y2}}), do: agent_add_vertical(x, y1, y2)
  def add_by_line({{x1, y}, {x2, y}}), do: agent_add_horizontal(y, x1, x2)
  def add_by_line({{x1, y1}, {x2, y2}}), do: nil

  def add_by_line2({{x, y1}, {x, y2}}), do: agent_add_vertical(x, y1, y2)
  def add_by_line2({{x1, y}, {x2, y}}), do: agent_add_horizontal(y, x1, x2)
  def add_by_line2({{x1, y1}, {x2, y2}}), do: agent_add_diagonal(x1, x2, y1, y2)

  #from left to right
  def agent_add_horizontal(y, x1, x2) when x1 <= x2 do
    Enum.reduce(x1..x2, [], fn x, acc -> acc ++ [{x, y}] end)
    |> agent_add_by_coordinate_list()
  end
  #from right to left, just invert
  def agent_add_horizontal(y, x1, x2) when x1 > x2, do: agent_add_horizontal(y, x2, x1)

  #from up do down
  def agent_add_vertical(x, y1, y2) when y1 <= y2 do
    Enum.reduce(y1..y2, [], fn y, acc -> acc ++ [{x, y}] end)
    |> agent_add_by_coordinate_list()
  end
  #from down to up, just invert
  def agent_add_vertical(x, y1, y2) when y1 > y2, do: agent_add_vertical(x, y2, y1)

  #left->down
  def agent_add_diagonal(x1, x2, y1, y2) when x1 <= x2 and y1 <= y2 and x2 - x1 == y2 - y1 do
    Enum.reduce(0..(x2 - x1), [], fn num, acc -> acc ++ [{x1 + num, y1 + num}] end)
    |> agent_add_by_coordinate_list()
  end
  #left->up
  def agent_add_diagonal(x1, x2, y1, y2) when x1 <= x2 and y1 > y2 and x2 - x1 == y1 - y2 do
    Enum.reduce(0..(x2 - x1), [], fn num, acc -> acc ++ [{x1 + num, y1 - num}] end)
    |> agent_add_by_coordinate_list()
  end
  #right->down
  def agent_add_diagonal(x1, x2, y1, y2) when x1 > x2 and y1 <= y2 and x1 - x2 == y2 - y1 do
    Enum.reduce(0..(x1 - x2), [], fn num, acc -> acc ++ [{x1 - num, y1 + num}] end)
    |> agent_add_by_coordinate_list()
  end
  #right->up
  def agent_add_diagonal(x1, x2, y1, y2) when x1 > x2 and y1 > y2 and x1 - x2 == y1 - y2 do
    Enum.reduce(0..(x1 - x2), [], fn num, acc -> acc ++ [{x1 - num, y1 - num}] end)
    |> agent_add_by_coordinate_list()
  end
  #not correct
  def agent_add_diagonal(_x1, _x2, _y1, _y2), do: nil

  def agent_add_by_coordinate_list(coordinates_list) do
    Agent.update(@agent_name, fn state ->
      Enum.reduce(coordinates_list, state, fn {x, y}, acc ->
        current = Map.get(acc, {x, y}, 0)
        Map.put(acc, {x, y}, current + 1)
      end)
    end)
  end

  def calculate_larger_than(val) do
    Agent.get(@agent_name, fn state ->
      Enum.filter(state, fn {_index, count} -> count >= val end)
    end)
    |> Enum.count()
  end
end
