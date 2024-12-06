defmodule Aoc2024.Solutions.Y24.Day06 do
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
            {?., x}, {map, _xBound} -> {map, x}
            {?^, x}, {map, _xBound} -> {Map.put(map, %Coords{x: x, y: y}, :guard), x}
            {?#, x}, {map, _xBound} -> {Map.put(map, %Coords{x: x, y: y}, :obstacle), x}
          end)

        {map, y, xBound}
      end)

    {map, %Coords{x: xBound, y: yBound}}
  end

  def part_one({map, %Coords{} = bounds}) do
    [guard_coords] =
      Map.filter(map, fn
        {_k, :guard} -> true
        {_, _} -> false
      end)
      |> Map.keys()

    map = Map.delete(map, guard_coords)

    # |> IO.inspect(label: "map")

    # IO.inspect(bounds, label: "bounds")

    walk(map, guard_coords, :north, [guard_coords], bounds)
    |> Enum.uniq()
    |> Enum.count()
  end

  def walk(map, location, direction, visitted, bounds) do
    delta = delta(direction)
    new_location = Coords.add(location, delta)

    cond do
      Coords.out_of_bounds(new_location, bounds) ->
        visitted

      Map.get(map, new_location) == :obstacle ->
        new_direction = turn(direction)
        walk(map, location, new_direction, visitted, bounds)

      true ->
        walk(map, new_location, direction, [new_location | visitted], bounds)
    end
  end

  def turn(:north), do: :east
  def turn(:east), do: :south
  def turn(:south), do: :west
  def turn(:west), do: :north

  def delta(:north), do: %Coords{x: 0, y: -1}
  def delta(:east), do: %Coords{x: 1, y: 0}
  def delta(:south), do: %Coords{x: 0, y: 1}
  def delta(:west), do: %Coords{x: -1, y: 0}

  # def part_two(problem) do
  #   problem
  # end
end
