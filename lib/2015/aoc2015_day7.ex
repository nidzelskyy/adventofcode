defmodule Aoc2015Day7 do
  @moduledoc false
  use Bitwise

  @year 2015
  @quest_file "input7.txt"
  @test_quest_file "input7_test.txt"
  @agent_name :calc_agent
  @command_agent_name :commands_agent
  @min_range 0
  @max_range 65535

  #Aoc2015Day7.run(:test)
  #Aoc2015Day7.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2015Day7.part_one(:test)
  #Aoc2015Day7.part_one(:prod)
  def part_one(mode) do
    Agent.start(fn -> %{} end, [name: @agent_name])
    Agent.start(fn -> %{} end, [name: @command_agent_name])
    commands =
      parse_file(mode)
      |> Enum.map(fn string -> check_command(string) end)
      |> Map.new()

    Agent.update(@command_agent_name, fn _state -> commands end)

    result = search_result("a")

    Agent.stop(@agent_name)
    Agent.stop(@command_agent_name)
    result
  end

  #Aoc2015Day7.part_two(:test)
  #Aoc2015Day7.part_two(:prod)
  def part_two(mode) do
    wire_a_result = part_one(:prod)
    Agent.start(fn -> %{} end, [name: @agent_name])
    Agent.start(fn -> %{} end, [name: @command_agent_name])

    commands =
      parse_file(mode)
      |> Enum.map(fn string -> check_command(string) end)
      |> Map.new()

    Agent.update(@agent_name, fn state -> Map.put(state, "b", wire_a_result) end)
    command = Map.get(commands, "b")
    commands = Map.put(commands, "b", Map.put(command, :arg1, wire_a_result))
    Agent.update(@command_agent_name, fn _state -> commands end)

    result = search_result("a")

    Agent.stop(@agent_name)
    Agent.stop(@command_agent_name)
    result
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/#{@year}/#{file_name(mode)}")
    |> Stream.map(&String.trim(&1))
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def check_command(string) do
    cond do
      info = Regex.named_captures(~r/(NOT)\s(?<arg1>[a-z]{1,2}|[0-9]{1,5})\s->\s(?<result>[a-z]{1,2})/, string) ->
        result = %{command: :not, arg1: prepare_if_number(info["arg1"]), result: prepare_if_number(info["result"])}
        prepare_init_values(result)
        {Map.get(result, :result), result}
      info = Regex.named_captures(~r/(?<arg1>[a-z]{1,2}|[0-9]{1,5})\s(?<command>OR)\s(?<arg2>[a-z]{1,2}|[0-9]{1,5})\s->\s(?<result>[a-z]{1,2})/, string) ->
        result = %{command: :or, arg1: prepare_if_number(info["arg1"]), arg2: prepare_if_number(info["arg2"]), result: prepare_if_number(info["result"])}
        prepare_init_values(result)
        {Map.get(result, :result), result}
      info = Regex.named_captures(~r/(?<arg1>[a-z]{1,2}|[0-9]{1,5})\s(?<command>AND)\s(?<arg2>[a-z]{1,2}|[0-9]{1,5})\s->\s(?<result>[a-z]{1,2})/, string) ->
        result = %{command: :and, arg1: prepare_if_number(info["arg1"]), arg2: prepare_if_number(info["arg2"]), result: prepare_if_number(info["result"])}
        prepare_init_values(result)
        {Map.get(result, :result), result}
      info = Regex.named_captures(~r/(?<arg1>[a-z]{1,2}|[0-9]{1,5})\s(?<command>RSHIFT)\s(?<arg2>[a-z]{1,2}|[0-9]{1,5})\s->\s(?<result>[a-z]{1,2})/, string) ->
        result = %{command: :rshift, arg1: prepare_if_number(info["arg1"]), arg2: prepare_if_number(info["arg2"]), result: prepare_if_number(info["result"])}
        prepare_init_values(result)
        {Map.get(result, :result), result}
      info = Regex.named_captures(~r/(?<arg1>[a-z]{1,2}|[0-9]{1,5})\s(?<command>LSHIFT)\s(?<arg2>[a-z]{1,2}|[0-9]{1,5})\s->\s(?<result>[a-z]{1,2})/, string) ->
        result = %{command: :lshift, arg1: prepare_if_number(info["arg1"]), arg2: prepare_if_number(info["arg2"]), result: prepare_if_number(info["result"])}
        prepare_init_values(result)
        {Map.get(result, :result), result}
      info = Regex.named_captures(~r/(?<arg1>[a-z]{1,2}|[0-9]{1,5})\s->\s(?<result>[a-z]{1,2})/, string) ->
        result = %{command: :assign, arg1: prepare_if_number(info["arg1"]), result: prepare_if_number(info["result"])}
        prepare_init_values(result)
        {Map.get(result, :result), result}
      true ->
        :unknown
    end
  end

  def prepare_if_number(value) do
    case Integer.parse(value, 10) do
      {number, _} -> number
      :error -> value
      _other -> value
    end
  end

  def prepare_init_values(%{arg1: arg1, arg2: arg2, result: result}) do
    init_if_not_exists(arg1)
    init_if_not_exists(arg2)
    init_if_not_exists(result)
  end
  def prepare_init_values(%{arg1: arg1, result: result}) do
    init_if_not_exists(arg1)
    init_if_not_exists(result)
  end

  def init_if_not_exists(arg) when is_bitstring(arg), do: Agent.update(@agent_name, fn state -> Map.put(state, arg, nil) end)
  def init_if_not_exists(_arg), do: nil

  def get_agent_value(key), do: Agent.get(@agent_name, fn state -> Map.get(state, key, nil) end)
  def get_wire_command(wire), do: Agent.get(@command_agent_name, fn state -> Map.get(state, wire, nil) end)

  def search_result(wire) do
    case get_agent_value(wire) do
      nil ->
        command = get_wire_command(wire)
        arg1 = Map.get(command, :arg1)
        arg2 = Map.get(command, :arg2)
        if(is_bitstring(arg1)) do
          search_result(arg1)
        end
        if(is_bitstring(arg2)) do
          search_result(arg2)
        end
        run_command(command)
        get_agent_value(wire)
      value ->
        value
    end
  end

  def run_command(%{command: :not, arg1: arg1, result: result}) do
    Agent.update(@agent_name, fn state ->
      value = Map.get(state, arg1, arg1)
      upd_value = @max_range - value
      Map.put(state, result, upd_value)
    end)
  end
  def run_command(%{command: :or, arg1: arg1, arg2: arg2, result: result}) do
    Agent.update(@agent_name, fn state ->
      a1 = Map.get(state, arg1, arg1)
      a2 = Map.get(state, arg2, arg2)
      res = a1 ||| a2
      Map.put(state, result, res)
    end)
  end
  def run_command(%{command: :and, arg1: arg1, arg2: arg2, result: result}) do
    Agent.update(@agent_name, fn state ->
      a1 = Map.get(state, arg1, arg1)
      a2 = Map.get(state, arg2, arg2)
      res = a1 &&& a2
      Map.put(state, result, res)
    end)
  end
  def run_command(%{command: :rshift, arg1: arg1, arg2: arg2, result: result}) do
    Agent.update(@agent_name, fn state ->
      a1 = Map.get(state, arg1, arg1)
      a2 = Map.get(state, arg2, arg2)
      res = a1 >>> a2
      Map.put(state, result, res)
    end)
  end
  def run_command(%{command: :lshift, arg1: arg1, arg2: arg2, result: result}) do
    Agent.update(@agent_name, fn state ->
      a1 = Map.get(state, arg1, arg1)
      a2 = Map.get(state, arg2, arg2)
      res = a1 <<< a2
      Map.put(state, result, res)
    end)
  end
  def run_command(%{command: :assign, arg1: arg1, result: result}) do
    Agent.update(@agent_name, fn state ->
      a1 = Map.get(state, arg1, arg1)
      Map.put(state, result, a1)
    end)
  end
end
