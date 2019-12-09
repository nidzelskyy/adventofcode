defmodule Aoc2018Day1 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    parse_file()
    |> Enum.sum()
  end

  def part_two() do
    info = parse_file()

    Enum.reduce(1..150, %{sum: 0, list: [], catched_sum: nil}, fn x, prev ->
      info
      |> Enum.reduce(prev, fn x, %{sum: sum, list: list, catched_sum: cached_sum} ->
          new_sum = sum + x
          new_list = [new_sum | list]
          case is_nil(cached_sum) do
            true ->
              new_cached =
                case Enum.filter(list, fn exist_sum -> exist_sum == new_sum end) do
                  [hd | _] -> hd
                  [] -> nil
                end
              %{sum: new_sum, list: new_list, catched_sum: new_cached}
            false ->
              new_sum = sum + x
              %{sum: new_sum, list: new_list, catched_sum: cached_sum}
          end
      end)
    end)
    |> Map.get(:catched_sum)
  end

  def parse_file() do
    File.stream!("inputs/2018/input1.txt")
    |> Enum.map(fn x ->
      Integer.parse(x, 10)
      |> (fn {i, _} -> i end).()
    end)
  end
end
