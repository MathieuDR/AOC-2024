defmodule Aoc2024.Solutions.Y24.Day16 do
  alias AoC.Input
  alias Aoc2024.Helpers.GridMap
  alias Aoc2024.Helpers.Coords

  def parse(input, _part) do
    {map, _bounds} =
      Input.read!(input)
      |> GridMap.string_to_map(&map_value/1)

    {reindeer_pos, _reindeer_state} =
      Enum.find(map, fn
        {_pos, {:reindeer, :right}} -> true
        _ -> false
      end)

    {end_pos, _} =
      Enum.find(map, fn
        {_, :end} -> true
        _ -> false
      end)

    map =
      Map.put(map, reindeer_pos, :floor)
      |> Map.put(end_pos, :floor)

    graph =
      GridMap.map_to_graph(map, &edge?/2, direction: ~w(up down right left)a)
      |> Map.reject(fn
        {_, %{edges: []}} -> true
        _ -> false
      end)

    %{
      map: map,
      reindeer: {reindeer_pos, :right},
      goal: end_pos,
      graph: graph
    }
  end

  def part_one(%{graph: graph, reindeer: {start, start_direction}, goal: goal}) do
    start_node = Map.get(graph, start)
    # goal_node = Map.get(graph, goal)
    find_paths(graph, start_node, start_direction, goal)
  end

  def find_paths(graph, start, start_direction, goal) do
    dfs(
      graph,
      start,
      [%{pos: start.coord, weigth: 0, direction: start_direction}],
      MapSet.new([start.coord]),
      goal
    )
  end

  def dfs(_graph, %{edges: []}, path, _visited, _goal), do: [path]

  def dfs(_graph, %{coord: goal}, path, _visited, goal) do
    [path]
  end

  def dfs(graph, current_node, [%{direction: direction} | _rest] = path, visited, goal) do
    Enum.flat_map(current_node.edges, fn {edge, weight} ->
      edge_node = Map.get(graph, edge)

      if MapSet.member?(visited, edge) do
        []
      else
        {weight, new_direction} =
          weight_and_direction(weight, {current_node.coord, direction}, edge)

        path_piece = %{pos: edge_node.coord, weight: weight, direction: new_direction}
        path = [path_piece | path]

        visited = MapSet.put(visited, edge)

        dfs(graph, edge_node, path, visited, goal)
      end
    end)
  end

  def weight_and_direction(base_weight, {coords, direction}, new_coords) do
    {1, :right}
  end

  def print_path(path) do
    Enum.map(path, & &1.pos)
    |> IO.inspect(label: "Path")
  end

  def map_value(?#), do: :wall
  def map_value(?.), do: :floor
  def map_value(?S), do: {:reindeer, :right}
  def map_value(?E), do: :end

  def edge?(:wall, _b), do: :no_edge
  def edge?(_a, :wall), do: :no_edge
  def edge?(_a, _b), do: {:edge, 1}

  # def part_two(problem) do
  #   problem
  # end
end
