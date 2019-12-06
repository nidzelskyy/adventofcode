defmodule Aoc2019Day6 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    info =
      parse_file()
      |> prepare_first_nested()

    all = Enum.uniq(info.all)
    satellites = Enum.uniq(info.satellites)

    start = all -- satellites |> hd()

    create_planet_tree(info.result, start)
    |> calculate_count()
  end

  def part_two() do
    info =
      parse_file()
      |> prepare_first_nested()

    all = Enum.uniq(info.all)
    satellites = Enum.uniq(info.satellites)

    start = all -- satellites |> hd()

    tree = create_planet_tree(info.result, start)

    path = get_path_to(tree, "YOU")
    path2 = get_path_to(tree, "SAN")

    a = path -- path2
    b = path2 -- path

    length(a) + length(b) - 2
  end

  def parse_file() do
    File.read!("inputs/2019/input6.txt")
    |> String.trim()
    |> String.split(~r/\n/)
    |> Enum.map(fn x -> x end)
  end

  def prepare_first_nested(input) do
    input
    |> Enum.reduce(%{all: [], satellites: [], result: %{}}, fn x, acc ->
      [planet, satellite] = String.split(x, ")")
      planets = Map.get(acc.result, planet, [])
      satellites = [satellite | planets]


      %{acc | all: [planet, satellite | acc.all], satellites: [satellite | acc.satellites], result: Map.put(acc.result, planet, satellites)}
    end)
  end

  def create_planet_tree(planets, head) do
    satellites = Map.get(planets, head)
    case not is_nil(satellites) && length(satellites) > 0 do
      true ->
        Enum.reduce(satellites, %{head => []}, fn x, acc ->
          info = create_planet_tree(planets, x)
          %{ acc | head => [info | Map.get(acc, head)] }
        end)
      false ->
        %{head => nil}
    end
  end

  def calculate_count(tree, level \\ 0, sum \\ 0)
  def calculate_count(tree, level, sum) do
    Enum.reduce(tree, sum , fn {key, childs}, acc ->
      case not is_nil(childs) and length(childs) > 0 do
        true ->
          Enum.reduce(childs, acc, fn child, s ->
            calculate_count(child, level + 1, s)
          end) + level
        false ->
          acc + level
      end
    end)
  end

  def get_path_to(tree, satellite_name) do
    Enum.reduce(tree, [], fn {key, childs}, acc ->
      case not is_nil(childs) and length(childs) > 0 and key != node do
        true ->
          Enum.reduce(childs, acc, fn child, a ->
            res = get_path_to(child, satellite_name)
            case Enum.member?(res, satellite_name) do
              true -> [key | res]
              false -> a
            end
          end)
        false ->
          case key == satellite_name do
            true -> [key]
            false -> acc
          end
      end
    end)
  end
end
