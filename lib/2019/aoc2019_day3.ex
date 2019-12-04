defmodule Aoc2019Day3 do
  @moduledoc false

  def run() do
    IO.inspect("First part answer: #{inspect part_one()}")
    IO.inspect("Second part answer: #{inspect part_two()}")
    :ok
  end

  def part_one() do
    [vector_1, vector_2] =
      parse_file()
      |> Enum.map(& convert_to_vector(&1, [%{x: 0, y: 0, o: nil, steps: 0}]))

    intersections =
      check_pair_intersections(vector_1, vector_2, vector_2, [])
      |> Enum.sort(&(Map.get(&1, :d) < Map.get(&2, :d)))

    intersections
      |> (fn [result | _] -> Map.get(result, :d, nil) end).()
  end

  def part_two() do
    [vector_1, vector_2] =
      parse_file()
      |> Enum.map(& convert_to_vector(&1, [%{x: 0, y: 0, o: nil, steps: 0}]))

    intersections =
      check_pair_intersections(vector_1, vector_2, vector_2, [])
      |> Enum.sort(&( (Map.get(&1, :steps_first) + Map.get(&1, :steps_second)) < (Map.get(&2, :steps_first) + Map.get(&2, :steps_second))))

    intersections
    |> (fn [result | _] -> Map.get(result, :steps_first, 0) + Map.get(result, :steps_second, 0) end).()
  end

  def parse_file() do
    File.stream!("inputs/2019/input3.txt")
    |> Enum.map(&String.trim/1)
    |> Enum.map(& String.split(&1, ","))
  end

  def convert_to_vector(list, res \\ [])
  def convert_to_vector([], res), do: res |> Enum.reverse() #if command lis empty reverse vector list
  def convert_to_vector([current_command | commands], [last | _] = vector) do
    new_vectors = create_vector(current_command, vector, Map.get(last, :steps))
    convert_to_vector(commands, new_vectors)
  end

  #o -> orientation, h -> horizontal, v -> vertical
  def create_vector("R" <> steps, [%{x: x, y: y} | _] = vector, total_steps) do
    [%{x: x + String.to_integer(steps), y: y, o: :h, steps: total_steps + String.to_integer(steps)} | vector]
  end
  def create_vector("L" <> steps, [%{x: x, y: y} | _] = vector, total_steps) do
    [%{x: x - String.to_integer(steps), y: y, o: :h, steps: total_steps + String.to_integer(steps)} | vector]
  end
  def create_vector("U" <> steps, [%{x: x, y: y} | _] = vector, total_steps) do
    [%{x: x, y: y + String.to_integer(steps), o: :v, steps: total_steps + String.to_integer(steps)} | vector]
  end
  def create_vector("D" <> steps, [%{x: x, y: y} | _] = vector, total_steps) do
    [%{x: x, y: y - String.to_integer(steps), o: :v, steps: total_steps + String.to_integer(steps)} | vector]
  end

  def check_pair_intersections(vector_1, vector_2, [_ | vector_2_tl] = vector_2_tail, intersections) when length(vector_1) >= 2 and length(vector_2_tail) >= 2 do
    upd_intersections = check_intersection(Enum.slice(vector_1, 0, 2), Enum.slice(vector_2_tail, 0, 2), intersections)
    check_pair_intersections(vector_1, vector_2, vector_2_tl, upd_intersections)
  end
  def check_pair_intersections([_ | vector_1_tl] = vector_1, vector_2, vector_2_tail, intersections) when length(vector_1) >= 2 and length(vector_2_tail) < 2 do
    check_pair_intersections(vector_1_tl, vector_2, vector_2, intersections)
  end
  def check_pair_intersections(vector_1, _, _, intersections) when length(vector_1) < 2, do: intersections

  def check_intersection(vector_1, vector_2, intersections \\ [])
  def check_intersection([%{x: x, y: y_1_1, steps: steps_1}, %{x: x, y: y_1_2}], [%{x: x_2_1, y: y, steps: steps_2}, %{x: x_2_2, y: y}], intersections) do  #vertical with horizontal
    max_x = max(x_2_1, x_2_2)
    min_x = min(x_2_1, x_2_2)
    max_y = max(y_1_1, y_1_2)
    min_y = min(y_1_1, y_1_2)

    case (max_x >= x && x >= min_x) && (max_y >= y && y >= min_y) do
      true ->
        distance = abs(0 + x) + abs(0 + y)
        steps_first = steps_1 + abs(y - y_1_1)
        steps_second = steps_2 + abs(x - x_2_1)
        intersection = %{x: x, y: y, d: distance, steps_first: steps_first, steps_second: steps_second}
        [intersection | intersections]
      false ->
        intersections
    end
  end
  def check_intersection([%{x: x_1_1, y: y, steps: steps_1}, %{x: x_1_2, y: y}], [%{x: x, y: y_2_1, steps: steps_2}, %{x: x, y: y_2_2}], intersections) do  #horizontal with vertical
    max_x = max(x_1_1, x_1_2)
    min_x = min(x_1_1, x_1_2)
    max_y = max(y_2_1, y_2_2)
    min_y = min(y_2_1, y_2_2)

    case (max_x >= x && x >= min_x) && (max_y >= y && y >= min_y) do
      true ->
        distance = abs(0 + x) + abs(0 + y)
        steps_first = steps_1 + abs(x - x_1_1)
        steps_second = steps_2 + abs(y - y_2_1)
        intersection = %{x: x, y: y, d: distance, steps_first: steps_first, steps_second: steps_second}
        [intersection | intersections]
      false ->
        intersections
    end
  end
  def check_intersection(_, _, intersections), do: intersections

end