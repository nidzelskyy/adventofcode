defmodule Aoc2020Day1 do
  @moduledoc false

  @quest_file "input1.txt"
  @test_quest_file "input1_test.txt"

  @needle 2020

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  def part_one(mode) do
    parse_file(mode)
    |> check_two_sum([])
    |> Enum.join("\n")
  end

  def part_two(mode) do
    parse_file(mode)
    |> check_three_sum([])
    |> Enum.join("\n")
  end

  def check_sum(nil, [hd | tl] = list, acc), do: check_sum(hd, tl, acc)
  def check_sum(_, [], acc), do: acc
  def check_sum({num1, num2}, [num3 | tl], acc), do: check_sum({num1, num2}, tl, acc ++ (if(num1 + num2 + num3 == @needle) do ["#{num1} * #{num2} * #{num3} = #{num1 * num2 * num3}"] else [] end))
  def check_sum(num1, [num2 | tl], acc), do: check_sum(num1, tl, acc ++ (if(num1 + num2 == @needle) do ["#{num1} * #{num2} = #{num1 * num2}"] else [] end))
  def check_sum(_, _, acc), do: acc

  def check_two_sum([], acc), do: acc
  def check_two_sum([hd | tl], acc), do: check_two_sum(tl, check_sum(hd, tl, acc))
  def check_two_sum(_, acc), do: acc
  def check_two_sum(const, [hd | tl], acc), do: check_two_sum(const, tl, check_sum({const, hd}, tl, acc))
  def check_two_sum(_, _, acc), do: acc

  def check_three_sum([], acc), do: acc
  def check_three_sum([hd | tl], acc), do: check_three_sum(tl, check_two_sum(hd, tl, acc))
  def check_three_sum(_, acc), do: acc

  def parse_file(mode) do
    File.stream!("inputs/2020/#{file_name(mode)}")
    |> Enum.map(fn x ->
      Integer.parse(x, 10)
      |> (fn {i, _} -> i end).()
    end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
end
