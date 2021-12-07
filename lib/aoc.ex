defmodule Aoc do
  @moduledoc """
  Documentation for Aoc.
  """

  @doc """
  Hello world.
  Aoc.create_template()
  """
  def create_template() do
    for(year <- 2015..DateTime.utc_now.year(), day <- 1..25, do: %{year: year, day: day, file: "aoc#{year}_day#{day}.ex", path: "lib/#{year}/"})
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

  @quest_file "input#{Map.get(x, :day)}.txt"
  @test_quest_file "input#{Map.get(x, :day)}_test.txt"

  @needle #{Map.get(x, :year)}

  #Aoc#{Map.get(x, :year)}Day#{Map.get(x, :day)}.run(:test)
  #Aoc#{Map.get(x, :year)}Day#{Map.get(x, :day)}.run(:prod)
  def run(mode \\\\ :test) do
    IO.inspect("First part answer: \#{inspect part_one(mode)}")
    IO.inspect("Second part answer: \#{inspect part_two(mode)}")
  end

  def part_one(mode) do
    parse_file(mode)
    :one
  end

  def part_two(mode) do
    parse_file(mode)
    :second
  end

  def parse_file(mode) do
    File.stream!("inputs/\#{@needle}/\#{file_name(mode)}")
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file
end
"""
          File.write(Map.get(x, :path) <> Map.get(x, :file), template)
          x
      end
    end)
  end
end
