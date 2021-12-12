defmodule Aoc2021Day12 do
  @moduledoc false

  @quest_file "input12.txt"
  @test_quest_file "input12_test.txt"
  @test_quest_file2 "input12_test2.txt"
  @test_quest_file3 "input12_test3.txt"

  @needle 2021

  #Aoc2021Day12.run(:test)
  #Aoc2021Day12.run(:test2)
  #Aoc2021Day12.run(:test3)
  #Aoc2021Day12.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  #Aoc2021Day12.part_one(:test)
  #Aoc2021Day12.part_one(:test2)
  #Aoc2021Day12.part_one(:test3)
  #Aoc2021Day12.part_one(:prod)
  def part_one(mode) do
    init_queue_agent(mode)
    Agent.start(fn -> [] end, name: :results)

    Stream.iterate(1, & &1 + 1)
    |> Enum.reduce_while(nil, fn _, _ ->
      case get_next_task() do
        {:ok, {path_list, graph_map}} ->
          search_next_path(path_list, graph_map)
          {:cont, nil}
        _otherwise -> {:halt, nil}
      end
    end)

    result = Agent.get(:results, fn state -> Enum.count(state) end)
#    Agent.get(:results, fn state -> state end)
#    |> Enum.each(fn list -> list |> Enum.reverse() |> Enum.join("->") |> IO.inspect() end)
    Agent.stop(:queue)
    Agent.stop(:results)
    result
  end

  #Aoc2021Day12.part_two(:test)
  #Aoc2021Day12.part_two(:test2)
  #Aoc2021Day12.part_two(:test3)
  #Aoc2021Day12.part_two(:prod)
  def part_two(mode) do
    init_queue_agent_2(mode)
    Agent.start(fn -> [] end, name: :results)

    Stream.iterate(1, & &1 + 1)
    |> Enum.reduce_while(nil, fn _, _ ->
      case get_next_task() do
        {:ok, {path_list, graph_map, has_duplicate}} ->
          search_next_path_2(path_list, graph_map, has_duplicate)
          {:cont, nil}
        _otherwise -> {:halt, nil}
      end
    end)

    result = Agent.get(:results, fn state -> Enum.count(state) end)
#    Agent.get(:results, fn state -> state end)
#    |> Enum.each(fn list -> list |> Enum.reverse() |> Enum.join("->") |> IO.inspect() end)
    Agent.stop(:queue)
    Agent.stop(:results)
    result
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(fn str ->
      str
      |> String.trim()
      |> String.split("-", trim: true)
    end)
    |> Enum.map(&(&1))
    |> Enum.reduce(%{}, fn [a, b], acc ->
        a_list = ([b] ++ Map.get(acc, a, [])) |> Enum.uniq
        b_list = [a] ++ Map.get(acc, b, []) |> Enum.uniq
        acc
        |> Map.put(a, a_list)
        |> Map.put(b, b_list)
      end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(:test2), do: @test_quest_file2
  def file_name(:test3), do: @test_quest_file3
  def file_name(_), do: @quest_file

  def init_queue_agent(mode) do
    input =
      parse_file(mode)
      |> Map.delete("end")

    Agent.start(fn ->
                   start = Map.get(input, "start")
                   upd_input = delete_if_downcase(input, "start")
                   Enum.reduce(start, [], fn key, acc ->
                                             [{[key, "start"], clear_downcase_path(upd_input, key)}] ++ acc
                   end)
    end, name: :queue)
  end

  def delete_if_downcase(map, drop_key) do
    case drop_key == String.downcase(drop_key) do
      true ->
        map
        |> Map.delete(drop_key)
        |> clear_downcase_path(drop_key)
      false -> map
    end
  end

  def clear_downcase_path(map, drop_key) do
    case drop_key == String.downcase(drop_key) do
      true ->
        map
        |> Enum.reduce(%{}, fn {key, value}, acc -> Map.put(acc, key, value -- [drop_key]) end)
      false -> map
    end
  end

  def get_next_task() do
    Agent.get_and_update(:queue, fn
      [head | new_state] -> {{:ok, head}, new_state}
      [] -> {{:error, nil}, []}
    end)
  end

  def search_next_path(["end" | _] = path_list, _graph_map), do: Agent.update(:results, fn state -> [path_list] ++ state end)
  def search_next_path([last_key | _] = path_list, graph_map) do
    Map.get(graph_map, last_key, [])
    |> Enum.each(fn next_key ->
      Agent.update(:queue, fn state ->
        state ++ [{[next_key | path_list], graph_map |> delete_if_downcase(last_key)}]
      end)
    end)
  end

  def init_queue_agent_2(mode) do
    input =
      parse_file(mode)
      |> Map.delete("end")

    Agent.start(fn ->
                   start = Map.get(input, "start")
                   upd_input = delete_if_downcase(input, "start")
                   Enum.reduce(start, [], fn key, acc ->
                                             [{[key, "start"], clear_downcase_path_2(upd_input, key, false), false}] ++ acc
                   end)
    end, name: :queue)
  end

  def delete_if_downcase_2(map, drop_key, false = _has_duplicate), do: map
  def delete_if_downcase_2(map, drop_key, true = _has_duplicate) do
    case drop_key == String.downcase(drop_key) do
      true ->
        map
        |> Map.delete(drop_key)
        |> clear_downcase_path_2(drop_key, true)
      false -> map
    end
  end

  def clear_downcase_path_2(map, drop_key, false = _has_duplicate), do: map
  def clear_downcase_path_2(map, drop_key, true = _has_duplicate) do
    case drop_key == String.downcase(drop_key) do
      true ->
        map
        |> Enum.reduce(%{}, fn {key, value}, acc -> Map.put(acc, key, value -- [drop_key]) end)
      false -> map
    end
  end

  def search_next_path_2(["end" | _] = path_list, _graph_map, _has_duplicate), do: Agent.update(:results, fn state -> [path_list] ++ state end)
  def search_next_path_2([last_key | rest_list] = path_list, graph_map, has_duplicate) do
    Map.get(graph_map, last_key, [])
    |> Enum.each(fn next_key ->
      Agent.update(:queue, fn state ->
        upd_path_list = [next_key | path_list]
        has_duplicate = check_is_exists_downcase_duplicate(has_duplicate, upd_path_list)
        upd_graph_map =
          graph_map
          |> delete_if_downcase_2(last_key, has_duplicate)
          |> (fn map ->
                Enum.reduce(rest_list -- [next_key], map, fn key, acc ->
                  delete_if_downcase_2(acc, key, has_duplicate)
                end)
              end).()
        state ++ [{upd_path_list, upd_graph_map, has_duplicate}]
      end)
    end)
  end

  def check_is_exists_downcase_duplicate(true, _), do: true
  def check_is_exists_downcase_duplicate(_, path_list) do
    path_list
    |> Enum.frequencies()
    |> Enum.filter(fn {key, count} -> key == String.downcase(key) && count > 1 end)
    |> (fn x -> Enum.count(x) > 0 end).()
  end
end
