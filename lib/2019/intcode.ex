defmodule Intcode do
  @moduledoc false

  @position_mode 0
  @immediate_mode 1

  @manual_interactive 0
  @automatic_interactive 1

  def run(input) do
    run(input, @manual_interactive)
  end

  def run(input, interactive_mode) do
    IntcodeReaderWriter.init(interactive_mode)
    create_continue_loop_agent()
    program_loop(:start, input)
  end

  def run(input, interactive_mode, init_state) do
    IntcodeReaderWriter.init(interactive_mode)
    IntcodeStateAgent.init(init_state)
    IntcodeStateAgent.add_to_result(0)
    create_continue_loop_agent()
    program_loop(:start, input)
  end

  def run_cycle_program(input, interactive_mode, init_state) do
    create_continue_loop_agent()
    set_continue_loop_agent(1)
    count_programs = length(init_state)
    IntcodeReaderWriter.init(interactive_mode)
    IntcodeStateAgent.init(init_state)
    IntcodeStateAgent.add_to_result(0)

    continue_state =
      Enum.map(1..count_programs, fn x -> program_loop(:start, input) end)

    result = continue_cycle_program(continue_state)
  end

  def continue_cycle_program(continue_state) do
    IntcodeStateAgent.set_input_agent(2)
    continue_state = Enum.map(continue_state, fn {command, position, program} -> continue_loop(position, program) end)

    case List.last(continue_state) do
      {:finish, _, _} ->
        IntcodeStateAgent.get_last_result()
      _ ->
        continue_cycle_program(continue_state)
    end
  end

  def create_continue_loop_agent() do
    case Agent.start(fn -> 0 end, name: :continue_loop) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        set_continue_loop_agent(0)
        {:ok, pid}
    end
  end

  def set_continue_loop_agent(id) do
    Agent.update(:continue_loop, fn state -> id end)
  end

  def get_loop_state() do
    Agent.get(:continue_loop, fn state -> state end)
  end

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
  def program_loop({:jump, new_position}, _position, program) do
    program_loop(:next, new_position, program)
  end
  def program_loop(:pause_iteration, position, program) do
    {:pause_iteration, position, program}
  end
  def program_loop(:finish, position, program) do
    case get_loop_state() do
      0 ->
        program
      1 ->
        {:finish, position, program}
    end
  end

  def continue_loop(new_position, program) do
    program_loop(:next, new_position, program)
  end

  @doc """
    Reed next command from programs instructions and parse its parameter modes
  """
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

  @doc """
    By command code get its human readable atom
  """
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

  @doc """
    Since each command has a different number of parameters, each command has its own method of extracting parameters
  """
  def read_params(:add, position, program) do
    [Enum.at(program, position + 1), Enum.at(program, position + 2), Enum.at(program, position + 3)]
  end
  def read_params(:multi, position, program) do
    [Enum.at(program, position + 1), Enum.at(program, position + 2), Enum.at(program, position + 3)]
  end
  def read_params(:jump_true, position, program) do
    [Enum.at(program, position + 1), Enum.at(program, position + 2)]
  end
  def read_params(:jump_false, position, program) do
    [Enum.at(program, position + 1), Enum.at(program, position + 2)]
  end
  def read_params(:less_than, position, program) do
    [Enum.at(program, position + 1), Enum.at(program, position + 2), Enum.at(program, position + 3)]
  end
  def read_params(:equals, position, program) do
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

  @doc """
    Each operation has its own execution method.
  """
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
  def execute_command(:jump_true, mode, params, program, command_position) do
    first = get_params_value_by_mode(Enum.at(mode, 0), Enum.at(params, 0), program)
    second = get_params_value_by_mode(Enum.at(mode, 1), Enum.at(params, 1), program)
    case first != 0 do
      true -> {{:jump, second}, program}
      false -> {:next, program}
    end
  end
  def execute_command(:jump_false, mode, params, program, command_position) do
    first = get_params_value_by_mode(Enum.at(mode, 0), Enum.at(params, 0), program)
    second = get_params_value_by_mode(Enum.at(mode, 1), Enum.at(params, 1), program)
    case first == 0 do
      true -> {{:jump, second}, program}
      false -> {:next, program}
    end
  end
  def execute_command(:less_than, mode, params, program, command_position) do
    first  = get_params_value_by_mode(Enum.at(mode, 0), Enum.at(params, 0), program)
    second = get_params_value_by_mode(Enum.at(mode, 1), Enum.at(params, 1), program)
    out    = get_params_value_by_mode(Enum.at(mode, 2), Enum.at(params, 2), program)

    value =
      case first < second do
        true -> 1
        false -> 0
      end
    new_program = set_param_value_by_mode(Enum.at(mode, 2), Enum.at(params, 2), value, program, command_position + length(params) - 1)
    {:next, new_program}
  end
  def execute_command(:equals, mode, params, program, command_position) do
    first = get_params_value_by_mode(Enum.at(mode, 0), Enum.at(params, 0), program)
    second = get_params_value_by_mode(Enum.at(mode, 1), Enum.at(params, 1), program)
    out = get_params_value_by_mode(Enum.at(mode, 2), Enum.at(params, 2), program)

    value =
      case first == second do
        true -> 1
        false -> 0
      end
    new_program = set_param_value_by_mode(Enum.at(mode, 2), Enum.at(params, 2), value, program, command_position + length(params) - 1)
    {:next, new_program}
  end
  def execute_command(:read, mode, params, program, command_position) do
    Enum.at(program, Enum.at(params, 0))
    |> IntcodeReaderWriter.write()

    case get_loop_state() do
      0 ->
        {:next, program}
      1 ->
        {:pause_iteration, program}
    end
  end
  def execute_command(:write, [mode |_], [param | _] = params, program, command_position) do
    new_value = IntcodeReaderWriter.read()
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
