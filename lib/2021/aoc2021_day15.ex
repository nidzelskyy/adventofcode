defmodule Aoc2021Day15 do
  @moduledoc false

  @quest_file "input15.txt"
  @test_quest_file "input15_test.txt"

  @needle 2021

  #Aoc2021Day15.run(:test)
  #Aoc2021Day15.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  #Aoc2021Day15.part_one(:test)
  #Aoc2021Day15.part_one(:prod)
  def part_one(mode) do
    Agent.start(fn -> parse_file(mode) end, [name: :board])
    Agent.start(fn -> Enum.reduce(Agent.get(:board, & &1), %{}, fn {coord, _}, acc -> Map.put(acc, coord, nil) end) end, [name: :result_board])

    start_sum = Agent.get(:board, fn state -> Map.get(state, {0, 0}, 0) end)
    size = Agent.get(:board, fn state -> Enum.count(state) |> :math.sqrt() |> round() end)

    Enum.each(0..(size - 1), fn row ->
      Enum.each(0..(size - 1), fn col ->
        cost = Agent.get(:board, fn state -> Map.get(state, {row, col}) end)
        cost_from_up =
          case get_prew_up_sum({row, col}) do
            :not_exists -> nil
            sum -> sum + cost
          end
        cost_from_right =
          case get_prew_right_sum({row, col}) do
            :not_exists -> nil
            sum -> sum + cost
          end
        min_cost = Enum.min([cost_from_up, cost_from_right])
        min_cost = if (is_nil(min_cost)) do cost; else min_cost end
        IO.inspect("#{row} - #{col} - #{min_cost}", label: "iter")
        if(row == 0 && col == 0) do
          Agent.update(:result_board, fn state -> Map.put(state, {row, col}, 0) end)
        else
          Agent.update(:result_board, fn state -> Map.put(state, {row, col}, min_cost) end)
        end
      end)
    end)

    result = Agent.get(:result_board, fn state -> Map.get(state, {size - 1, size - 1}) end) - 17

    Agent.stop(:board)
    Agent.stop(:result_board)

    result
  end

  #Aoc2021Day15.part_two(:test)
  #Aoc2021Day15.part_two(:prod)
  def part_two(mode) do
    parse_file(mode)
    :second
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

  def get_prew_up_sum({x, y} = _coord), do: Agent.get(:result_board, fn state -> Map.get(state, {x - 1, y}, :not_exists) end)
  def get_prew_right_sum({x, y} = _coord), do: Agent.get(:result_board, fn state -> Map.get(state, {x, y - 1}, :not_exists) end)
end
