defmodule Aoc2020Day8 do
  @moduledoc false

  @quest_file "input8.txt"
  @test_quest_file "input8_test.txt"

  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  def part_one(mode) do
    program = parse_file(mode)
    execute_command(0, 0, [], program)
  end

  def part_two(mode) do
    program = parse_file(mode)
    executed_command =
      get_executed_command_list(0, 0, [], program)
      |> Enum.filter(fn pos ->
          {command, _step} = Map.get(program, pos)
          command in ["nop", "jmp"]
        end)

    Enum.reduce(executed_command, [], fn index, acc ->
      {command, step} = Map.get(program, index)
      new_command =
        case command do
          "nop" -> "jmp"
          "jmp" -> "nop"
        end
      upd_program = Map.put(program, index, {new_command, step})
      case execute_command(0, 0, [], upd_program) do
        {:finish, result} -> acc ++ [result]
        _ -> acc
      end
    end)
    |> hd()
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/2020/#{file_name(mode)}")
    |> Enum.map(fn line -> String.trim(line) end)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index}, acc ->
        [command, step] = String.split(line, " ")
        Map.put(acc, index, {String.trim(command), String.to_integer(step)})
      end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def execute_command(position, acc, executed_list, program) do
    if(position not in executed_list) do
      {new_position, new_acc} =
        case Map.get(program, position) do
          {"nop", step} -> execute_command(position + 1,    acc,       [position] ++ executed_list, program)
          {"acc", add}  -> execute_command(position + 1,    acc + add, [position] ++ executed_list, program)
          {"jmp", step} -> execute_command(position + step, acc,       [position] ++ executed_list, program)
          nil           -> {:finish, acc}
        end
    else
      {:recursive, acc}
    end
  end

  def get_executed_command_list(position, acc, executed_list, program) do
    if(position not in executed_list) do
      {new_position, new_acc} =
        case Map.get(program, position) do
          {"nop", step} -> {position + 1, acc}
          {"acc", add}  -> {position + 1, acc + add}
          {"jmp", step} -> {position + step, acc}
        end
      get_executed_command_list(new_position, new_acc, executed_list ++ [position], program)
    else
      executed_list
    end
  end
end
