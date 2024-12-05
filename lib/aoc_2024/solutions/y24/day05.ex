defmodule Aoc2024.Solutions.Y24.Day05 do
  alias AoC.Input

  def parse(input, _part) do
    [instructions, prints] =
      Input.read!(input)
      |> String.split("\n\n", trim: true)

    instructions =
      instructions
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, "|")
        |> Enum.map(&String.to_integer/1)
      end)

    prints =
      prints
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, ",", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)

    {instructions, prints}
  end

  def create_page_lookup(instructions) do
    Enum.reduce(instructions, %{}, fn [a, b], acc ->
      Map.update(acc, b, [a], &[a | &1])
    end)
  end

  def part_one({instructions, prints}) do
    lookup = create_page_lookup(instructions)

    Enum.filter(prints, &valid_print?(&1, lookup))
    # |> IO.inspect(label: "VALID")
    |> Enum.map(&get_middle/1)
    |> Enum.sum()
  end

  defp valid_print?(print, lookup) do
    {valid?, _valid_until} =
      Enum.reduce_while(print, {true, []}, fn
        p, {true, printed} ->
          pre = Map.get(lookup, p)

          case pre do
            nil ->
              {:cont, {true, [p | printed]}}

            needed ->
              if print?(printed, print, needed) do
                {:cont, {true, [p | printed]}}
              else
                {:halt, {false, printed}}
              end
          end
      end)

    valid?
  end

  defp print?(current_print, total_print, pages) do
    Enum.reduce(pages, true, fn
      _, false ->
        false

      page, true ->
        # Can be improved here
        Enum.member?(current_print, page) or not Enum.member?(total_print, page)
    end)
  end

  defp get_middle(list) do
    ln = Enum.count(list)
    idx = floor(ln / 2)
    Enum.at(list, idx)
  end

  # def part_two(problem) do
  #   problem
  # end
end
