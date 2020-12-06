defmodule Aoc2020Day5 do
  @moduledoc false

  @quest_file "input5.txt"
  @test_quest_file "input5_test.txt"

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    parse_file(mode)
    |> Enum.map(fn line -> search_sit_id(line) end)
    |> Enum.max()
  end

  def part_two(mode) do
    ids =
      parse_file(mode)
      |> Enum.map(fn line -> search_sit_id(line) end)
      |> Enum.sort()

    positioned_ids =
      ids
      |> Enum.with_index()
      |> Enum.map(fn {id, pos} -> {pos, id} end)
      |> Map.new()

    min = Enum.min(ids)

    Enum.reduce(0..(Enum.count(ids) - 1), {[], min}, fn pos, {acc, min} ->
      num = Map.get(positioned_ids, pos)
      if (num != min + pos) do
        {[num - 1] ++ acc, min + 1}
      else
        {acc, min}
      end
    end)
    |> (fn {seat_ids, _} -> hd(seat_ids) end).()
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/2020/#{file_name(mode)}")
    |> Enum.map(fn str ->
        points =
          String.trim(str)
          |> String.codepoints()
        {Enum.take(points, 7), Enum.take(points, -3)}
      end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def search_sit_id({rows_path, cols_path}) do
    row = search_in_diapason(rows_path, 0, 127)
    col = search_in_diapason(cols_path, 0, 7)
    id = row * 8 + col
  end

  def search_in_diapason([letter | path], min, max) do
    {upd_min, upd_max} = get_part_of_range(letter, {min, max})
    row = search_in_diapason(path, upd_min, upd_max)
  end
  def search_in_diapason([], row, row), do: row

  def get_part_of_range("F", {min, max}), do: {min, min + div(max - min, 2)}
  def get_part_of_range("B", {min, max}), do: {min + div(max - min, 2) + 1, max}
  def get_part_of_range("L", {min, max}), do: {min, min + div(max - min, 2)}
  def get_part_of_range("R", {min, max}), do: {min + div(max - min, 2) + 1, max}
end
