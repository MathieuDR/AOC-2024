defmodule Aoc2024.Solutions.Y24.Day10 do
  alias AoC.Input
  alias Aoc2024.Helpers.GridMap

  def parse(input, _part) do
    {map, bounds} =
      Input.read!(input)
      |> GridMap.string_to_map(&to_value/1)

    {map, bounds}
  end

  def to_value(?.), do: :impassable
  def to_value(x) when x in ?0..?9, do: x - 48

  @max_delta 1
  def edge?(current, _) when not is_integer(current), do: :no_edge
  def edge?(_, edge) when not is_integer(edge), do: :no_edge

  def edge?(value, edge) when edge - value <= @max_delta and edge - value > 0,
    do: {:edge, edge - value}

  def edge?(_, _), do: :no_edge

  @directions ~w(up right down left)a
  def part_one({map, _bounds}) do
    graph =
      GridMap.map_to_graph(map, &edge?/2, directions: @directions)
      |> Map.new()

    graph
    |> Enum.reduce([], fn
      {_coord, %{value: 0} = node}, acc -> [node | acc]
      _, acc -> acc
    end)
    |> find_paths(graph, 9)
    |> Enum.map(fn paths ->
      Enum.map(paths, &hd/1)
      |> Enum.uniq()
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def part_two({map, _bounds}) do
    graph =
      GridMap.map_to_graph(map, &edge?/2, directions: @directions)
      |> Map.new()

    graph
    |> Enum.reduce([], fn
      {_coord, %{value: 0} = node}, acc -> [node | acc]
      _, acc -> acc
    end)
    |> find_paths(graph, 9)
    |> Enum.map(fn paths ->
      Enum.uniq(paths)
      |> Enum.count()
    end)
    |> Enum.sum()
  end

  def find_paths(starts, graph, goal) do
    Enum.map(starts, fn start ->
      depth_first_search(graph, start, [start])
      |> Enum.filter(fn path -> Enum.count(path, &(&1.value == goal)) > 0 end)
    end)
    |> Enum.uniq()
  end

  def depth_first_search(_graph, %{edges: []}, path), do: [path]

  def depth_first_search(graph, node, path) do
    Enum.flat_map(node.edges, fn {edge, _weight} ->
      edge = Map.get(graph, edge)
      depth_first_search(graph, edge, [edge | path])
    end)
  end
end
