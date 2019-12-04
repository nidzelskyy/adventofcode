defmodule Aoc2019Day2 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    #    list = [1,9,10,3,2,3,11,0,99,30,40,50]
    #    list = [1,0,0,0,99]
    #    list = [2,3,0,3,99]
    #    list = [2,4,4,5,99,0]
    #    list = [1,1,1,4,99,5,6,0,99]
    list =
      parse_file()
      |> update_position(1, 12)
      |> update_position(2, 2)

    operation(Enum.slice(list, 0, 4), 1, list) |> hd()
  end

  def part_two() do
    list = parse_file()

      res =
        for(noun <- 0..99, verb <- 0..99, do: %{noun: noun, verb: verb})
        |> Enum.find(fn %{noun: noun, verb: verb} -> result = step_two(noun, verb, list);  Enum.at(result, 0) == 19690720 end)

        100 * res.noun + res.verb
  end

  def step_two(noun, verb, list) do
    prepared_list =
      list
      |> update_position(1, noun)
      |> update_position(2, verb)

    operation(Enum.slice(prepared_list, 0, 4), 1, prepared_list)
  end

  def parse_file() do
    File.read!("inputs/2019/input2.txt")
    |> String.split(~r/\,/)
    |> Enum.map(fn x -> Integer.parse(x, 10) |> (fn {i, _} -> i end).() end)
  end

  def operation([1, inp_1, inp_2, outp] = command, iteration, list) do  #add
    res = Enum.at(list, inp_1) + Enum.at(list, inp_2)
    upd_list = update_position(list, outp, res)
    slice = Enum.slice(upd_list, iteration * 4, 4)

    operation(slice, iteration + 1, upd_list)
  end

  def operation([2, inp_1, inp_2, outp] = command, iteration, list) do #multiply
    res = Enum.at(list, inp_1) * Enum.at(list, inp_2)
    upd_list = update_position(list, outp, res)
    slice = Enum.slice(upd_list, iteration * 4, 4)

    operation(slice, iteration + 1, upd_list)
  end

  def operation([99 | _], _, list) do #finish
    list
  end

  def operation(_, _, list) do #finish
    list
  end

  def update_position(list, pos, value) do
    List.replace_at(list, pos, value)
  end
end
