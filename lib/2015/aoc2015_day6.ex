defmodule Aoc2015Day6 do
  @moduledoc false

  @year 2015
  @quest_file "input6.txt"
  @test_quest_file "input6_test.txt"

  #Aoc2015Day6.run(:test)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2015Day6.part_one(:test)
  def part_one(mode) do
    {:ok, pid} = Agent.start(fn -> create_light_square(1000) end)

    parse_file(mode)
    |> Enum.each(fn instruction -> run_instruction(instruction, pid) end)

    result = calculate_agent_light(pid)
    Agent.stop(pid)
    result
  end

  #Aoc2015Day6.part_two(:test)
  def part_two(mode) do
    {:ok, pid} = Agent.start(fn -> create_light_square(1000) end)

    parse_file(mode)
    |> Enum.each(fn instruction -> run_instruction_2(instruction, pid) end)

    result = calculate_agent_brightness(pid)
    Agent.stop(pid)
    result
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/#{@year}/#{file_name(mode)}")
    |> Stream.map(&String.trim(&1))
    |> Stream.map(fn instruction ->
        #turn off 660,55 through 986,197
        [_, command, x1, y1, x2, y2] = Regex.run(~r/(turn on|turn off|toggle)\s+(\d{1,3})\,(\d{1,3})\s+through\s+(\d{1,3})\,(\d{1,3})/, instruction)
        {command_name(command), String.to_integer(x1), String.to_integer(y1), String.to_integer(x2), String.to_integer(y2)}
      end)
  end

  def command_name("turn on"),  do: :turn_on
  def command_name("turn off"), do: :turn_off
  def command_name("toggle"),   do: :toggle

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  #Aoc2015Day6.create_light_square(3)
  def create_light_square(size) do
    Enum.reduce(0..(size - 1), [], fn x, acc ->
      Enum.reduce(0..(size - 1), acc, fn y, acc2 ->
        [{{x, y}, 0}] ++ acc2
      end)
    end)
    |> Map.new()
  end

  def run_instruction({instruction_name, x1, y1, x2, y2}, agent_pid) do
    Enum.each(x1..x2, fn x ->
      Enum.each(y1..y2, fn y ->
        Agent.update(agent_pid, fn state -> Map.put(state, {x, y}, prepare_command(instruction_name, Map.get(state, {x, y}))) end)
      end)
    end)
  end

  def run_instruction_2({instruction_name, x1, y1, x2, y2}, agent_pid) do
    Enum.each(x1..x2, fn x ->
      Enum.each(y1..y2, fn y ->
        Agent.update(agent_pid, fn state -> Map.put(state, {x, y}, prepare_command_2(instruction_name, Map.get(state, {x, y}))) end)
      end)
    end)
  end

  def prepare_command(:turn_on, _),  do: 1
  def prepare_command(:turn_off, _), do: 0
  def prepare_command(:toggle, 1),   do: 0
  def prepare_command(:toggle, 0),   do: 1

  def prepare_command_2(:turn_on, x),  do: x + 1
  def prepare_command_2(:turn_off, 0), do: 0
  def prepare_command_2(:turn_off, x), do: x - 1
  def prepare_command_2(:toggle, x),   do: x + 2

  def calculate_agent_light(agent_pid) do
    Agent.get(agent_pid, fn state ->
      Enum.filter(state, fn {_, status} -> status == 1 end)
      |> Enum.count()
    end)
  end

  def calculate_agent_brightness(agent_pid) do
    Agent.get(agent_pid, fn state ->
      Enum.reduce(state, 0, fn {_, status}, acc -> acc + status end)
    end)
  end
end
