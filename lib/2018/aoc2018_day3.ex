defmodule Aoc2018Day3 do
  @moduledoc false

  @board_size 1000

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  #Aoc2018Day3.part_one
  def part_one() do
    info =
      parse_file()
      |> List.flatten()
      |> Enum.group_by(fn {line, _range} -> line end, fn {_line, range} -> range end)
      |> Enum.sort_by(fn {line, _range} -> line end)
      |> Enum.map(fn {line, list} ->
          count_duplicate =
            Enum.map(list, fn range ->
              Enum.map(range, fn x -> x end)
            end)
            |> List.flatten()
            |> Enum.group_by(fn x -> x end)
            |> Enum.filter(fn {a, l} -> length(l) > 1 end)
            |> length()

          {line, count_duplicate}
      end)
      |> Enum.reduce(0, fn {line, count}, acc -> acc + count end)
  end

  def part_two() do
    :second
  end

  def parse_file() do
    File.stream!("inputs/2018/input3.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.map(fn line ->
      Regex.named_captures(~r/\#(?<id>\d+)\s@\s(?<padding_left>\d+)\,(?<padding_top>\d+)\:\s(?<width>\d+)x(?<height>\d+)/, line)
    end)
    |> Enum.map(fn %{"padding_left" => padding_left, "padding_top" => padding_top, "width" => width, "height" => height, "id" => id} ->
          ceil_start = String.to_integer(padding_left)
          ceil_count = String.to_integer(width)
          row_start = String.to_integer(padding_top)
          rows_count = String.to_integer(height)
          Enum.reduce((row_start+1)..(row_start+rows_count), [], fn y, acc ->
            [{y, (ceil_start+1)..(ceil_start+ceil_count)} | acc]
          end)
        end)
  end

  def get_empty_board() do
    false_board = for x <- 0..@board_size, do: (for y <- 0..@board_size, do: {"#{x}_#{y}", []})

    board =
      false_board
      |> List.flatten()
      |> Map.new()
  end

  def add_info_to_board(board, info) do
    Enum.reduce(info, board, fn %{padding_left: padding_left, padding_top: padding_top, width: width, height: height, id: id}, board_info ->
      Enum.reduce(padding_top..(height-1), board_info, fn y, acc ->
        Enum.reduce(padding_left..(width-1), acc, fn x, acc2 ->
          name = "#{x}_#{y}"
          Map.put(acc2, name, [id | Map.get(acc2, name, [])])
        end)
      end)
    end)
  end
end
