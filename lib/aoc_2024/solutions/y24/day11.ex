defmodule Aoc2024.Solutions.Y24.Day11 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def part_one(numbers) do
    blink_stones(numbers, 25, 5, %{})
    |> Enum.sum()
  end

  def part_two(numbers) do
    blink_stones(numbers, 75, 15, %{})
    |> Enum.sum()
  end

  def blink_stones(nums), do: Enum.flat_map(nums, &do_blink/1)

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

  def blink_stones(numbers, blinks, step, conversion_map) do
    to_do = min(step, blinks)
    # IO.puts("Blinks to do: #{blinks} with #{step} step")

    {numbers, conversion_map} =
      Enum.reduce(numbers, {[], conversion_map}, fn number, {acc, conversion_map} ->
        case Map.get(conversion_map, number) do
          nil ->
            res = blink_stone(number, to_do)
            conversion_map = Map.put(conversion_map, number, res)
            {[res | acc], conversion_map}

          x ->
            {[x | acc], conversion_map}
        end
      end)

    # Enum.count(numbers)
    # |> IO.inspect(label: "#{inspect(blinks - to_do)} blinks remaining for")

    numbers
    |> Enum.map(fn numbers ->
      Task.async(fn ->
        case blinks - to_do do
          0 ->
            [Enum.count(numbers)]

          x ->
            blink_stones(numbers, x, step, conversion_map)
        end
      end)
    end)
    |> Enum.flat_map(&Task.await/1)
  end

  def blink_stone(number, blinks) do
    1..blinks
    |> Enum.reduce([number], fn _blink, stones ->
      Enum.flat_map(stones, &do_blink/1)
    end)
  end
end
