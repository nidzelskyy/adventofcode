defmodule IntcodeStateAgent do
  @moduledoc false

  def init(init_state) do
    create_input_type_agent()
    create_combinations_agent(init_state)
    create_result_agent()
  end

  def create_input_type_agent() do
    case Agent.start(fn -> 0 end, name: :input_type) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        set_input_agent(0)
        {:ok, pid}
    end
  end

  def next() do
    type = Agent.get_and_update(:input_type, fn state ->
      {info, new_state} =
        case state do
          0 -> {get_next_input(), 1}
          1 -> {get_last_result(), 0}
          2 -> {get_last_result(), 2}
        end
      {info, new_state}
    end)
  end

  def set_input_agent(id) do
    Agent.update(:input_type, fn state -> id end)
  end

  def reset_input_agent() do
    set_input_agent(0)
  end

  def create_result_agent() do
    case Agent.start(fn -> [] end, name: :results) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        reset_result_agent()
        {:ok, pid}
    end
  end

  def add_to_result(number) do
    Agent.update(:results, fn state -> [number | state] end)
  end

  def get_last_result() do
    Agent.get(:results, fn state -> hd(state) end)
  end

  def reset_result_agent() do
    Agent.update(:results, fn _state -> [] end)
  end

  def create_combinations_agent(init_state) do
    case Agent.start(fn -> init_state end, name: :combinations) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        reset_combinations_agent(init_state)
        {:ok, pid}
    end
  end

  def reset_combinations_agent(init_state) do
    Agent.update(:combinations, fn _state -> init_state end)
  end

  def get_count_combinations() do
    info = Agent.get(:combinations, fn state -> state end)
    length(info)
  end

  def get_next_input() do
    [first | _] = Agent.get(:combinations, fn state -> state end)
    Agent.update(:combinations, fn [_hd | tl] -> tl end)
    first
  end
end
