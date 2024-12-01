defmodule Aoc2024.Solutions.Y24.Day01 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce([[], []], fn [a, b], [left, right] ->
      [[a | left], [b | right]]
    end)
    |> Enum.map(&Enum.reverse/1)
  end

  def parse_line(line) do
    String.split(line, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part_one([left, right]) do
    left = Enum.sort(left)
    right = Enum.sort(right)

    Enum.zip(left, right)
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  def part_two([left, right]) do
    freq = Enum.frequencies(right)

    Enum.reduce(left, 0, fn num, total ->
      multiplier = Map.get(freq, num, 0)
      total + num * multiplier
    end)
  end
end
