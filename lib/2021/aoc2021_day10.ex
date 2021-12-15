defmodule Aoc2021Day10 do
  @moduledoc false

  @quest_file "input10.txt"
  @test_quest_file "input10_test.txt"

  @needle 2021

  #Aoc2021Day10.run(:test)
  #Aoc2021Day10.run(:prod)
  def run(mode \\ :test) do
    IO.inspect("First part answer: #{inspect part_one(mode)}")
    IO.inspect("Second part answer: #{inspect part_two(mode)}")
  end

  #Aoc2021Day10.part_one(:test)
  #Aoc2021Day10.part_one(:prod)
  def part_one(mode) do
    Agent.start(fn -> [] end, [name: :stack])
    result =
      parse_file(mode)
      |> Enum.reduce(0, fn x, acc ->
          sum = Enum.reduce(x, 0, fn codepoint, acc2 ->
          case codepoint in ["(", "[", "{", "<"] do
            true ->
              Agent.update(:stack, fn state -> [codepoint | state] end)
              acc2
            false ->
              last_open_tag =
                Agent.get(:stack, fn state ->
                  case Enum.count(state) > 0 do
                    true -> hd(state)
                    _ -> nil
                  end
                end)
              case is_pair?(last_open_tag, codepoint) do
                true ->
                  Agent.update(:stack, fn [hd | new_state] -> new_state end)
                  acc2
                false ->
                  if(acc2 == 0) do
                    get_costs(codepoint)
                  else
                    acc2
                  end
              end
          end
        end)
        Agent.update(:stack, fn state -> [] end)
        acc + sum
      end)

    Agent.stop(:stack)

    result
  end

  def part_two(mode) do
    Agent.start(fn -> [] end, [name: :stack])
    result =
      parse_file(mode)
      |> Enum.reduce([], fn x, acc ->
          is_good =
            Enum.reduce(x, true, fn codepoint, is_continue ->
              case is_continue do
                true ->
                  case codepoint in ["(", "[", "{", "<"] do
                    true ->
                      Agent.update(:stack, fn state -> [codepoint | state] end)
                      true
                    false ->
                      last_open_tag =
                        Agent.get(:stack, fn state ->
                          case Enum.count(state) > 0 do
                            true -> hd(state)
                            _ -> nil
                          end
                        end)
                      case is_pair?(last_open_tag, codepoint) do
                        true ->
                          Agent.update(:stack, fn [hd | new_state] -> new_state end)
                          true
                        false ->
                          false
                      end
                  end
                false -> false
              end
            end)
        sum =
          case is_good do
            true ->
              rest_list = Agent.get(:stack, fn state -> state end)
              Enum.reduce(rest_list, 0, fn x, acc ->
                (acc * 5) + get_costs2(x)
              end)
            false ->
              0
          end
        Agent.update(:stack, fn state -> [] end)
        case sum > 0 do
          true -> [sum | acc]
          false -> acc
        end
      end)

    Agent.stop(:stack)

    Enum.sort(result) |> Enum.at(div(Enum.count(result), 2))
  end

  def parse_file(mode) do
    File.stream!("inputs/#{@needle}/#{file_name(mode)}")
    |> Stream.map(fn x -> String.trim(x) end)
    |> Enum.map(fn x -> String.codepoints(x) end)
  end

  def file_name(:test), do: @test_quest_file
  def file_name(_), do: @quest_file

  def is_pair?("(", ")"), do: true
  def is_pair?("{", "}"), do: true
  def is_pair?("[", "]"), do: true
  def is_pair?("<", ">"), do: true
  def is_pair?(_, _), do: false

  def get_costs(")"), do: 3
  def get_costs("]"), do: 57
  def get_costs("}"), do: 1197
  def get_costs(">"), do: 25137

  def get_costs2("("), do: 1
  def get_costs2("["), do: 2
  def get_costs2("{"), do: 3
  def get_costs2("<"), do: 4
end
