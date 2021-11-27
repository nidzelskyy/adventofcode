defmodule Aoc2015Day5 do
  @moduledoc false

  @year 2015
  @quest_file "input5.txt"
  @test_quest_file "input5_test.txt"

  #Aoc2015Day5.run(:test)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
    :ok
  end

  def part_one(mode) do
    parse_file(mode)
    |> Stream.filter(&filter_by_vowels/1)
    |> Stream.filter(&filter_by_double_char/1)
    |> Stream.filter(&filter_by_bad_combo/1)
    |> Enum.count()
  end

  #Aoc2015Day5.part_two(:test)
  def part_two(mode) do
    parse_file(mode)
    |> Stream.filter(&filter_by_duplicate_pairs/1)
    |> Stream.filter(&filter_by_repeat_letter/1)
    |> Enum.count()
  end

  def parse_file(mode \\ :test) do
    File.stream!("inputs/#{@year}/#{file_name(mode)}")
    |> Stream.with_index()
    |> Stream.map(fn {line, index} -> {index, String.trim(line) |> String.codepoints()} end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def filter_by_vowels({_, string_list}) do
      string_list
      |> Enum.filter(fn x -> x in ["a", "e", "i", "o", "u"] end)
      |> (fn list_vowels -> Enum.count(list_vowels) > 2 end).()
  end

  def filter_by_double_char({_, string_list}) do
    map = codepoints_to_map(string_list)

    Enum.reduce(map, false, fn {index, codepoint}, acc -> acc || Map.get(map, index + 1) == codepoint end)
  end

  def filter_by_bad_combo({num, string_list}) do
    map = codepoints_to_map(string_list)

    Enum.reduce(map, true, fn {index, codepoint}, acc ->
      case codepoint <> Map.get(map, index + 1, "") in ["ab", "cd", "pq", "xy"] do
        true -> false
        false -> acc
      end
    end)
  end

  @doc """
    фільтрує строки які відповідають першому правилу 2-ої частини завдання
  """
  def filter_by_duplicate_pairs({_, string_list}) do
    codepoints_map =
      string_list
      |> Enum.with_index()
      |> Enum.map(fn {letter, index} -> {index, letter} end)
      |> Map.new()

    codepoints_map
    |> create_all_pairs()
    |> Enum.filter(&filter_pairs_by_count/1)
    |> Enum.filter(&filter_pairs_by_length/1)
    |> (fn list -> Enum.count(list) > 0 end).()
  end

  @doc """
    фільтрує строки які відповідають другому правилу 2-ої частини завдання
  """
  def filter_by_repeat_letter({_, string_list}) do
    codepoints_map =
      string_list
      |> Enum.with_index()
      |> Enum.map(fn {letter, index} -> {index, letter} end)
      |> Map.new()

    Enum.reduce(codepoints_map, false, fn {index, letter}, acc ->
      case letter == Map.get(codepoints_map, index + 2, nil) do
        true -> true
        false -> acc
      end
    end)
  end

  @doc """
    створюємо пари сусідніх букв і записуємо їх позиції
    %{"aa" => [0,2,3]}
    пари виступають ключами карти
    позиції першої букви з пари записуються в список, який є значенням карти
  """
  defp create_all_pairs(codepoints_map) do
    list_length = Enum.count(codepoints_map)

    codepoints_map
    |> Enum.reduce(%{}, fn {index, letter}, acc ->
      case index < (list_length - 1) do
        true ->
          pair = letter <> Map.get(codepoints_map, index + 1)
          exists_list = Map.get(acc, pair, [])
          Map.put(acc, pair, exists_list ++ [index])
        false ->
          acc
      end
    end)
  end

  @doc """
    відбираємо тільки ті пари яких є декілька, > 1
  """
  defp filter_pairs_by_count({_pair_key, pair_positions}) do
    Enum.count(pair_positions) > 1
  end

  @doc """
    відбираємо ті пари в яких відстань між позиціями пар > 1
  """
  defp filter_pairs_by_length({_pair_key, pair_positions}) do
    max_length =
      main_calculate_length(pair_positions, [])
      |> Enum.sort(&(&1 >= &2))
      |> hd()
    !is_nil(max_length) && max_length > 1
  end
  defp filter_pairs_by_length(test), do: IO.inspect(test); false

  @doc """
    рекурсивно для кожного значення в списку вираховує довжини з іншини дублюючими парами
  """
  defp main_calculate_length([], acc), do: acc
  defp main_calculate_length([_h | []], acc), do: acc
  defp main_calculate_length([start_point | t], acc) do
    main_calculate_length(t, second_calculate_length(start_point, t, acc))
  end

  @doc """
    для заданої позиції start_point вираховує довжини з парами в хвості списка
  """
  defp second_calculate_length(_start_point, [], acc), do: acc
  defp second_calculate_length(start_point, [current_point | t], acc) do
    second_calculate_length(start_point, t, [current_point - start_point] ++ acc)
  end


  defp codepoints_to_map(string_list) do
    string_list
    |> Stream.with_index()
    |> Stream.map(fn {codepoint, index} -> {index, codepoint} end)
    |> Map.new()
  end
end
