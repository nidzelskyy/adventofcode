defmodule Aoc2021Day13 do
  @moduledoc false

  @quest_file "input13.txt"
  @test_quest_file "input13_test.txt"

  @needle 2021

  #Aoc2021Day13.run(:test)
  #Aoc2021Day13.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  #Aoc2021Day13.part_one(:test)
  #Aoc2021Day13.part_one(:prod)
  def part_one(mode) do
    input = parse_file(mode)
    board = create_board(input)
    folds = Map.get(input, :folds)
    {type, value} = folds |> hd()
    upd_board = fold(type, value, board)
    calculate_count(upd_board)
  end

  #Aoc2021Day13.part_two(:test)
  #Aoc2021Day13.part_two(:prod)
  def part_two(mode) do
    input = parse_file(mode)
    board = create_board(input)
    folds = Map.get(input, :folds)
    upd_board =
      Enum.reduce(folds, board, fn {type, value}, board ->
        fold(type, value, board)
      end)
    print_board(upd_board)
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(fn str -> String.trim(str) end)
    |> Enum.reduce(%{coord: %{}, folds: []}, fn str, %{coord: coords, folds: folds} = acc ->
        case parse_command(str) do
          {:fold_y, y} -> Map.put(acc, :folds, folds ++ [{:y, y}])
          {:fold_x, x} -> Map.put(acc, :folds, folds ++ [{:x, x}])
          {:point, coord} -> Map.put(acc, :coord, Map.put(coords, coord, coord))
          _ -> acc
        end
      end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def parse_command("fold along y=" <> y), do: {:fold_y, String.to_integer(y)}
  def parse_command("fold along x=" <> x), do: {:fold_x, String.to_integer(x)}
  def parse_command(""), do: nil
  def parse_command(coord_str) do
    String.split(coord_str, ",")
    |> Enum.reduce([], fn num, acc -> acc ++ [String.to_integer(num)] end)
    |> (fn [col, row] -> {:point, {row, col}} end).()
  end

  def create_board(input) do
    {rows, columns} = search_board_size(Map.get(input, :coord))
    points = Map.get(input, :coord)
    board =
       for row <- 0..rows, column <- 0..columns, into: %{} do
        {{row, column}, if (Map.has_key?(points, {row, column})) do 1; else 0 end }
       end
  end

  def search_board_size(coordinates) do
    Enum.reduce(coordinates, {_row = 0, _col = 0}, fn {{y1, x1}, _}, {y, x} ->
     { Enum.max([y1, y]), Enum.max([x1, x]) }
    end)
  end

  def fold(:y, y, board) do
    new_board =
      Enum.reduce(board, %{}, fn {{row, col}, num}, acc ->
        case row == y do
          true -> acc
          false ->
            case row > y do
              false ->
                Map.put(acc, {row, col}, Enum.max([Map.get(acc, {row, col}, 0), num]))
              true ->
                new_y = 2 * y - row
                Map.put(acc, {new_y, col}, Enum.max([Map.get(acc, {new_y, col}, 0), num]))
            end
        end
      end)
  end
  def fold(:x, x, board) do
    new_board =
      Enum.reduce(board, %{}, fn {{row, col}, num}, acc ->
        case col == x do
          true -> acc
          false ->
            case col > x do
              false ->
                Map.put(acc, {row, col}, Enum.max([Map.get(acc, {row, col}, 0), num]))
              true ->
                new_x = 2 * x - col
                Map.put(acc, {row, new_x}, Enum.max([Map.get(acc, {row, new_x}, 0), num]))
            end
        end
      end)
  end

  def calculate_count(board), do: Enum.reduce(board, 0, fn {_, num}, acc -> acc + num end)

  def print_board(board) do
    {rows, cols} = search_board_size(board)
    Enum.each(0..rows, fn row ->
      row_elems =
        Enum.reduce(0..cols, [], fn col, acc ->
          case Map.get(board, {row, col}) do
            0 -> acc ++ ["."]
            1 -> acc ++ ["#"]
          end
      end)
      IO.puts(Enum.join(row_elems))
    end)
  end
end
