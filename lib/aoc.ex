defmodule Aoc do
  @moduledoc """
  Documentation for Aoc.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aoc.hello()
      :world

  """
  def create_template do
    for(year <- 2015..2019, day <- 1..25, do: %{year: year, day: day, file: "aoc#{year}_day#{day}.ex", path: "lib/#{year}/"})
    |> Enum.map(fn x ->
      case File.exists?(Map.get(x, :path)) do
        false -> File.mkdir_p(Map.get(x, :path))
        true -> nil
      end
      case File.exists?(Map.get(x, :path) <> Map.get(x, :file)) do
        true -> nil
        false ->
          template = """
defmodule Aoc#{Map.get(x, :year)}Day#{Map.get(x, :day)} do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: \#{inspect part_one()}")
    IO.inspect("Second part answer: \#{inspect part_two()}")
  end

  def part_one() do
    :one
  end

  def part_two() do
    :second
  end

  def parse_file() do
    :parse_file
  end
end
"""
          File.write(Map.get(x, :path) <> Map.get(x, :file), template)
          x
      end
    end)
  end
end
