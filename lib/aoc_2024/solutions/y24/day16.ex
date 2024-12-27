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

  def part_one(%{graph: graph, reindeer: {start, _start_direction}, goal: goal} = problem) do
    start_node = Map.get(graph, start)
    {cost, path} = a_star(graph, start_node, goal)
    print_path(problem, path)
    cost
  end

  def a_star(graph, start, goal) do
    open_set = :gb_sets.singleton({0, start.coord, :right})

    visited = MapSet.new()

    came_from = %{}
    g_scores = %{{start.coord, :right} => 0}

    search(graph, open_set, visited, came_from, g_scores, goal)
  end

  def search(graph, open, closed, came_from, g_scores, goal) do
    if :gb_sets.is_empty(open) do
      :no_path
    else
      {{f_key, current_node_pos, current_direction}, open} = :gb_sets.take_smallest(open)
      current_node = Map.get(graph, current_node_pos)

      if current_node_pos == goal do
        {f_key, reconstruct_path(came_from, {goal, current_direction}, [])}
      else
        closed =
          MapSet.put(closed, {current_node_pos, current_direction})

        # |> IO.inspect()

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

        search(graph, open, closed, came_from, g_scores, goal)
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

      if new_direction not in possible_turns or MapSet.member?(closed, {edge, new_direction}) do
        {open, g_scores, came_from}
      else
        turn_cost = if new_direction == direction, do: 0, else: 1000
        tentative_g = current_g + 1 + turn_cost

        if better_path?(tentative_g, edge, new_direction, g_scores) do
          f = tentative_g + heuristic(edge, goal, new_direction)
          open = add_or_update_set(edge, f, new_direction, open)

          {open, Map.put(g_scores, {edge, new_direction}, tentative_g),
           Map.put(came_from, {edge, new_direction}, {node.coord, direction})}
        else
          {open, g_scores, came_from}
        end
      end
    end)
  end

  def heuristic(a, b, direction) do
    manhatten_distance = Coords.manhatten_distance(a, b)
    x_diff = abs(b.x - a.x)
    y_diff = abs(b.y - a.y)

    # Calculate minimum turns needed
    min_turns =
      cond do
        # If we're moving purely horizontally or vertically
        x_diff == 0 or y_diff == 0 ->
          case direction do
            # Need one turn if going up but need to move horizontally
            :up when x_diff > 0 -> 1
            :down when x_diff > 0 -> 1
            :left when y_diff > 0 -> 1
            :right when y_diff > 0 -> 1
            _ -> 0
          end

        # If we need to move both horizontally and vertically
        true ->
          # We'll need at least one turn to change direction
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

  def reconstruct_path(came_from, last_pos, path) do
    case Map.pop(came_from, last_pos) do
      {nil, _} -> [last_pos | path]
      {parent, came_from} -> reconstruct_path(came_from, parent, [last_pos | path])
    end
  end

  def better_path?(maybe_g, edge, direction, g_scores) do
    case Map.get(g_scores, {edge, direction}) do
      nil -> true
      g_score -> maybe_g < g_score
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

  def print_path(%{map: map, reindeer: {start, _}, goal: goal}, path) do
    coords = Map.keys(map)
    min_x = Enum.min_by(coords, & &1.x).x
    max_x = Enum.max_by(coords, & &1.x).x
    min_y = Enum.min_by(coords, & &1.y).y
    max_y = Enum.max_by(coords, & &1.y).y

    path_set =
      path
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    IO.puts("\nPath Visualization:")

    for y <- min_y..max_y do
      line =
        for x <- min_x..max_x do
          coord = %Coords{x: x, y: y}

          cond do
            coord == start -> "S"
            coord == goal -> "E"
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

  # def part_two(problem) do
  #   problem
  # end
end
