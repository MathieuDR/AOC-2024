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

    lookup = create_page_lookup(instructions)

    {instructions, prints, lookup}
  end

  def create_page_lookup(instructions) do
    Enum.reduce(instructions, %{}, fn [a, b], acc ->
      Map.update(acc, b, [a], &[a | &1])
    end)
  end

  def part_one({_instructions, prints, lookup}) do
    Enum.filter(prints, &valid_print?(&1, lookup))
    |> Enum.map(&get_middle/1)
    |> Enum.sum()
  end

  defp valid_print?(print, lookup) do
    {valid?, _valid_until} = get_valid_print(print, lookup)
    valid?
  end

  # TODO: Refactor with part 2, too lazy now
  defp get_valid_print(print, lookup) do
    Enum.reduce_while(print, {true, []}, fn
      p, {true, printed} ->
        pre = Map.get(lookup, p)

        case pre do
          nil ->
            {:cont, {true, [p | printed]}}

          needed ->
            if do_print?(printed, print, needed) do
              {:cont, {true, [p | printed]}}
            else
              {:halt, {false, printed}}
            end
        end
    end)
  end

  # TODO: Can be merged with can_print
  defp do_print?(current_print, total_print, pages) do
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

  def part_two({_instructions, prints, lookup}) do
    Enum.reject(prints, &valid_print?(&1, lookup))
    |> Enum.map(fn bad_print ->
      order_print(bad_print, lookup)
      |> get_middle()
    end)
    |> Enum.sum()
  end

  def order_print(bad_print, lookup) do
    {_, good_part} = get_valid_print(bad_print, lookup)

    bad_part =
      Enum.drop(bad_print, Enum.count(good_part))

    ordered =
      do_order(bad_part, [], [], lookup)

    good_part ++ ordered
  end

  def do_order([], printed, [], _), do: Enum.reverse(printed)

  def do_order([next], printed, skipped, lookup) do
    printed = [next | printed]
    skipped = Enum.reverse(skipped)
    do_order(skipped, printed, [], lookup)
  end

  def do_order([next | rest], printed, skipped, lookup) do
    if can_print?(next, [skipped | rest], lookup) do
      printed = [next | printed]
      skipped = Enum.reverse(skipped)
      do_order(skipped ++ rest, printed, [], lookup)
    else
      do_order(rest, printed, [next | skipped], lookup)
    end
  end

  defp can_print?(current_page, print_buffer, lookup) do
    case Map.get(lookup, current_page) do
      nil ->
        true

      prerequisites ->
        Enum.reduce(prerequisites, true, fn
          _, false ->
            false

          p, true ->
            not Enum.member?(print_buffer, p)
        end)
    end
  end

  def get_first_page(page, pages_to_print, lookup) do
    Map.get(lookup, pages_to_print)
    |> case do
      nil -> page
      pages -> Enum.filter(pages, fn p -> Enum.member?(pages_to_print, p) end)
    end
  end
end
