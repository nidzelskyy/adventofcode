defmodule Aoc2015Day10 do
  @moduledoc false

  @input "1321131112"
  @input_test  "1"

  def run() do
#    IO.inspect("First part answer: #{inspect part_one()}")
#    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    step_calc(@input |> String.codepoints(), 0)
    |> String.length()
  end

  def part_two() do
    step_calc(@input |> String.codepoints(), 0)
    |> String.length()
  end

  def step_calc(list, counter \\ 0)
#  def step_calc(list, 40), do: Enum.join(list, "")
  def step_calc(list, 50), do: Enum.join(list, "")
  def step_calc(list, counter) do
    IO.inspect(counter)
    recursion_look_say(list, [])
    |> step_calc(counter + 1)
  end

  def recursion_look_say([], new_list), do: new_list
  def recursion_look_say([head | _] = list, new_list) do
    {current, rest} = Enum.split_while(list, fn x -> x == head end)

    recursion_look_say(rest, new_list ++ (String.codepoints("#{Enum.count(current)}")) ++  [hd(current)])
  end
end
