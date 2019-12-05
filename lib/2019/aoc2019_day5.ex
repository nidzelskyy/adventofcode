defmodule Aoc2019Day5 do
  @moduledoc false

  @position_mode 0
  @immediate_mode 1

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    program_type = get_program_type()
    input = parse_file()
    run_program(program_type, input)
    |> Enum.at(1)
  end

  def part_two() do
    :second
  end

  def parse_file() do
    File.read!("inputs/2019/input5.txt")
    |> String.split(~r/\,/)
    |> Enum.map(fn x -> Integer.parse(x, 10) |> (fn {i, _} -> i end).() end)
  end

  def get_program_type() do
    IO.write( "Enter the program type: ")
    IO.read(:stdio, :line)
    |> String.trim("\n")
    |> String.split(" ")
    |> Enum.map(fn x -> Integer.parse(x) |> elem(0) end)
    |> hd()
  end

  def run_program(0, input) do
    :gravity_program
  end
  def run_program(1, input) do
    program_loop(:start, input)
  end
  def run_program(_, _), do: :unknown_program

  def program_loop(:start, program) do
    {command_type, modes} = read_command(0, program)
    params = read_params(command_type, 0, program)
    {message, new_program} = execute_command(command_type, modes, params, program, 0)
    program_loop(message, length(params) + 1, new_program)
  end
  def program_loop(:next, position, program) do
    {command_type, modes} = read_command(position, program)
    params = read_params(command_type, position, program)
    {message, new_program} = execute_command(command_type, modes, params, program, position)
    program_loop(message, position + length(params) + 1, new_program)
  end
  def program_loop(:finish, _position, program) do
    program
  end

  def read_command(position, program) do
    Enum.at(program, position)
    |> (fn x ->
          String.slice("00000" <> "#{x}", -5..-1)
          |> String.codepoints()
          |> Enum.chunk_every(3)
          |> (fn [params, command] ->  params ++ [Enum.join(command)]  end).()
        end).()
    |> Enum.map(& String.to_integer(&1))
    |> Enum.reverse()
    |> (fn [command | modes] -> {get_command_type(command), modes} end).()
  end

  def get_command_type(command) do
    case command do
      1 -> :add
      2 -> :multi
      3 -> :write
      4 -> :read
      5 -> :jump_true
      6 -> :jump_false
      7 -> :less_than
      8 -> :equals
      99 -> :exit
    end
  end

  def read_params(:add, position, program) do
    [Enum.at(program, position + 1), Enum.at(program, position + 2), Enum.at(program, position + 3)]
  end
  def read_params(:multi, position, program) do
    [Enum.at(program, position + 1), Enum.at(program, position + 2), Enum.at(program, position + 3)]
  end
  def read_params(:read, position, program) do
    [Enum.at(program, position + 1)]
  end
  def read_params(:write, position, program) do
    [Enum.at(program, position + 1)]
  end
  def read_params(:exit, _position, _program) do
    []
  end

  def execute_command(:add, mode, params, program, command_position) do
    first = get_params_value_by_mode(Enum.at(mode, 0), Enum.at(params, 0), program)
    second = get_params_value_by_mode(Enum.at(mode, 1), Enum.at(params, 1), program)
    res = first + second
    new_program = set_param_value_by_mode(Enum.at(mode, 2), Enum.at(params, 2), res, program, command_position + length(params) - 1)
    {:next, new_program}
  end
  def execute_command(:multi, mode, params, program, command_position) do
    first = get_params_value_by_mode(Enum.at(mode, 0), Enum.at(params, 0), program)
    second = get_params_value_by_mode(Enum.at(mode, 1), Enum.at(params, 1), program)
    res = first * second
    new_program = set_param_value_by_mode(Enum.at(mode, 2), Enum.at(params, 2), res, program, command_position + length(params) - 1)
    {:next, new_program}
  end
  def execute_command(:read, mode, params, program, command_position) do
    IO.puts(Enum.at(program, Enum.at(params, 0)))
    {:next, program}
  end
  def execute_command(:write, [mode |_], [param | _] = params, program, command_position) do
    IO.write( "Correct the program: ")
    new_value =
    IO.read(:stdio, :line)
      |> String.trim("\n")
      |> String.split(" ")
      |> Enum.map(fn x -> Integer.parse(x) |> elem(0) end)
      |> hd()
    new_program = set_param_value_by_mode(mode, param, new_value, program, command_position + length(params) - 1)
    {:next, new_program}
  end
  def execute_command(:exit, _mode, _params, program, command_position) do
    {:finish, program}
  end
  def execute_command(_connamd, _mode, _params, program, command_position) do
    IO.inspect("Unknown command")
    {:next, program}
  end

  def get_params_value_by_mode(@position_mode, param, program), do: Enum.at(program, param)
  def get_params_value_by_mode(@immediate_mode, param, _program), do: param

  def set_param_value_by_mode(@position_mode, position, value, program, _command_position), do: List.replace_at(program, position, value)
  def set_param_value_by_mode(@immediate_mode, _position, value, program, command_position), do: List.replace_at(program, command_position, value)
end
