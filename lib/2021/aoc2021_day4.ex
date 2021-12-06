defmodule Aoc2021Day4 do
  @moduledoc false

  @quest_file "input4.txt"
  @test_quest_file "input4_test.txt"

  @needle 2021

  @board_size 5

  #Aoc2021Day4.run(:test)
  #Aoc2021Day4.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  #Aoc2021Day4.part_one(:test)
  #Aoc2021Day4.part_one(:prod)
  def part_one(mode) do
    {_board_num, _last_number, _finish_step, total_scope} =
      part_prepare_and_play(mode)
      |> search_first_wined_board()

    total_scope
  end

  #Aoc2021Day4.part_two(:test)
  #Aoc2021Day4.part_two(:prod)
  def part_two(mode) do
    {_board_num, _last_number, _finish_step, total_scope} =
      part_prepare_and_play(mode)
      |> search_last_wined_board()

    total_scope
  end

  def part_prepare_and_play(mode) do
    map =
      parse_file(mode)
      |> Map.new()

    sequence = get_game_sequence(map)
    {_, boards} = parse_boards(map)

    Enum.reduce(boards, %{}, fn {board_number, board_info}, acc ->
      upd_board_info = play_game(sequence, board_info)
      Map.put(acc, board_number, upd_board_info)
    end)
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(&(String.trim(&1)))
    |> Stream.with_index()
    |> Stream.map(fn {x, i} -> {i, x} end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def get_game_sequence(map) do
    Map.get(map, 0)
    |> String.split(",")
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  def parse_boards(map) do
    Enum.reduce(2..(Enum.count(map) - 1), {1, %{}}, fn line_num, {board_num, boards} ->
      case String.length(Map.get(map, line_num)) > 0 do
        true ->
          numbers_map =
            Map.get(map, line_num)
            |> (fn str -> Regex.replace(~r/\s{2}/, str, " ") end).()
            |> String.split(" ")
            |> Enum.with_index()
            |> Enum.map(fn {x, i} -> {i + 1, String.to_integer(x)} end)

          %{board: board, num_positions: num_positions} =
            case Map.get(boards, board_num) do
              nil -> %{board: %{}, num_positions: %{}}
              board_info -> board_info
            end

          row = div(Enum.count(board), @board_size) + 1
          board = Enum.reduce(numbers_map, board, fn {index, num}, acc -> Map.put(acc, {row, index}, {num, 0}) end)
          num_positions = Enum.reduce(numbers_map, num_positions, fn {index, num}, acc -> Map.put(acc, num, {row, index}) end)
          zero_counter = %{1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0}

          upd_boards = Map.put(boards, board_num, %{board: board, num_positions: num_positions, line_counter: zero_counter,
                column_counter: zero_counter, last_number: nil, total_scope: 0, last_step: 0, is_win_board: false})

          next_board_num = if(Enum.count(board) >= (@board_size * @board_size)) do board_num + 1; else board_num end
          {next_board_num, upd_boards}

        false -> {board_num, boards}
      end
    end)
  end

  def play_game(number_sequence, board_info) do
    Enum.reduce_while(number_sequence, board_info, fn number, %{board: board, num_positions: num_positions, line_counter: line_counter, column_counter: column_counter, last_step: last_step} = acc ->
      acc = %{acc | last_step: last_step + 1}
      case Map.get(num_positions, number) do
        nil ->
          {:cont, acc}
        {row, pos} ->
          upd_board = Map.put(board, {row, pos}, {number, 1})
          upd_line_counter   = Map.put(line_counter,   row, Map.get(line_counter, row, 0) + 1)
          upd_column_counter = Map.put(column_counter, pos, Map.get(column_counter, pos, 0) + 1)
          last_line_count   = Map.get(upd_line_counter,   row, 0)
          last_column_count = Map.get(upd_column_counter, pos, 0)

          case last_line_count == @board_size or last_column_count == @board_size do
            true ->
              total_scope = calculate_not_used_count(upd_board) * number
              upd_acc = %{acc | board: upd_board, line_counter: upd_line_counter, column_counter: upd_column_counter, last_number: number, total_scope:  total_scope, is_win_board: true}
              {:halt, upd_acc}
            false ->
              upd_acc = %{acc | board: upd_board, line_counter: upd_line_counter, column_counter: upd_column_counter}
              {:cont, upd_acc}
          end
      end
    end)
  end

  def calculate_not_used_count(board) do
    Enum.reduce(board, 0, fn {_, {num, status}}, acc ->
      case status do
        0 -> acc + num
        _ -> acc
      end
    end)
  end

  def search_first_wined_board(boards) do
    Enum.reduce(boards, {nil, nil, 10_000, nil}, fn {board_number, %{last_step: last_step, total_scope:  total_scope, is_win_board: is_win_board, last_number: number} = _board_info},
                                                    {_win_board_number, _win_number, win_board_step, _win_board_scope} = acc ->
      case is_win_board and last_step < win_board_step do
        true -> {board_number, number, last_step, total_scope}
        false -> acc
      end
    end)
  end

  def search_last_wined_board(boards) do
    Enum.reduce(boards, {nil, nil, 0, nil}, fn {board_number, %{last_step: last_step, total_scope:  total_scope, is_win_board: is_win_board, last_number: number} = _board_info},
                                               {_win_board_number, _win_number, win_board_step, _win_board_scope} = acc ->
      case is_win_board and last_step > win_board_step do
        true -> {board_number, number, last_step, total_scope}
        false -> acc
      end
    end)
  end
end
