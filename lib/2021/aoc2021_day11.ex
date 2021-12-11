defmodule Aoc2021Day11 do
  @moduledoc false

  @quest_file "input11.txt"
  @test_quest_file "input11_test.txt"

  @needle 2021

  #Aoc2021Day11.run(:test)
  #Aoc2021Day11.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  #Aoc2021Day11.part_one(:test)
  #Aoc2021Day11.part_one(:prod)
  def part_one(mode) do
    Agent.start(fn  -> [] end, name: :queue)
    Agent.start(fn -> parse_file(mode) end, name: :board)
    result =
      Enum.reduce(0..99, 0, fn step, acc ->
        IO.inspect(step)
        prepare_default_queue()
        emulate_blink()
        blinks = calculate_blink()
        acc + blinks
      end)

    Agent.stop(:queue)
    Agent.stop(:board)
    result
  end

  #Aoc2021Day11.part_two(:test)
  #Aoc2021Day11.part_two(:prod)
  def part_two(mode) do
    Agent.start(fn  -> [] end, name: :queue)
    Agent.start(fn -> parse_file(mode) end, name: :board)
    result =
      Enum.reduce_while(1..10_000, 0, fn step, acc ->
        prepare_default_queue()
        emulate_blink()
        blinks = calculate_blink()
#        IO.inspect("STEP: #{step} - BLINKS: #{blinks} - ACC: #{acc + blinks}")
        case blinks == 100 do
          true -> {:halt, step}
          false -> {:cont, acc + blinks}
        end
      end)

    Agent.stop(:queue)
    Agent.stop(:board)
    result
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(fn str ->
      str
      |> String.trim()
      |> String.codepoints()
      |> Enum.with_index()
    end)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {list, row_index}, acc ->
        Enum.reduce(list, acc, fn {num, index}, acc ->
          Map.put(acc, {row_index, index}, String.to_integer(num))
        end)
      end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def prepare_default_queue(), do: Agent.update(:queue, fn _state -> for x <- 0..9, y <- 0..9, do: {x, y} end)
  def get_queue_size(), do: Agent.get(:queue, fn state -> Enum.count(state) end)
  def get_queue_next(), do: Agent.get_and_update(:queue, fn [x | rest] -> {x, rest} end)
  def queue_add(queue), do: Agent.update(:queue, fn state -> state ++ [queue] end)

  def increment_board_position(index) do
    Agent.update(:board, fn state ->
      num = Map.get(state, index)
      case num + 1 do
        10 ->
          increase_neighbours(index)
          Map.put(state, index, 10)
        upd_num ->
          Map.put(state, index, upd_num)
      end
    end)
  end

  def increase_neighbours({y0, x0}) do
    mask = (for x <- -1..1, y <- -1..1, do: {x, y}) -- [{0,0}]
    Enum.each(mask, fn {y1, x1} ->
      y = y0 + y1
      x = x0 + x1
      case y >= 0 and y < 10 and x >= 0 and x < 10 do
        true -> queue_add({y, x})
        false -> nil
      end
    end)
  end

  def emulate_blink() do
    case get_queue_size() > 0 do
      true ->
        get_queue_next()
        |> increment_board_position()
        emulate_blink()
      false -> nil
    end
  end

  def calculate_blink() do
    Agent.get_and_update(:board, fn state ->
      Enum.reduce(state, {0, %{}}, fn {index, value}, {count, acc} ->
        case value >= 10 do
          true -> {count + 1, Map.put(acc, index, 0)}
          false -> {count,  Map.put(acc, index, value)}
        end
      end)
    end)
  end
end
