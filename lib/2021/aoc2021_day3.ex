defmodule Aoc2021Day3 do
  @moduledoc false

  @quest_file "input3.txt"
  @test_quest_file "input3_test.txt"

  @needle 2021

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2021Day3.part_one(:prod)
  def part_one(mode) do
    list =
      parse_file(mode)
      |> Enum.map(fn x -> x end)

    acc = Enum.reduce(hd(list), %{}, fn {index, _value}, acc -> Map.put(acc, index, %{0 => 0, 1 => 0}) end)

    {gamma, epsilon} =
      Enum.reduce(list, acc, fn row, acc ->
        Enum.reduce(row, acc, fn {index, value}, acc2 ->
          info = %{0 => zero_sum, 1 => one_sum} = Map.get(acc2, index)
          info =
            case value do
              "0" -> Map.put(info, 0, zero_sum + 1)
              "1" -> Map.put(info, 1, one_sum + 1)
            end
          Map.put(acc2, index, info)
        end)
      end)
      |> Enum.reduce(%{}, fn {index, %{0 => zero_sum, 1 => one_sum}}, acc ->
        case zero_sum > one_sum do
          true -> Map.put(acc, index, 0)
          _ -> Map.put(acc, index, 1)
        end
      end)
      |> (fn map -> Enum.reduce(map, {"", ""}, fn {index, tmp}, {gamma, epsilon} ->
          case tmp == 0 do
            true -> {"#{gamma}0", "#{epsilon}1"}
            false -> {"#{gamma}1", "#{epsilon}0"}
          end
        end) end).()

      String.to_integer(gamma, 2) * String.to_integer(epsilon, 2)
  end

  #Aoc2021Day3.part_two(:prod)
  def part_two(mode) do
    map =
      parse_file(mode)
      |> Enum.map(fn x -> x end)

    bit_length = hd(map) |> Enum.count()
    {oxygen, co2} =
      Enum.reduce(0..(bit_length - 1), {map, map}, fn bit_position, {oxygen, co2} ->
        oxygen_bit = search_most_popular_bit(oxygen, bit_position)
        co2_bit = search_less_popular_bit(co2, bit_position)
        {
          filter_by_popular_bit(oxygen, bit_position, oxygen_bit),
          filter_by_popular_bit(co2, bit_position, co2_bit),
        }
      end)
    oxygen_str =
      oxygen
      |> hd()
      |> Enum.reduce("", fn {_, x}, acc -> acc <> "#{x}" end)
    co2_str =
      co2
      |> hd()
      |> Enum.reduce("", fn {_, x}, acc -> acc <> "#{x}" end)

    String.to_integer(oxygen_str , 2) * String.to_integer(co2_str, 2)
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(&(String.trim(&1) |> String.codepoints() |> Enum.with_index() |> Enum.map(fn {x, i} -> {i, x} end)))
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def search_most_popular_bit(map, bit_position) do
    calculate_bit_position(map, bit_position)
    |> (fn {zero_count, one_count} ->
          cond do
            zero_count > one_count -> "0"
            zero_count < one_count -> "1"
            true -> "1"
          end
        end).()
  end

  def search_less_popular_bit(map, bit_position) do
    calculate_bit_position(map, bit_position)
    |> (fn {zero_count, one_count} ->
      cond do
        zero_count < one_count -> "0"
        zero_count > one_count -> "1"
        true -> "0"
      end
        end).()
  end

  defp calculate_bit_position(map, bit_position) do
    Enum.reduce(map, {0,0}, fn row, {zero_count, one_count} ->
      case Map.get(row |> Map.new(), bit_position) do
        "0" -> {zero_count + 1, one_count}
        "1" -> {zero_count, one_count + 1}
        _ -> {zero_count, one_count}
      end
    end)
  end

  def filter_by_popular_bit(list = [hd | []], _bit_position, _popular_bit), do: list
  def filter_by_popular_bit(map, bit_position, popular_bit) do
    Enum.filter(map, fn list ->
      Map.new(list)
      |> Map.get(bit_position)
      |> (fn x -> x == popular_bit end).()
    end)
  end
end
