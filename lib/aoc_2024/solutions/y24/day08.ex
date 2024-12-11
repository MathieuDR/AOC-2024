defmodule Aoc2024.Solutions.Y24.Day08 do
  alias AoC.Input

  alias Aoc2024.Helpers.Coords

  def parse(input, _part) do
    {map, yBound, xBound} =
      Input.read!(input)
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce({%{}, 0, 0}, fn {line, y}, {map, _y, _x} ->
        {map, xBound} =
          String.to_charlist(line)
          |> Enum.with_index()
          |> Enum.reduce({map, 0}, fn
            {?., x}, {map, _xBound} ->
              {map, x}

            {antenna, x}, {map, _xBound} ->
              {Map.update(map, antenna, [%Coords{x: x, y: y}], &[%Coords{x: x, y: y} | &1]), x}
          end)

        {map, y, xBound}
      end)

    {map, %Coords{x: xBound, y: yBound}}
  end

  def part_one({map, bounds}) do
    calculate_antinode_map(map, bounds)
    |> MapSet.size()
  end

  def calculate_antinode_map(map, bounds) do
    Enum.reduce(map, MapSet.new(), fn {_frequency, locations}, acc ->
      Enum.with_index(locations, 1)
      |> Enum.reduce(acc, fn {antenna, i}, acc ->
        Enum.drop(locations, i)
        |> Enum.reduce(acc, fn other, acc ->
          calculate_antinodes(antenna, other)
          |> Enum.reject(&Coords.out_of_bounds(&1, bounds))
          |> Enum.reduce(acc, &MapSet.put(&2, &1))
        end)
      end)
    end)
  end

  def calculate_antinodes(%Coords{x: x1, y: y1} = coord_1, %Coords{x: x2, y: y2} = coord_2) do
    %Coords{x: dx, y: dy} = Coords.calculate_delta(coord_1, coord_2)
    [%Coords{x: x2 - dx, y: y2 - dy}, %Coords{x: x1 + dx, y: y1 + dy}]
  end

  # def part_two(problem) do
  #   problem
  # end
end
