defmodule Aoc2024.Solutions.Y24.Day02 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn report ->
      String.split(report)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def part_one(problem) do
    problem
    |> Enum.map(&safe?/1)
    |> Enum.count(& &1)
  end

  def part_two(problem) do
    problem
    |> Enum.map(&problem_dampener/1)
    |> Enum.count(& &1)
  end

  defp safe?(levels) do
    levels
    |> check_sequence()
    |> Enum.all?()
  end

  def check_sequence(levels) do
    diffs =
      Enum.chunk_every(levels, 2, 1, :discard)
      |> Enum.map(fn [a, b] -> a - b end)

    direction =
      if Enum.count(diffs, &(&1 > 0)) >= length(levels) / 2, do: :increasing, else: :decreasing

    Enum.map(diffs, fn diff ->
      cond do
        diff == 0 -> false
        abs(diff) > 3 -> false
        direction == :increasing and diff < 0 -> false
        direction == :decreasing and diff > 0 -> false
        true -> true
      end
    end)
  end

  def problem_dampener(levels) do
    transitions = check_sequence(levels)

    if Enum.all?(transitions) do
      true
    else
      case transitions do
        [false, true | _rest] ->
          List.delete_at(levels, 0)
          |> safe?()

        _ ->
          idx = Enum.find_index(transitions, &(not &1)) + 1

          List.delete_at(levels, idx)
          |> safe?()
      end
    end
  end
end
