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

  def set_point_angle(x, y, angle) do
    Agent.update(:board_agent, fn state ->
        info = Map.get(state, "#{x}_#{y}")
        new_info = Map.put(info, :angle, angle)
        Map.put(state, "#{x}_#{y}", new_info) end)
  end
end
