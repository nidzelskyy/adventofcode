defmodule Aoc2019Day8 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    input = parse_file()
    layers = input |> Enum.chunk_every(25 * 6)
    layer_counter =
      Enum.map(layers, fn(layer) ->
        Enum.group_by(layer, fn x -> x end)
        |> Enum.map(fn {k, list} -> {k, length(list)} end)
        |> Map.new()
      end)
      |> Enum.min_by(fn %{0 => count} -> count end) |> IO.inspect()
      |> (fn %{1 => first, 2 => second} -> first * second end).()
#    layers_rows = input |> Enum.chunk_every(25) |> Enum.chunk_every(6) |> IO.inspect()
  end

  def part_two() do
    input = parse_file()
    layers = input |> Enum.chunk_every(25 * 6)
    picture =
      Enum.reduce(layers, [], &overlaying_layers/2)

      |> Enum.chunk_every(25)
      |> Enum.map(fn list -> Enum.join(list) |> String.replace(~r/0/, " ") |> String.replace(~r/1/, "*") end)
      |> Enum.each(fn x -> IO.puts(x) end)
  end

  def parse_file() do
    File.read!("inputs/2019/input8.txt")
    |> String.trim()
    |> String.codepoints()
    |> Enum.map(fn x -> Integer.parse(x, 10) |> (fn {i, _} -> i end).() end)
  end

  def overlaying_layers(new_layer, []) do
    new_layer
  end
  def overlaying_layers(new_layer, picture) do
    new_list =
      new_layer
      |> Enum.with_index
      |> Enum.reduce(picture, fn {pixel, index}, acc ->
          picture_pixel = Enum.at(acc, index)
          result_pixel =
            case picture_pixel < 2 do
              true -> picture_pixel
              false -> pixel
            end
          List.replace_at(acc, index, result_pixel)
        end)
  end
end



0110011110011000011001100
1001000010100100001010010
1001000100100000001010000
1111001000100000001010000
1001010000100101001010010
1001011110011000110001100

