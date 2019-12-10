defmodule Aoc2019Day10 do
  @moduledoc false

  @board_size 36

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    base_board =
      parse_file
      |> Stream.with_index()
      |> Enum.map(fn {point_list, index} ->
          {index, Enum.with_index(point_list)}
        end)
      |> Enum.reduce(%{}, fn {line, line_points}, board ->
          Enum.reduce(line_points, board, fn {point, index}, board_2 ->
            point_type = if point == "." do 0 else 1 end
            Map.put(board_2, "#{index}_#{line}", %{type: point_type, angle: nil, x: index, y: line})
          end)
        end)

    create_board_agent(base_board)

    :one
  end

  def part_two() do
    :second
  end

  def parse_file() do
    File.stream!("inputs/2019/input10.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.codepoints/1)
  end

  def create_board_agent(board) do
    case Agent.start(fn -> board end, name: :board_agent) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        {:ok, pid}
    end
  end

  def get_board_point(x, y) do
    Agent.get(:board_agent, fn state -> Map.get(state, "#{x}_#{y}") end)
  end

  def get_board() do
    Agent.get(:board_agent, fn state -> state end)
  end

  def create_point_board_agent(board) do
    case Agent.start(fn -> board end, name: :point_board_agent) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        {:ok, pid}
    end
  end
  def get_point_board_point(x, y) do
    Agent.get(:board_agent, fn state -> Map.get(state, "#{x}_#{y}") end)
  end

  def get_point_board() do
    Agent.get(:board_agent, fn state -> state end)
  end

  #Aoc2019Day10.test
  def test() do
    lines_0 = create_test()
    lines_90 = rotate_90(lines_0)
    lines_180 = rotate_180(lines_0)
    lines_270 = rotate_270(lines_0)

    all_lines = [
      lines_0, lines_90, lines_180, lines_270
    ]
  end

  #Aoc2019Day10.create_test
  def create_test() do
    res =
      Enum.reduce(0..35, %{all: %{}, grouped: []}, fn x, acc ->
        Enum.reduce(0..35, acc, fn y, %{all: all, grouped: grouped} ->
          current_combo =
            Enum.map(1..35, fn a -> {x*a, y*a} end)
            |> Enum.filter(fn {a, b} -> a < 36 && b < 36 && !Map.has_key?(all, "#{a}_#{b}") && (a > 0 || b > 0) end)

          new_all =
            Enum.reduce(current_combo, all, fn {x1, y1}, tuple -> Map.put(tuple, "#{x1}_#{y1}", {x1, y1}) end)
          new_combo =
            if length(current_combo) > 0 do
              grouped ++ [current_combo]
            else
              grouped
            end
          %{all: new_all, grouped: new_combo}
        end)
      end)
      |> Map.get(:grouped)
  end

  def rotate_90(lines) do
    Enum.map(lines, fn line ->
      new_line = Enum.map(line, fn {x, y} -> {x, y * -1} end)
      case length(new_line -- line) > 0 do
        true -> new_line
        false -> []
      end
    end)
    |> Enum.filter(fn a -> length(a) > 0 end)
  end

  def rotate_180(lines) do
    Enum.map(lines, fn line ->
      new_line = Enum.map(line, fn {x, y} -> {x * -1, y * -1} end)
      [{a, b} | _] = new_line
      case length(new_line -- line) > 0 && a != 0 do
        true -> new_line
        false -> []
      end
    end)
    |> Enum.filter(fn a -> length(a) > 0 end)
  end

  def rotate_270(lines) do
    Enum.map(lines, fn line ->
      new_line = Enum.map(line, fn {x, y} -> {x * -1, y} end)
      [{a, b} | _] = new_line
      case length(new_line -- line) > 0 && a != 0 && b != 0 do
        true -> new_line
        false -> []
      end
    end)
    |> Enum.filter(fn a -> length(a) > 0 end)
  end

end
