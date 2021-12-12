defmodule Aoc2021Day9 do
  @moduledoc false

  @quest_file "input9.txt"
  @test_quest_file "input9_test.txt"

  @needle 2021

  #Aoc2021Day9.run(:test)
  #Aoc2021Day9.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    input = parse_file(mode)

    columns = Enum.filter(input, fn {{x,y}, _num} -> x == 0 end) |> Enum.count()
    rows = Enum.filter(input, fn {{x,y}, _num} -> y == 0 end) |> Enum.count()

    input
    |> Enum.reduce([], fn {{x,y}, _num}, acc ->
        case is_smaller?({x, y}, input, rows, columns) do
          true -> [{x, y}] ++ acc
          false -> acc
        end
      end)
    |> Enum.reduce(0, fn {x,y}, acc -> acc + 1 + Map.get(input, {x,y}) end)
  end

  def part_two(mode) do
    input = parse_file(mode)

    columns = Enum.filter(input, fn {{x,y}, _num} -> x == 0 end) |> Enum.count()
    rows = Enum.filter(input, fn {{x,y}, _num} -> y == 0 end) |> Enum.count()

    input
    |> Enum.reduce([], fn {{x,y}, _num}, acc ->
      case is_smaller?({x, y}, input, rows, columns) do
        true -> [{x, y}] ++ acc
        false -> acc
      end
    end)
    |> Enum.reduce([], fn {x, y}, acc ->
        basin_size = search_basins({x,y}, input)
        [basin_size | acc]
    end)
    |> Enum.sort(& &1 > &2)
    |> (fn [a,b,c | _] -> a * b * c end).()
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {str, row}, acc ->
        str
        |> String.trim()
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {num, column}, acc2 ->
          Map.put(acc2, {row, column}, String.to_integer(num))
        end)
      end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def is_smaller?({x, y}, map, total_rows, total_columns) do
    current = Map.get(map, {x, y})
    count =
      Enum.reduce([{1,0},{0,1},{-1,0},{0,-1}], 0, fn {x1, y1}, count ->
          case current < Map.get(map, {x + x1, y + y1}, 9) do
            true -> count + 1
            false -> count
          end
      end)
    count == 4
  end

  def search_basins({x,y}, map) do
    columns = Enum.filter(map, fn {{x,y}, _num} -> x == 0 end) |> Enum.count()
    rows = Enum.filter(map, fn {{x,y}, _num} -> y == 0 end) |> Enum.count()

    Agent.start(fn -> [{x,y}] end, name: :queue)
    Agent.start(fn -> [{x,y}] end, name: :basin)
    Stream.iterate(1, & &1 + 1)
    |> Enum.reduce_while(0, fn _, acc ->
        get_next_task()
        |> case do
          {:ok, {x1, y1}} ->
#            IO.inspect({x1, y1})
            move_up({x1, y1}, map, rows, columns)
            move_down({x1, y1}, map, rows, columns)
            move_left({x1, y1}, map, rows, columns)
            move_right({x1, y1}, map, rows, columns)
            {:cont, acc}
          _otherwise -> {:halt, nil}
        end
      end)
    result = Agent.get(:basin, fn points ->
#      IO.inspect(points)
      Enum.count(points)
    end)
    Agent.stop(:basin)
    Agent.stop(:queue)
    result
  end

  def move_up({x, y}, map, total_rows, total_columns), do: add_new_task(x - 1, y, map, total_rows, total_columns)
  def move_down({x, y}, map, total_rows, total_columns), do: add_new_task(x + 1, y, map, total_rows, total_columns)
  def move_left({x, y}, map, total_rows, total_columns), do: add_new_task(x, y - 1, map, total_rows, total_columns)
  def move_right({x, y}, map, total_rows, total_columns), do: add_new_task(x, y + 1, map, total_rows, total_columns)

  def get_next_task() do
    Agent.get_and_update(:queue, fn
      [task | rest] -> {{:ok, task}, rest}
      [] -> {{:error, nil}, []}
    end)
  end

  def add_new_task(x, y, map, total_rows, total_columns) do
#    IO.inspect(x)
#    IO.inspect(y)
#    IO.inspect(Map.get(map, {x, y}, 9))
#    IO.inspect("^^^^^^^^^^^^^^^^^^^^^^^^^")
    case Map.get(map, {x, y}, 9) do
      9 -> nil
      _otherwise ->
        (is_coord_new?(x, y) && is_coord_exists?(x, y, total_rows, total_columns))
        |> case do
             true ->
               Agent.update(:basin, fn state -> state ++ [{x, y}] end)
               Agent.update(:queue, fn state -> state ++ [{x, y}] end)
             false -> nil
           end
    end
  end

  def is_coord_exists?(x, y, total_rows, total_columns) do
    x >= 0 && x < total_rows && y >= 0 && y < total_columns
  end
  def is_coord_new?(x, y) do
    Agent.get(:basin, fn state ->
      Enum.filter(state, fn coord -> coord == {x, y} end)
      |> (fn x -> Enum.count(x) == 0 end).()
    end)
  end
end
