defmodule Aoc2024.Solutions.Y24.Day11 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(numbers) do
    blink_stones(numbers, 25)
    |> Enum.count()
  end

  def part_two(numbers) do
    blink_stones(numbers, 75, 25)
    |> Enum.count()
  end

  def blink(number, map, blinks) do
    case Map.get(map, number) do
      nil ->
        result =
          1..blinks
          |> Enum.reduce([number], fn _, numbers ->
            Enum.flat_map(numbers, &do_blink/1)
          end)

        {result, Map.put(map, number, result)}

      x ->
        {x, map}
    end
  end

  def do_blink(0), do: [1]

  def do_blink(num) do
    digits = trunc(:math.log10(num)) + 1

    if rem(digits, 2) == 0 do
      split(num, digits)
    else
      [num * 2024]
    end
  end

  def split(number, digits) do
    factor =
      :math.pow(10, div(digits, 2))
      |> trunc()

    a = div(number, factor)
    b = number - a * factor

    [a, b]
  end

  def blink_stones(numbers, blinks, blinks_per_round \\ 5) do
    {stones, _conversion_map} =
      1..div(blinks, blinks_per_round)
      |> Enum.reduce({numbers, %{}}, fn i, {stones, conversion_map} ->
        IO.puts("We're about to blink to #{inspect(i * blinks_per_round)} times")
        res = Enum.flat_map_reduce(stones, conversion_map, &blink(&1, &2, blinks_per_round))
        IO.puts("We've blinked #{inspect(i * blinks_per_round)} times")

        res
      end)

    stones
  end
end
