defmodule Aoc2024.Solutions.Y24.Day12 do
  alias AoC.Input
  alias Aoc2024.Helpers.GridMap

  def parse(input, _part) do
    {map, _bounds} =
      Input.read!(input)
      |> GridMap.string_to_map(& &1)

    GridMap.map_to_graph(map, &edge?/2, directions: ~w(up left right down)a)
  end

  def edge?(current, current), do: {:edge, 0}
  def edge?(_, _), do: :no_edge

  def part_one(problem) do
    problem
  end

  # def part_two(problem) do
  #   problem
  # end
end
