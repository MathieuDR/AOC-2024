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

  def part_one(plot_graph) do
    group_plots(plot_graph)
    |> calculate_fence(0)
  end

  # def part_two(problem) do
  #   problem
  # end

  def calculate_fence([], acc), do: acc

  def calculate_fence([group | rest], acc) do
    group_fence =
      Enum.reduce(group, 0, fn node, fence ->
        fence + 4 - Enum.count(node.edges)
      end)

    calculate_fence(rest, acc + group_fence * Enum.count(group))
  end

  def group_plots(graph) do
    {grouped_plots, _visited} =
      Enum.reduce(graph, {[], []}, fn {_coord, plot_node}, {grouped_plots, visited_plots} ->
        case Enum.member?(visited_plots, plot_node) do
          true ->
            {grouped_plots, visited_plots}

          false ->
            {_, visited} = depth_first_search(graph, plot_node, [plot_node])
            {[visited | grouped_plots], visited ++ visited_plots}
        end
      end)

    grouped_plots
  end

  def depth_first_search(_graph, %{edges: []}, visited), do: {[], visited}

  def depth_first_search(graph, node, visited) do
    Enum.flat_map_reduce(node.edges, visited, fn {edge, _weight}, visited ->
      edge = Map.get(graph, edge)

      case Enum.member?(visited, edge) do
        true -> {[], visited}
        _ -> depth_first_search(graph, edge, [edge | visited])
      end
    end)
  end
end
