defmodule Aoc2024.Solutions.Y24.Day03 do
  alias AoC.Input

  def parse(input, _part), do: Input.read!(input)

  def part_one(problem) do
    calculate_muls(problem)
  end

  def calculate_muls(input) do
    ~r/mul\((\d*),(\d*)\)/u
    |> Regex.scan(input, capture: :all)
    |> Enum.map(fn [_str, a, b] ->
      String.to_integer(a) * String.to_integer(b)
    end)
    |> Enum.sum()
  end

  def part_two(problem) do
    [ok | dont] = String.split(problem, "don't()", trim: true)

    good =
      Enum.map(dont, fn str ->
        [_ | good] = String.split(str, "do()", trim: true)
        good
      end)

    [ok | good]
    |> Enum.join()
    |> calculate_muls()
  end
end
