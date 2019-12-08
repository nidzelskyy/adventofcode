defmodule IntcodeReaderWriter do
  @moduledoc false

  @manual_interactive 0
  @automatic_interactive 1

  def init(type) do
    case Agent.start(fn -> type end, name: :reader_writer) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        reset(type)
        {:ok, pid}
    end
  end

  def reset(type) do
    Agent.update(:reader_writer, fn _state -> type end)
  end

  def get_current_type() do
    Agent.get(:reader_writer, fn state -> state end)
  end

  def read() do
    case get_current_type() do
      @manual_interactive ->
        ManualInput.read()
      @automatic_interactive ->
        AutomaticInput.read()
    end
  end

  def write(number) do
    case get_current_type() do
      @manual_interactive ->
        ManualInput.write(number)
      @automatic_interactive ->
        AutomaticInput.write(number)
    end
  end
end
