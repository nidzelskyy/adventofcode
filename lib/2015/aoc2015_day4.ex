defmodule Aoc2015Day4 do
  @moduledoc false

  @secret "bgvyzdsv"

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    Enum.find(1..100_000_000, fn x ->
     hash = :crypto.hash(:md5, "#{@secret}#{x}") |> Base.encode16(case: :lower)
     Regex.match?(~r/^0{5}/, hash)
    end)
  end

  def part_two() do
    Enum.find(1..100_000_000, fn x ->
      hash = :crypto.hash(:md5, "#{@secret}#{x}") |> Base.encode16(case: :lower)
      Regex.match?(~r/^0{6}/, hash)
    end)
  end

  def parse_file() do
    :parse_file
  end
end
