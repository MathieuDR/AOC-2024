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
    calculate_antinode_map(map, bounds, false)
    |> MapSet.size()
  end

  def part_two({map, bounds}) do
    nodes = calculate_antinode_map(map, bounds, true)

    Enum.reduce(map, nodes, fn {_, antennas}, set ->
      Enum.reduce(antennas, set, &MapSet.put(&2, &1))
    end)
    |> MapSet.size()
  end

  def calculate_antinode_map(map, bounds, frequencies) do
    Enum.reduce(map, MapSet.new(), fn {_frequency, locations}, acc ->
      # Chunking them together, drop the one we just had
      Enum.with_index(locations, 1)
      |> Enum.reduce(acc, fn {antenna, i}, acc ->
        # We have other locations, lets create the antinodes
        Enum.drop(locations, i)
        |> Enum.reduce(acc, fn other, acc ->
          [left_stream, right_stream] =
            stream_antinodes(antenna, other)
            |> Enum.map(&take_antinodes(&1, bounds))

          nodes =
            if frequencies do
              Enum.to_list(left_stream) ++ Enum.to_list(right_stream)
            else
              Enum.take(left_stream, 1) ++ Enum.take(right_stream, 1)
            end

          # Put them in set
          Enum.reduce(nodes, acc, &MapSet.put(&2, &1))
        end)
      end)
    end)
  end

  def take_antinodes(stream, bounds),
    do: Stream.take_while(stream, &(not Coords.out_of_bounds(&1, bounds)))

  def stream_antinodes(%Coords{x: x1, y: y1} = coord_1, %Coords{x: x2, y: y2} = coord_2) do
    %Coords{x: dx, y: dy} = Coords.calculate_delta(coord_1, coord_2)

    [
      Stream.map(1..1_000_000, &%Coords{x: x2 - dx * &1, y: y2 - dy * &1}),
      Stream.map(1..1_000_000, &%Coords{x: x1 + dx * &1, y: y1 + dy * &1})
    ]
  end
end
