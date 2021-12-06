defmodule Aoc2021Day6 do
  @moduledoc false

  @quest_file "input6.txt"
  @test_quest_file "input6_test.txt"

  @every_day_child_agent :child_agent

  @needle 2021

  #for part one
#  @total_days 80
  #for test
#  @total_days 18
  # for part two
  @total_days 256

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2021Day6.part_one(:test)
  #Aoc2021Day6.part_one(:prod)
  def part_one(mode) do
    input = parse_file(mode)
    init_empty_agent(Enum.count(input))

    input
    |> prepare_agent_init()

    Enum.each(1..@total_days, fn x -> prepare_day_child(x) end)

    result = get_total_sum()

    IO.inspect(get_agent_state())

    Agent.stop(@every_day_child_agent)

    result
  end

  #Aoc2021Day6.part_two(:test)
  #Aoc2021Day6.part_two(:prod)
  def part_two(mode) do
    input = parse_file(mode)
    init_empty_agent(Enum.count(input))

    input
    |> prepare_agent_init()

    Enum.each(1..@total_days, fn x -> prepare_day_child(x) end)

    result = get_total_sum()

    IO.inspect(get_agent_state())

    Agent.stop(@every_day_child_agent)

    result
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.filter(&(String.length(&1) > 0))
    |> Stream.map(fn str ->
      str
      |> String.trim()
      |> String.split(",") end)
    |> Enum.map(fn x -> x end)
    |> List.flatten()
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def init_empty_agent(start_count) do
    Agent.start(fn ->
         Enum.map(0..@total_days, fn x -> {x, 0} end)
         |> Map.new()
         |> Map.put(0, start_count)
      end,
      [name: @every_day_child_agent])
  end

  def prepare_agent_init(input) do
    Enum.frequencies(input)
    |> Enum.each(fn {num, count} ->
      prepare_day_child(1, num, count)
    end)
  end

  #Aoc2021Day6.prepare_day_child(0, 4)
  def prepare_day_child(day, first_left_days \\ 9, counter \\ nil) do
    numbers =
      Enum.reduce(1..div(@total_days - day, 7), [day + first_left_days], fn x, [last_day | _] = acc -> [last_day + 7] ++ acc end)
      |> Enum.filter(fn x -> x <= @total_days end)
      |> Enum.reverse()
    day_count =
      case counter do
        nil -> get_day_counter(day)
        count -> count
      end
    Agent.update(@every_day_child_agent, fn state ->
      Enum.reduce(numbers, state, fn x, acc ->
        count = Map.get(state, x, 0)
        Map.put(acc, x, count + day_count)
      end)
    end)
  end

  def get_agent_state() do
    Agent.get(@every_day_child_agent, fn state -> state end)
    |> Enum.filter(fn {i, x} -> x > 0 end)
  end

  def get_day_counter(day) do
    Agent.get(@every_day_child_agent, fn state -> Map.get(state, day) end)
  end

  def get_total_sum() do
    Agent.get(@every_day_child_agent, fn state -> state end)
    |> Enum.reduce(0, fn {_i, x}, acc -> acc + x end)
  end
end
