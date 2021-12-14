defmodule Aoc2021Day14 do
  @moduledoc false

  @quest_file "input14.txt"
  @test_quest_file "input14_test.txt"

  @needle 2021

  #Aoc2021Day14.run(:test)
  #Aoc2021Day14.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  #Aoc2021Day14.part_one(:test)
  #Aoc2021Day14.part_one(:prod)
  def part_one(mode) do
    %{base_task: base_task, instructions: instructions} = parse_file(mode)
    #початковий мап
    chunked = base_task |> Enum.chunk_every(2, 1, :discard)
    #ця буква буде завжди в кінці списку
    last_letter = Enum.at(base_task, Enum.count(base_task) - 1)

    basic_info = Enum.reduce(chunked, %{}, fn key_pair, acc -> Map.put(acc, key_pair, Map.get(acc, key_pair, 0) + 1) end)
    Enum.reduce(1..10, basic_info, fn num, acc ->
#      IO.inspect(num, label: "ITERATION:")
      Enum.reduce(acc, %{}, fn {[a, b] = key, count}, acc ->
        new_letter = Map.get(instructions, key)
        pair_a = [a, new_letter]
        pair_b = [new_letter, b]
        acc
        |> Map.put(pair_a, Map.get(acc, pair_a, 0) + count)
        |> Map.put(pair_b, Map.get(acc, pair_b, 0) + count)
      end)
    end)
    |> Enum.reduce(%{}, fn {[a, _], count}, acc ->
      Map.put(acc, a, Map.get(acc, a, 0) + count)
    end)
    |> Map.new()
    |> (fn acc -> Map.put(acc, last_letter, Map.get(acc, last_letter, 0) + 1) end).()
    |> (fn acc ->
      {max, min} =
        Enum.reduce(acc, {nil, nil}, fn
          {_, count}, {nil, nil} -> {count, count}
          {_, count}, {max, min} -> {Enum.max([count, max]), Enum.min([count, min])}
        end)
      max - min
        end).()
  end

  #Aoc2021Day14.part_two(:test)
  #Aoc2021Day14.part_two(:prod)
  def part_two(mode) do
    %{base_task: base_task, instructions: instructions} = parse_file(mode)
    #початковий мап
    chunked = base_task |> Enum.chunk_every(2, 1, :discard)
    #ця буква буде завжди в кінці списку
    last_letter = Enum.at(base_task, Enum.count(base_task) - 1)

    basic_info = Enum.reduce(chunked, %{}, fn key_pair, acc -> Map.put(acc, key_pair, Map.get(acc, key_pair, 0) + 1) end)
    Enum.reduce(1..40, basic_info, fn num, acc ->
#      IO.inspect(num, label: "ITERATION:")
      Enum.reduce(acc, %{}, fn {[a, b] = key, count}, acc ->
        new_letter = Map.get(instructions, key)
        pair_a = [a, new_letter]
        pair_b = [new_letter, b]
        acc
        |> Map.put(pair_a, Map.get(acc, pair_a, 0) + count)
        |> Map.put(pair_b, Map.get(acc, pair_b, 0) + count)
      end)
    end)
    |> Enum.reduce(%{}, fn {[a, _], count}, acc ->
        Map.put(acc, a, Map.get(acc, a, 0) + count)
      end)
    |> Map.new()
    |> (fn acc -> Map.put(acc, last_letter, Map.get(acc, last_letter, 0) + 1) end).()
    |> (fn acc ->
        {max, min} =
          Enum.reduce(acc, {nil, nil}, fn
            {_, count}, {nil, nil} -> {count, count}
            {_, count}, {max, min} -> {Enum.max([count, max]), Enum.min([count, min])}
          end)
        max - min
        end).()
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(fn str -> str |> String.trim end)
    |> Stream.filter(fn str -> String.length(str) > 0 end)
    |> Enum.reduce(%{base_task: nil, instructions: %{}}, fn str, %{base_task: base_task, instructions: instructions} = acc ->
      case parse_row(str) do
        {:inctruction, key, value} -> Map.put(acc, :instructions, Map.put(instructions, key, value))
        {:base_task, task_list} -> Map.put(acc, :base_task, task_list)
        _otherwise -> acc
      end
    end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
  def parse_row(str) do
    case Regex.match?(~r/([A-Z]{2})\s+\-\>\s+([A-Z]{1})/, str) do
      true ->
        info = Regex.named_captures(~r/(?<base>[A-Z]{2})\s+\-\>\s+(?<result>[A-Z]{1})/, str)
        [a, b] = String.split(Map.get(info, "base"), "", trim: true)
        {:inctruction, [a,b], Map.get(info, "result")}
      false ->
       {:base_task, String.split(str, "", trim: true)}
    end
  end
end
