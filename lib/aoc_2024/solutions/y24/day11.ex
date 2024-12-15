defmodule Aoc2024.Solutions.Y24.Day11 do
  alias AoC.Input
  use Memoize

  def parse(input, _part) do
    {:ok, _} = Application.ensure_all_started(:memoize)

    Input.read!(input)
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(numbers) do
    Enum.map(numbers, &do_blink(&1, 25))
    |> Enum.sum()
  end

  def part_two(numbers) do
    Enum.map(numbers, &do_blink(&1, 75))
    |> Enum.sum()
  end

  defmemo(do_blink(_, 0), do: 1)
  defmemo(do_blink(0, blinks), do: do_blink(1, blinks - 1))

  defmemo do_blink(num, blinks) do
    digits = trunc(:math.log10(num)) + 1

    if rem(digits, 2) == 0 do
      split(num, digits)
      |> Enum.map(&do_blink(&1, blinks - 1))
      |> Enum.sum()
    else
      do_blink(num * 2024, blinks - 1)
    end
  end

  defmemo split(number, digits) do
    factor =
      :math.pow(10, div(digits, 2))
      |> trunc()

    a = div(number, factor)
    b = number - a * factor

    [a, b]
  end
end
