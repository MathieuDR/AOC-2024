defmodule Aoc2024.Solutions.Y24.Day12 do
  alias AoC.Input
  alias Aoc2024.Helpers.GridMap

  def parse(input, _part) do
    {map, _bounds} =
      Input.read!(input)
      |> GridMap.string_to_map(& &1)

    GridMap.map_to_graph(map, &edge?/2, directions: ~w(up left right down)a)
    |> group_plots()
  end

  def edge?(current, current), do: {:edge, 0}
  def edge?(_, _), do: :no_edge

  def part_one(grouped_plots) do
    calculate_fence(grouped_plots, 0)
  end

  def part_two(grouped_plots) do
    Enum.map(grouped_plots, fn plot ->
      sides =
        count_corners(plot)
        |> Enum.map(fn {_coord, corners} -> Enum.count(corners) end)
        |> Enum.sum()

      sides * Enum.count(plot)
    end)
    |> Enum.sum()
  end

  @directions ~w(up right down left diagonal_up_right diagonal_up_left diagonal_down_right diagonal_down_left)a
  def count_corners(plots) do
    Enum.reduce(plots, [], fn plot, corners ->
      # IO.inspect(plot, label: "plot")

      surrounding =
        Enum.map(@directions, fn dir ->
          coord = GridMap.get_delta(plot.coord, dir)

          res =
            Enum.find(plots, &(&1.coord == coord))
            |> case do
              nil -> false
              _ -> true
            end

          {dir, res}
        end)
        |> Map.new()

      inner_corners =
        calculate_inner_corners(surrounding)

      outer_diagonal_corners =
        calculate_outer_diagonal_corners(surrounding)

      exclusion_corners =
        calculate_exclusion_corners(surrounding)

      [{plot.coord, inner_corners ++ outer_diagonal_corners ++ exclusion_corners} | corners]
    end)
  end

  def calculate_inner_corners(s) do
    acc = []
    # Left top
    acc =
      if not Map.get(s, :diagonal_up_left) and not Map.get(s, :left) and not Map.get(s, :up) do
        [:inner_left_top | acc]
      else
        acc
      end

    acc =
      if not Map.get(s, :diagonal_up_right) and not Map.get(s, :right) and not Map.get(s, :up) do
        [:inner_right_top | acc]
      else
        acc
      end

    acc =
      if not Map.get(s, :diagonal_down_left) and not Map.get(s, :left) and not Map.get(s, :down) do
        [:inner_left_bottom | acc]
      else
        acc
      end

    acc =
      if not Map.get(s, :diagonal_down_right) and not Map.get(s, :right) and not Map.get(s, :down) do
        [:inner_right_bottom | acc]
      else
        acc
      end

    acc
  end

  def calculate_outer_diagonal_corners(s) do
    acc = []

    acc =
      if not Map.get(s, :diagonal_up_left) and Map.get(s, :left) and Map.get(s, :up) do
        [:outer_diagonal_up_left | acc]
      else
        acc
      end

    acc =
      if not Map.get(s, :diagonal_up_right) and Map.get(s, :right) and Map.get(s, :up) do
        [:outer_diagonal_up_right | acc]
      else
        acc
      end

    acc =
      if not Map.get(s, :diagonal_down_left) and Map.get(s, :left) and Map.get(s, :down) do
        [:outer_diagonal_down_left | acc]
      else
        acc
      end

    acc =
      if not Map.get(s, :diagonal_down_right) and Map.get(s, :right) and Map.get(s, :down) do
        [:outer_diagonal_down_right | acc]
      else
        acc
      end

    acc
  end

  def calculate_exclusion_corners(s) do
    acc = []

    acc =
      if Map.get(s, :diagonal_up_left) and not Map.get(s, :left) and not Map.get(s, :up) do
        [:exclusion_diagonal_up_left | acc]
      else
        acc
      end

    acc =
      if Map.get(s, :diagonal_up_right) and not Map.get(s, :right) and not Map.get(s, :up) do
        [:exlusion_diagonal_up_right | acc]
      else
        acc
      end

    acc =
      if Map.get(s, :diagonal_down_left) and not Map.get(s, :left) and not Map.get(s, :down) do
        [:exclusion_diagonal_down_left | acc]
      else
        acc
      end

    acc =
      if Map.get(s, :diagonal_down_right) and not Map.get(s, :right) and not Map.get(s, :down) do
        [:exclusion_diagonal_down_right | acc]
      else
        acc
      end

    acc
  end

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
