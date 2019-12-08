defmodule AutomaticInput do
  @moduledoc false

  def init() do

  end

  def read() do
    IntcodeStateAgent.next()
  end

  def write(value) do
    IntcodeStateAgent.add_to_result(value)
  end
end
