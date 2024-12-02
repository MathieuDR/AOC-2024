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
    transitions =
      check_sequence(levels)
      |> IO.inspect()

    if Enum.all?(transitions) do
      true
    else
      case transitions do
        [false, true | _rest] ->
          List.delete_at(levels, 0)
          |> safe?()

        _ ->
          if fixable?(transitions) do
            idx = Enum.find_index(transitions, &(not &1)) + 1

            List.delete_at(levels, idx)
            |> safe?()
          else
            false
          end
      end
    end
  end

  def fixable?(transitions) do
    bad_count =
      Enum.count(transitions, &(not &1))
      |> IO.inspect(label: inspect(transitions))

    cond do
      bad_count == 1 ->
        true

      bad_count > 2 ->
        true

      bad_count == 2 ->
        # We check if it's fixable
        # if they

        Enum.chunk_every(transitions, 3, 1, :discard)
        |> IO.inspect()
        |> Enum.any?(fn
          [false, false, true] -> true
          [true, false, false] -> true
          _ -> false
        end)
    end
  end
end
