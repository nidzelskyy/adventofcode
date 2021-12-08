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

  def part_two(mode) do
    input = parse_file(mode)

#    parse_row(Map.get(input, 3))

    parsed_rows =
      Enum.map(input, fn {i, info} ->
        IO.inspect(i)
        parse_row(info)
      end)

    Enum.reduce(parsed_rows, 0, fn %{result: result}, acc -> acc + result end)
  end

  def parse_row(row) do
    signals = Map.get(row, :signals)
    digits = Map.get(row, :digits)

    one = detect_one(signals) |> IO.inspect()
    four = detect_four(signals) |> IO.inspect()
    seven = detect_seven(signals) |> IO.inspect()
    eight = detect_eight(signals) |> IO.inspect()

    up = search_up(one, seven)

    five_segment_list = five_segment_list(signals)
    six_segment_list = six_segment_list(signals) |> IO.inspect()

    nine = detect_nine(six_segment_list, four, up) |> IO.inspect()

    six_segment_list = (six_segment_list -- [nine])

    down = search_down(four, nine, up)
    left_down = search_down_left(eight, nine)
    zero = detect_zero(six_segment_list, four, up, down, left_down) |> IO.inspect()
    six = six_segment_list -- [zero] |> hd() |> IO.inspect()

    middle = search_middle(eight, zero)
    right_up = search_up_right(one, six)
    left_up = search_up_left(four, one, middle)
    right_down = search_down_right(one, right_up)
    three = detect_three(five_segment_list, one) |> IO.inspect()

    five_segment_list = five_segment_list -- [three]

    two = detect_two(five_segment_list, right_up) |> IO.inspect()
    five = detect_five(five_segment_list, left_up) |> IO.inspect()

    parsed_signals = %{
      0 => zero |> Enum.sort() |> Enum.join(),
      1 => one |> Enum.sort() |> Enum.join(),
      2 => two |> Enum.sort() |> Enum.join(),
      3 => three |> Enum.sort() |> Enum.join(),
      4 => four |> Enum.sort() |> Enum.join(),
      5 => five |> Enum.sort() |> Enum.join(),
      6 => six |> Enum.sort() |> Enum.join(),
      7 => seven |> Enum.sort() |> Enum.join(),
      8 => eight |> Enum.sort() |> Enum.join(),
      9 => nine |> Enum.sort() |> Enum.join()
    }

    parsed_segment = %{
      up: up,
      down: down,
      middle: middle,
      up_left: left_up,
      up_right: right_up,
      down_left: left_down,
      down_right: right_down
    }
    parsed_digits =
      Enum.map(digits, fn digit ->
        str = digit |> Enum.sort() |> Enum.join()
        {num, _} = Enum.filter(parsed_signals, fn {i, x} ->
          x == str
        end) |> hd()
        num
      end)

    number =
      parsed_digits
      |> Enum.join()
      |> String.to_integer()

      %{row | parsed_digits: parsed_digits, parsed_signals: parsed_signals} |> Map.put(:result, number) |> Map.put(:parsed_segment, parsed_segment)
  end

  def search_up(one, seven), do: (seven -- one) |> hd()
  def search_down(four, nine, up), do: (nine -- [up | four]) |> hd()
  def search_middle(eight, zero), do: (eight -- zero) |> hd()
  def search_up_right(one, six), do: (one -- six) |> hd()
  def search_up_left(four, one, middle), do: (four -- [middle | one]) |> hd()
  def search_down_left(eight, nine), do: (eight -- nine) |> hd()
  def search_down_right(one, right_up), do: (one -- [right_up]) |> hd()

  #2, 3, 5
  def five_segment_list(candidate_list), do: Enum.filter(candidate_list, fn x -> Enum.count(x) == 5 end)
  #0, 6, 9
  def six_segment_list(candidate_list), do: Enum.filter(candidate_list, fn x -> Enum.count(x) == 6 end)

  def detect_zero(candidate_list, four, up, down, left_down) do
    Enum.reduce(candidate_list, nil, fn candidate, acc ->
      upd_candidate = candidate -- [up, down, left_down]
      case Enum.count(four -- upd_candidate) do
        1 -> candidate
        _ -> acc
      end
    end)
  end
  def detect_one(candidate_list), do: Enum.filter(candidate_list, fn x -> Enum.count(x) == 2 end) |> hd
  def detect_two(candidate_list, right_up) do
    Enum.reduce(candidate_list, nil, fn candidate, acc ->
      case right_up in candidate do
        true -> candidate
        _ -> acc
      end
    end)
  end
  def detect_three(candidate_list, one) do
    Enum.reduce(candidate_list, nil, fn candidate, acc ->
      case Enum.count(candidate -- one) do
        3 -> candidate
        _ -> acc
      end
    end)
  end
  def detect_four(candidate_list), do: Enum.filter(candidate_list, fn x -> Enum.count(x) == 4 end) |> hd
  def detect_five(candidate_list, left_up) do
    Enum.reduce(candidate_list, nil, fn candidate, acc ->
      case left_up in candidate do
        true -> candidate
        _ -> acc
      end
    end)
  end
  def detect_six(candidate_list, four, up, down, left_down) do
    Enum.reduce(candidate_list, nil, fn candidate, acc ->
      upd_candidate = candidate -- [up, down, left_down]
      case Enum.count(four -- upd_candidate) do
        0 -> candidate
        _ -> acc
      end
    end)
  end
  def detect_seven(candidate_list), do: Enum.filter(candidate_list, fn x -> Enum.count(x) == 3 end) |> hd
  def detect_eight(candidate_list), do: Enum.filter(candidate_list, fn x -> Enum.count(x) == 7 end) |> hd
  def detect_nine(candidate_list, four, up) do
    Enum.reduce(candidate_list, nil, fn candidate, acc ->
      case Enum.count(candidate -- [up | four]) do
        1 -> candidate
        _ -> acc
      end
    end)
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

        {index, %{signals: signals, digits: digits, parsed_digits: [], parsed_signals: []}}
      end)
    |> Map.new()
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
end
