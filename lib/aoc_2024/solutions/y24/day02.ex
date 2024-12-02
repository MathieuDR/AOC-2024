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

  def to_diffs(levels) do
    Enum.chunk_every(levels, 2, 1, :discard)
    |> Enum.map(fn [a, b] -> a - b end)
  end

  defp safe?(levels) do
    levels
    |> to_diffs()
    |> safe_transitions()
    |> Enum.all?()
  end

  def problem_dampener(levels) do
    transitions =
      levels
      |> to_diffs()
      |> safe_transitions()

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

  def safe_transitions(diffs) do
    transitions =
      Enum.map(diffs, fn a ->
        absolute_value = abs(a)
        range? = absolute_value > 0 and absolute_value < 4
        positive? = a > 0

        %{positive: range? and positive?, negative: range? and not positive?}
      end)

    pos_trans = Enum.count(transitions, & &1.positive)
    neg_trans = Enum.count(transitions, & &1.negative)

    if pos_trans >= neg_trans do
      Enum.map(transitions, & &1.positive)
    else
      Enum.map(transitions, & &1.negative)
    end
  end
end
