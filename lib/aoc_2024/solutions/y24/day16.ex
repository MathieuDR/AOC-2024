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
      GridMap.map_to_graph(map, &edge?/2, directions: ~w(up down right left)a)
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
    # find_paths(graph, start_node, start_direction, goal)
    a_star(graph, start_node, goal)
  end

  def a_star(graph, start, goal) do
    open_set = :gb_sets.singleton({0, start.coord})

    visited = MapSet.new()

    came_from = %{}
    g_scores = %{start.coord => 0}

    search(graph, open_set, visited, came_from, g_scores, goal)
  end

  def search(graph, open, closed, came_from, g_scores, goal) do
    if :gb_sets.is_empty(open) do
      :no_path
    else
      {{_f_key, current_node_pos}, open} = :gb_sets.take_smallest(open)
      current_node = Map.get(graph, current_node_pos)

      if current_node_pos == goal do
        reconstruct_path(came_from, goal, [])
      else
        closed = MapSet.put(closed, current_node_pos)

        {open, g_scores, came_from} =
          process_edges(graph, current_node, open, closed, g_scores, came_from, goal)

        search(graph, open, closed, came_from, g_scores, goal)
      end
    end
  end

  def process_edges(graph, node, open, closed, g_scores, came_from, goal) do
    current_g = Map.fetch!(g_scores, node.coord)

    Enum.reduce(node.edges, {open, g_scores, came_from}, fn {edge, _weight},
                                                            {open, g_scores, came_from} ->
      edge_node = Map.get(graph, edge)

      if MapSet.member?(closed, edge) do
        {open, g_scores, came_from}
      else
        tentative_g = current_g + to_neighbour(node, edge_node, :right)

        if better_path?(tentative_g, edge, g_scores) do
          f = tentative_g + Coords.manhatten_distance(edge, goal)
          open = add_or_update_set(edge, f, open)
          {open, Map.put(g_scores, edge, tentative_g), Map.put(came_from, edge, node.coord)}
        else
          {open, g_scores, came_from}
        end
      end
    end)
  end

  def add_or_update_set(edge, f, set) do
    case find_in_set(set, edge) do
      nil ->
        :gb_sets.insert({f, edge}, set)

      {old_f, ^edge} ->
        :gb_sets.delete({old_f, edge}, set)
        |> then(&:gb_sets.insert({f, edge}, &1))
    end
  end

  defp find_in_set(set, coords) do
    :gb_sets.iterator(set)
    |> :gb_sets.next()
    |> find_in_set_iter(coords)
  end

  defp find_in_set_iter(:none, _coords), do: nil

  defp find_in_set_iter({{f, coords}, iter}, pos) do
    case coords == pos do
      false -> find_in_set_iter(:gb_sets.next(iter), pos)
      true -> {f, coords}
    end
  end

  def reconstruct_path(came_from, last_pos, path) do
    case Map.pop(came_from, last_pos) do
      {nil, _} -> [last_pos | path]
      {parent, came_from} -> reconstruct_path(came_from, parent, [last_pos | path])
    end
  end

  def better_path?(maybe_g, edge, g_scores) do
    case Map.get(g_scores, edge) do
      nil -> true
      g_score -> maybe_g < g_score
    end
  end

  def to_neighbour(a, b, direction) do
    # To implement, if direction changes +1000
    1
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
