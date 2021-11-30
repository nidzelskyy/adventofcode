defmodule Aoc2015Day9 do
  @moduledoc false

  @year 2015
  @quest_file "input9.txt"
  @test_quest_file "input9_test.txt"
  @distance_map :distance_map
  @cities_list :cities_list

  #Aoc2015Day9.run(:test)
  #Aoc2015Day9.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2015Day9.part_one(:test)
  #Aoc2015Day9.part_one(:prod)
  def part_one(mode) do
    Agent.start(fn  -> %{} end, [name: @distance_map])
    Agent.start(fn  -> [] end, [name: @cities_list])

    parse_file(mode)
    |> Enum.each(fn string -> parse_distance(string) end)

    path =
      get_cities_list()
      |> Enum.map(fn x -> [x] end)
      |> create_all_city_path()
      |> calculate_distance()
      |> Enum.sort(fn {_, one}, {_, two} -> one < two end)
      |> hd()

    Agent.stop(@distance_map)
    Agent.stop(@cities_list)

    path
  end

  #Aoc2015Day9.part_two(:test)
  #Aoc2015Day9.part_two(:prod)
  def part_two(mode) do
    Agent.start(fn  -> %{} end, [name: @distance_map])
    Agent.start(fn  -> [] end, [name: @cities_list])

    parse_file(mode)
    |> Enum.each(fn string -> parse_distance(string) end)

    path =
      get_cities_list()
      |> Enum.map(fn x -> [x] end)
      |> create_all_city_path()
      |> calculate_distance()
      |> Enum.sort(fn {_, one}, {_, two} -> one >= two end)
      |> hd()

    Agent.stop(@distance_map)
    Agent.stop(@cities_list)

    path
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/#{@year}/#{file_name(mode)}")
    |> Stream.map(&String.trim(&1))
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def add_city(city) do
    Agent.update(@cities_list, fn state ->
      case Enum.member?(state, city) do
        true -> state
        false -> [city] ++ state
      end
    end)
  end

  def add_distance(%{"distance" => distance, "from" => city1, "to" => city2}) do
    Agent.update(@distance_map, fn state ->
      key_one = "#{city1}_#{city2}"
      key_two = "#{city2}_#{city1}"
      distance = String.to_integer(distance)
      case Map.has_key?(state, key_one) do
        true -> state
        false ->
          state
          |> Map.put(key_one, distance)
          |> Map.put(key_two, distance)
      end
    end)
  end

  def parse_distance(string) do
    map = Regex.named_captures(~r/(?<from>[a-zA-Z]+)\sto\s(?<to>[a-zA-Z]+)\s\=\s(?<distance>\d+)/, string)
    add_distance(map)
    add_city(Map.get(map, "from"))
    add_city(Map.get(map, "to"))
  end

  def get_cities_count(), do: Agent.get(@cities_list, fn state -> Enum.count(state) end)
  def get_cities_list(), do: Agent.get(@cities_list, fn state -> state end)
  def get_distance_map(), do: Agent.get(@distance_map, fn state -> state end)

  def create_all_city_path(list) do
    first = hd(list)
    cities = get_cities_list()
    cities_count = Enum.count(cities)
    case Enum.count(first) < cities_count do
      true ->
        Enum.reduce(list, [], fn path, acc ->
          rest = cities -- path
          new_list = Enum.map(rest, fn city -> path ++ [city] end)
          new_list ++ acc
        end)
        |> create_all_city_path()
      false ->
        list
    end
  end

  def calculate_distance(path) do
    distance_map = get_distance_map()
    Enum.map(path, fn path_list ->
      distance = path_to_distance(path_list, 0)
      {path_list, distance}
    end)
  end

  def path_to_distance([first | []], distance), do: distance
  def path_to_distance([first | [ second | _] = tail], distance) do
    distance_map = get_distance_map()
    new_dist = Map.get(distance_map, "#{first}_#{second}")
    path_to_distance(tail, distance + new_dist)
  end
end
