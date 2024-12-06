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
    {:no_loop, vissited} = do_walk(map, bounds)

    vissited
    |> Enum.uniq_by(fn {{_dir, coords}, _} -> coords end)
    |> Enum.count()
  end

  def walk(map, location, direction, visitted, bounds) do
    delta = delta(direction)
    new_location = Coords.add(location, delta)

    cond do
      Coords.out_of_bounds(new_location, bounds) ->
        {:no_loop, visitted}

      Map.get(map, new_location) == :obstacle ->
        new_direction = turn(direction)
        walk(map, location, new_direction, visitted, bounds)

      true ->
        entry = {direction, new_location}

        if Map.has_key?(visitted, entry) do
          {:loop, visitted}
        else
          walk(map, new_location, direction, Map.put(visitted, entry, true), bounds)
        end
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

  def part_two({map, %Coords{x: xBound, y: yBound} = bounds}) do
    for x <- 0..xBound, y <- 0..yBound do
      coord = %Coords{x: x, y: y}

      case Map.get(map, coord) do
        nil ->
          Map.put(map, coord, :obstacle)
          |> loop?(bounds)

        _ ->
          false
      end
    end
    |> Enum.count(& &1)
  end

  def loop?(map, bounds) do
    case do_walk(map, bounds) do
      {:no_loop, _} -> false
      {:loop, _} -> true
    end
  end

  def do_walk(map, %Coords{} = bounds) do
    [guard_coords] =
      Map.filter(map, fn
        {_k, :guard} -> true
        {_, _} -> false
      end)
      |> Map.keys()

    map = Map.delete(map, guard_coords)

    walk(map, guard_coords, :north, %{{:north, guard_coords} => true}, bounds)
  end
end
