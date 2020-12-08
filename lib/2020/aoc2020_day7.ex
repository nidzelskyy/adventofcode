defmodule Aoc2020Day7 do
  @moduledoc false

  @quest_file "input7.txt"
  @test_quest_file "input7_test.txt"

  @santa_bug "shiny gold"

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    parse_file(mode)
    |> prepare_nested_child()
    |> calculate_nested_child(@santa_bug)
  end

  def part_two(mode) do
    info =
      parse_file(mode)
      |> prepare_nested_child()

      info
      |> Map.get(@santa_bug)
      |> Map.get(:child_count)
      |> Enum.into([])
      |> calculate_nested_count(1, 0, info)
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/2020/#{file_name(mode)}")
    |> Enum.map(fn line -> String.trim(line) end)
    |> Enum.map(fn line ->
        [[_all, _count, main_bug_name] | bug_child_arr] = Regex.scan(~r/(\d+)?\s?(\w+\s\w+)\sbags?/, line)
        child_list =
          Enum.map(bug_child_arr, fn [_all, count, name] ->
            if(name != "no other") do
              count =
                case Integer.parse(count) do
                  {num, _} -> num
                  _ -> 1
                end
              {name, count}
            else
              {name, 0}
            end
          end)
          |> Map.new()

        child = Map.keys(child_list) |> Enum.filter(fn name -> name != "no other" end)
        child_count = Enum.filter(child_list, fn {name, _count} -> name != "no other" end) |> Map.new()

        {main_bug_name, %{child: child, all_child: [], child_count: child_count}}
      end)
    |> Map.new()
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def prepare_nested_child(start_info) do
    start_info
    |> Enum.reduce(%{}, fn {name, info}, acc ->
        all_child = search_nested_child(Map.get(info, :child), Map.get(info, :child), start_info) |> Enum.uniq()
        Map.put(acc, name, Map.put(info, :all_child, all_child))
      end)
  end

  def calculate_nested_child(list, searched_name) do
    list
    |> Enum.filter(fn {name, info} ->
        Enum.member?(Map.get(info, :all_child), searched_name)
      end)
    |> Enum.count()
  end

  def search_nested_child([], nested_child_list, _all), do: nested_child_list
  def search_nested_child([current | last], nested_child_list, all) do
    current_child =
      Map.get(all, current)
      |> Map.get(:child)
    search_nested_child(last ++ current_child, nested_child_list ++ current_child, all)
  end

  def calculate_nested_count([], coefficient, result, _list), do: result
  def calculate_nested_count([{name, count} | tl], coefficient, result, list) do
    child_sum =
      list
      |> Map.get(name)
      |> Map.get(:child_count)
      |> Enum.into([])
      |> calculate_nested_count(coefficient * count, result + coefficient * count, list)

    calculate_nested_count(tl, coefficient, child_sum, list)
  end
end
