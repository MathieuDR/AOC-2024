defmodule Aoc2024.Solutions.Y24.Day16 do
  alias AoC.Input
  alias Aoc2024.Helpers.GridMap
  alias Aoc2024.Helpers.Coords

  def parse(input, _part) do
    {map, bounds} =
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

    problem = %{
      map: map,
      bounds: bounds,
      reindeer: {reindeer_pos, :right},
      goal: end_pos,
      graph: graph
    }

    Map.put(problem, :result, solve(problem))
  end

  def solve(%{graph: graph, reindeer: {start, _start_direction}, goal: goal}) do
    start_node = Map.get(graph, start)
    a_star(graph, start_node, goal)
  end

  def part_one(%{result: {cost, _nodes}}), do: cost

  def part_two(%{result: {_cost, nodes}} = problem) do
    IO.puts("PROBLEM:\n")
    print_path(problem, %{})
    IO.puts("PATH:\n")
    print_path(problem, nodes)

    nodes
    |> Enum.count()
  end

  def a_star(graph, start, goal) do
    open_set = :gb_sets.singleton({0, start.coord, :right})

    visited = MapSet.new()

    came_from = %{}
    g_scores = %{{start.coord, :right} => 0}

    search(graph, open_set, visited, came_from, g_scores, goal, nil)
  end

  def search(graph, open, closed, came_from, g_scores, goal, lowest_f) do
    if :gb_sets.is_empty(open) do
      if is_nil(lowest_f) do
        :no_path
      else
        {lowest_f, unique_nodes(came_from, goal)}
      end
    else
      {{f_key, current_node_pos, current_direction}, open} = :gb_sets.take_smallest(open)
      current_node = Map.get(graph, current_node_pos)

      cond do
        not is_nil(lowest_f) and f_key > lowest_f ->
          {lowest_f, unique_nodes(came_from, goal)}

        current_node_pos == goal ->
          search(graph, open, closed, came_from, g_scores, goal, f_key)

        true ->
          closed =
            MapSet.put(closed, {current_node_pos, current_direction})

          {open, g_scores, came_from} =
            process_edges(
              graph,
              current_node,
              current_direction,
              open,
              closed,
              g_scores,
              came_from,
              goal
            )

          search(graph, open, closed, came_from, g_scores, goal, lowest_f)
      end
    end
  end

  def process_edges(_graph, node, direction, open, closed, g_scores, came_from, goal) do
    current_g = Map.fetch!(g_scores, {node.coord, direction})

    possible_turns = get_possible_directions(direction)

    Enum.reduce(node.edges, {open, g_scores, came_from}, fn {edge, _weight},
                                                            {open, g_scores, came_from} ->
      new_direction =
        calculate_direction(node.coord, edge)

      turn_cost = if new_direction == direction, do: 0, else: 1000
      tentative_g = current_g + 1 + turn_cost
      edge_best_g = Map.get(g_scores, {edge, new_direction})

      if new_direction not in possible_turns or
           (MapSet.member?(closed, {edge, new_direction}) and
              not is_nil(edge_best_g) and
              edge_best_g < tentative_g) do
        {open, g_scores, came_from}
      else
        case path_type(tentative_g, edge, new_direction, g_scores) do
          :worse ->
            {open, g_scores, came_from}

          path_type when path_type in [:new, :better, :equal] ->
            f = tentative_g + heuristic(edge, goal, new_direction)
            open = add_or_update_set(edge, f, new_direction, open)

            parent_tuple = {node.coord, direction}
            edge_tuple = {edge, new_direction}

            came_from = insert_path(came_from, path_type, edge_tuple, parent_tuple)

            {open, Map.put(g_scores, edge_tuple, tentative_g), came_from}
        end
      end
    end)
  end

  def insert_path(came_from, :equal, edge_tuple, parent_tuple),
    do: Map.update(came_from, edge_tuple, [parent_tuple], fn a -> [parent_tuple | a] end)

  def insert_path(came_from, _new_or_better, edge_tuple, parent_tuple),
    do: Map.put(came_from, edge_tuple, [parent_tuple])

  def heuristic(a, b, direction) do
    manhatten_distance = Coords.manhatten_distance(a, b)
    x_diff = abs(b.x - a.x)
    y_diff = abs(b.y - a.y)

    min_turns =
      cond do
        x_diff == 0 or y_diff == 0 ->
          case direction do
            :up when x_diff > 0 -> 1
            :down when x_diff > 0 -> 1
            :left when y_diff > 0 -> 1
            :right when y_diff > 0 -> 1
            _ -> 0
          end

        true ->
          1
      end

    min_turns * 500 + manhatten_distance
  end

  def calculate_direction(a, b) do
    cond do
      a.x == b.x and a.y == b.y + 1 -> :up
      a.x == b.x and a.y == b.y - 1 -> :down
      a.x == b.x + 1 and a.y == b.y -> :left
      a.x == b.x - 1 and a.y == b.y -> :right
    end
  end

  def add_or_update_set(edge, f, dir, set) do
    case find_in_set(set, edge, dir) do
      nil ->
        :gb_sets.insert({f, edge, dir}, set)

      {old_f, ^edge, ^dir} ->
        :gb_sets.delete({old_f, edge, dir}, set)
        |> then(&:gb_sets.insert({f, edge, dir}, &1))
    end
  end

  defp find_in_set(set, coords, dir) do
    :gb_sets.iterator(set)
    |> :gb_sets.next()
    |> find_in_set_iter(coords, dir)
  end

  defp find_in_set_iter(:none, _coords, _dir), do: nil

  defp find_in_set_iter({{f, coords, dir}, iter}, pos, searched_dir) do
    case coords == pos and dir == searched_dir do
      false -> find_in_set_iter(:gb_sets.next(iter), pos, searched_dir)
      true -> {f, coords, dir}
    end
  end

  def unique_nodes(came_from, goal) do
    visited = MapSet.new()

    Enum.filter(came_from, fn
      {{^goal, _}, _} -> true
      _ -> false
    end)
    |> Enum.reduce(visited, fn {key, parents}, visited ->
      collect_nodes(came_from, parents, MapSet.put(visited, key))
    end)
    |> MapSet.new(&elem(&1, 0))
  end

  def collect_nodes(_came_from, [], visited), do: visited

  def collect_nodes(came_from, [parent | rest], visited) do
    if MapSet.member?(visited, parent) do
      collect_nodes(came_from, rest, visited)
    else
      visited = MapSet.put(visited, parent)

      case Map.get(came_from, parent) do
        nil ->
          collect_nodes(came_from, rest, visited)

        parents ->
          collect_nodes(came_from, rest ++ parents, visited)
      end
    end
  end

  def path_type(maybe_g, edge, direction, g_scores) do
    case Map.get(g_scores, {edge, direction}) do
      nil -> :new
      g_score when g_score > maybe_g -> :better
      g_score when g_score == maybe_g -> :equal
      _ -> :worse
    end
  end

  def get_possible_directions(:up), do: [:up, :left, :right]
  def get_possible_directions(:down), do: [:down, :left, :right]
  def get_possible_directions(:left), do: [:left, :up, :down]
  def get_possible_directions(:right), do: [:right, :up, :down]

  def map_value(?#), do: :wall
  def map_value(?.), do: :floor
  def map_value(?S), do: {:reindeer, :right}
  def map_value(?E), do: :end

  def edge?(:floor, :floor), do: {:edge, 1}
  def edge?(_a, _b), do: :no_edge

  def print_path(%{map: map, bounds: bounds, reindeer: {start, _}, goal: goal}, path) do
    min_x = 0
    max_x = bounds.x
    min_y = 0
    max_y = bounds.y

    path_set = MapSet.new(path)

    IO.puts("\nPath Visualization:")

    for y <- min_y..max_y do
      line =
        for x <- min_x..max_x do
          coord = %Coords{x: x, y: y}

          cond do
            MapSet.member?(path_set, coord) and coord == start -> "S"
            MapSet.member?(path_set, coord) and coord == goal -> "E"
            coord == start -> "s"
            coord == goal -> "e"
            MapSet.member?(path_set, coord) -> "○"  
            map[coord] == :wall -> "#"
            map[coord] == :floor -> "."
            true -> " "
          end
        end

      IO.puts(Enum.join(line))
    end

    IO.puts("")
  end
end
