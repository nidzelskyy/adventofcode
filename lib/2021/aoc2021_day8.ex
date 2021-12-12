defmodule Aoc2021Day8 do
  @moduledoc false

  @quest_file "input8.txt"
  @test_quest_file "input8_test.txt"

  @needle 2021

  #Aoc2021Day8.run(:test)
  #Aoc2021Day8.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  #Aoc2021Day8.part_one(:test)
  #Aoc2021Day8.part_one(:prod)
  def part_one(mode) do
    digit_size = %{1 => 2, 4 => 4, 7 => 3, 8 => 7}
    length = Map.values(digit_size)
    input = parse_file(mode)
    Enum.reduce(input, 0, fn {_, %{digits: digits} = _info}, acc ->
      sum =
        Enum.reduce(digits, 0, fn digit, sum ->
          case Enum.count(digit) in length do
            true -> sum + 1
            false -> sum
          end
        end)

      acc + sum
    end)
  end

  #Aoc2021Day8.part_two(:test)
  #Aoc2021Day8.part_two(:prod)
  def part_two(mode) do
    input = parse_file(mode)

    Enum.map(input, fn {i, info} ->
        parse_row(info)
    end)
    |> Enum.reduce(0, fn %{result: result}, acc -> acc + result end)
  end

  def parse_row(row) do
    detect_one(row)
    |> detect_four()
    |> detect_seven()
    |> detect_eight()
    |> detect_three()
    |> detect_nine()
    |> detect_five()
    |> detect_two()
    |> detect_six()
    |> detect_zero()
    |> detect_digits()
  end

  def detect_zero(%{signals: candidate_list, parsed_signals: %{six: six, nine: nine} = parsed_signals} = info) do
    zero =
      candidate_list
      |> Enum.filter(fn x -> Enum.count(x) == 6 end)
      |> Enum.filter(fn x -> Enum.count(nine -- x) != 0 end)
      |> Enum.filter(fn x -> Enum.count(six -- x) != 0 end)
      |> hd()
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :zero, zero))
  end
  def detect_one(%{signals: candidate_list, parsed_signals: parsed_signals} = info) do
    one = Enum.filter(candidate_list, fn x -> Enum.count(x) == 2 end) |> hd
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :one, one))
  end
  def detect_two(%{signals: candidate_list, parsed_signals: %{three: three, five: five} = parsed_signals} = info) do
    two =
      candidate_list
      |> Enum.filter(fn x -> Enum.count(x) == 5 end)
      |> Enum.filter(fn x -> Enum.count(three -- x) != 0 end)
      |> Enum.filter(fn x -> Enum.count(five -- x) != 0 end)
      |> hd()
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :two, two))
  end
  def detect_three(%{signals: candidate_list, parsed_signals: %{seven: seven} = parsed_signals} = info) do
    three =
      candidate_list
      |> Enum.filter(fn x -> Enum.count(x) == 5 end)
      |> Enum.filter(fn x -> Enum.count(seven -- x) == 0 end)
      |> hd()
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :three, three))
  end
  def detect_four(%{signals: candidate_list, parsed_signals: parsed_signals} = info) do
    four = Enum.filter(candidate_list, fn x -> Enum.count(x) == 4 end) |> hd
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :four, four))
  end
  def detect_five(%{signals: candidate_list, parsed_signals: %{three: three, nine: nine} = parsed_signals} = info) do
    five =
      candidate_list
      |> Enum.filter(fn x -> Enum.count(x) == 5 end)
      |> Enum.filter(fn x -> Enum.count(three -- x) != 0 end)
      |> Enum.filter(fn x -> Enum.count(x -- nine) == 0 end)
      |> hd()
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :five, five))
  end
  def detect_six(%{signals: candidate_list, parsed_signals: %{five: five, nine: nine} = parsed_signals} = info) do
    six =
      candidate_list
      |> Enum.filter(fn x -> Enum.count(x) == 6 end)
      |> Enum.filter(fn x -> Enum.count(nine -- x) != 0 end)
      |> Enum.filter(fn x -> Enum.count(five -- x) == 0 end)
      |> hd()
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :six, six))
  end
  def detect_seven(%{signals: candidate_list, parsed_signals: parsed_signals} = info) do
    seven = Enum.filter(candidate_list, fn x -> Enum.count(x) == 3 end) |> hd
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :seven, seven))
  end
  def detect_eight(%{signals: candidate_list, parsed_signals: parsed_signals} = info) do
    eight = Enum.filter(candidate_list, fn x -> Enum.count(x) == 7 end) |> hd
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :eight, eight))
  end
  def detect_nine(%{signals: candidate_list, parsed_signals: %{four: four} = parsed_signals} = info) do
    nine =
      candidate_list
      |> Enum.filter(fn x -> Enum.count(x) == 6 end)
      |> Enum.filter(fn x -> Enum.count(four -- x) == 0 end)
      |> hd()
    Map.put(info, :parsed_signals, Map.put(parsed_signals, :nine, nine))
  end

  def detect_digits(%{parsed_signals: parsed_signals, parsed_digits: parsed_digits, digits: digits} = info) do
    digits_map = %{zero: 0, one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9}
    digit_list =
      Enum.reduce(digits, [], fn digit, acc ->
        d = Enum.sort(digit) |> Enum.join()
        num =
          Enum.reduce(parsed_signals, nil, fn
              {name, signal}, nil ->
                case Enum.sort(signal) |> Enum.join() == d do
                  true -> Map.get(digits_map, name)
                  false -> nil
                end
              _, acc -> acc
          end)
        acc ++ [num]
      end)
    number = Enum.join(digit_list) |> String.to_integer()
    Map.put(info, :parsed_digits, digit_list)
    |> Map.put(:result, number)
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(fn str ->
        str
        |> String.trim()
        |> String.split(" | ")
        |> Enum.map(fn part_str ->
            part_str
            |> String.trim()
            |> String.split(" ")
          end)
      end)
    |> Stream.with_index()
    |> Enum.map(fn {info, index} ->
        signal_list = Enum.at(info, 0)
        digit_list  = Enum.at(info, 1)

        signals = Enum.map(signal_list, fn signal -> String.codepoints(signal) end)
        digits = Enum.map(digit_list, fn digit -> String.codepoints(digit) end)

        {index, %{signals: signals, digits: digits, parsed_digits: [], parsed_signals: %{}}}
      end)
    |> Map.new()
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
end
