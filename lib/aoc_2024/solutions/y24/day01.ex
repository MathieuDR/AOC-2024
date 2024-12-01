defmodule Aoc2024.Solutions.Y24.Day01 do
  alias AoC.Input

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce([[], []], fn [a, b], [row1, row2] ->
      [[a | row1], [b | row2]]
    end)
    |> Enum.map(&Enum.reverse/1)
  end

  def parse_line(line) do
    String.split(line, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part_one([row1, row2]) do
    row1 = Enum.sort(row1)
    row2 = Enum.sort(row2)

    Enum.zip(row1, row2)
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  def part_two([row1, row2]) do
    freq = calculate_frequency(row2)

    Enum.reduce(row1, 0, fn num, total ->
      multiplier = Map.get(freq, num, 0)
      total + num * multiplier
    end)
  end

  def calculate_frequency(list) do
    Enum.group_by(list, & &1)
    |> Enum.map(fn {key, times} -> {key, Enum.count(times)} end)
    |> Map.new()
  end
end
