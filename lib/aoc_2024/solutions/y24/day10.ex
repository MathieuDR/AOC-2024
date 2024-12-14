defmodule Aoc2024.Solutions.Y24.Day10 do
  alias AoC.Input
  alias Aoc2024.Helpers.Coords

  def parse(input, _part) do
    {map, yBound, xBound} =
      Input.read!(input)
      |> to_map()

    {map, %Coords{x: xBound, y: yBound}}
  end

  def to_map(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({%{}, 0, 0}, fn {line, y}, {map, _y, _x} ->
      {map, xBound} =
        String.to_charlist(line)
        |> Enum.with_index()
        |> Enum.reduce({map, 0}, fn
          {char, x}, {map, _xBound} ->
            value = to_value(char)
            coord = %Coords{x: x, y: y}
            map = Map.put(map, coord, value)
            {map, x}
        end)

      {map, y, xBound}
    end)
  end

  def to_value(?.), do: :impassable
  def to_value(x) when x in ?0..?9, do: x - 48

  @directions ~w(up right down left)a
  def to_graph(map, opts) do
    Enum.reduce(map, %{}, fn
      {_coord, :impassable}, acc ->
        acc

      {coord, height}, acc ->
        edges =
          find_edges(map, coord, height, opts)

        node = %{
          value: height,
          edges: edges,
          coord: coord
        }

        Map.put(acc, coord, node)
    end)
  end

  def find_edges(map, coord, height, opts \\ []) do
    directions = Keyword.get(opts, :directions)
    delta = Keyword.get(opts, :max_delta)

    Enum.reduce(directions, [], fn direction, acc ->
      to_check = get_delta(coord, direction)

      Map.get(map, to_check)
      |> case do
        x
        when x - height <= delta and x - height > 0 ->
          [{to_check, x - height} | acc]

        _ ->
          acc
      end
    end)
  end

  def get_delta(%Coords{x: x, y: y}, :up), do: %Coords{x: x, y: y - 1}
  def get_delta(%Coords{x: x, y: y}, :down), do: %Coords{x: x, y: y + 1}
  def get_delta(%Coords{x: x, y: y}, :right), do: %Coords{x: x + 1, y: y}
  def get_delta(%Coords{x: x, y: y}, :left), do: %Coords{x: x - 1, y: y}

  def part_one({map, _bounds}) do
    graph =
      to_graph(map, max_delta: 1, directions: @directions)
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
      to_graph(map, max_delta: 1, directions: @directions)
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
