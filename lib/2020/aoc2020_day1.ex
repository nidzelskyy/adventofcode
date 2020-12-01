defmodule Aoc2020Day1 do
  @moduledoc false

  @quest_file "input1.txt"

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    numbers = parse_file()
    [num1, num2] =
      Enum.reduce(numbers, [nil, nil], fn number1, acc ->
        case Enum.filter(numbers, fn x ->  number1 + x == 2020 end) do
          [] -> acc
          [number2 | _] -> [number1, number2] |> IO.inspect()
        end
      end)

      "Number 1 - #{num1}, Number 2 - #{num2}. Result: #{num1 * num2}"
  end

  def part_two() do
    numbers = parse_file()
    [num1, num2, num3] =
      Enum.reduce(numbers, [nil, nil, nil], fn number1, acc1 ->
        Enum.reduce(numbers, acc1, fn number2, acc2 ->
          case Enum.filter(numbers, fn x ->  number1 + number2 + x == 2020 end) do
            [] -> acc2
            [number3 | _] -> [number1, number2, number3] |> IO.inspect()
          end
        end)
      end)

    "Number 1 - #{num1}, Number 2 - #{num2}, Number3 - #{num3}. Result: #{num1 * num2 * num3}"
  end

  def parse_file() do
    File.stream!("inputs/2020/#{@quest_file}")
    |> Enum.map(fn x ->
      Integer.parse(x, 10)
      |> (fn {i, _} -> i end).()
    end)
  end
end
