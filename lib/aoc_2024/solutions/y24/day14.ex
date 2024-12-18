defmodule Aoc2024.Solutions.Y24.Day14 do
  alias Aoc2024.Helpers.Coords
  alias AoC.Input

  def parse(input, _part) do
    robots =
      Input.read!(input)
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [_, px, py, vx, vy] =
          ~r/p=([-\d]*),([-\d]*).*v=([-\d]*),([-\d]*)/u
          |> Regex.run(line)

        %{
          position: %Coords{x: String.to_integer(px), y: String.to_integer(py)},
          velocity: %Coords{x: String.to_integer(vx), y: String.to_integer(vy)}
        }
      end)

    bounds =
      Enum.reduce(robots, %Coords{x: 0, y: 0}, fn %{position: p}, %Coords{x: px, y: py} ->
        px = max(p.x, px)
        py = max(p.y, py)
        %Coords{x: px, y: py}
      end)

    {robots, bounds}
  end

  def part_one({robots, bounds}) do
    robots
    |> Enum.map(&update_position(&1, bounds, 100))
    |> count_robots_in_quadrants(bounds)
    |> Tuple.product()
  end

  def part_two({robots, bounds}) do
    # robots_map = Map.new(robots, fn %{position: p} = robot -> {p, robot} end)

    {_robots, step} =
      Stream.from_index()
      |> Stream.drop(1)
      |> Enum.reduce_while(robots, fn step, robots ->
        robots = Enum.map(robots, &update_position(&1, bounds, 1))
        positions = Enum.map(robots, & &1.position) |> MapSet.new()

        if form_line?(positions) do
          {:halt, {robots, step}}
        else
          {:cont, robots}
        end
      end)

    step
  end

  def form_line?(positions) do
    Enum.reduce(positions, false, fn
      _, true ->
        true

      position, false ->
        form_line?(position, positions)
    end)
  end

  def form_line?(position, positions) do
    1..15
    |> Enum.reduce(true, fn
      _i, false ->
        false

      i, true ->
        MapSet.member?(positions, %Coords{x: position.x, y: position.y + i})
    end)
  end

  def count_robots_in_quadrants(robots, bounds) do
    q =
      %Coords{x: div(bounds.x, 2), y: div(bounds.y, 2)}

    Enum.reduce(robots, {0, 0, 0, 0}, fn %{position: %Coords{x: x, y: y}},
                                         {top_left, top_right, bottom_left, bottom_right} = acc ->
      cond do
        q.x > x and q.y > y ->
          {top_left + 1, top_right, bottom_left, bottom_right}

        q.x < x and q.y > y ->
          {top_left, top_right + 1, bottom_left, bottom_right}

        q.x > x and q.y < y ->
          {top_left, top_right, bottom_left + 1, bottom_right}

        q.x < x and q.y < y ->
          {top_left, top_right, bottom_left, bottom_right + 1}

        true ->
          acc
      end
    end)
  end

  # Helper to check the testing
  def sort(robots) do
    Enum.sort(robots, fn a, b ->
      cond do
        a.y < b.y -> true
        a.y == b.y and a.x <= b.x -> true
        true -> false
      end
    end)
  end

  def update_position(%{position: p, velocity: v} = robot, %Coords{x: xBound, y: yBound}, steps) do
    xDiv = xBound + 1
    yDiv = yBound + 1

    px =
      (p.x + v.x * steps)
      |> rem(xDiv)
      |> Kernel.+(xDiv)
      |> rem(xDiv)

    py =
      (p.y + v.y * steps)
      |> rem(yDiv)
      |> Kernel.+(yDiv)
      |> rem(yDiv)

    %{robot | position: %Coords{x: px, y: py}}
  end
end
