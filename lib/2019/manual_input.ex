defmodule ManualInput do
  @moduledoc false

  def init() do

  end

  def read() do
    IO.write( "Correct the program: ")
    IO.read(:stdio, :line)
    |> String.trim("\n")
    |> String.split(" ")
    |> Enum.map(fn x -> Integer.parse(x) |> elem(0) end)
    |> hd()
  end

  def write(value) do
    IO.puts(value)
  end
end
