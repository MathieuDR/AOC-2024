defmodule Aoc2024.Helpers.GridMap do
  alias Aoc2024.Helpers.Coords

  def string_to_map(input, fn_cell_value) do
    {map, yBound, xBound} =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce({%{}, 0, 0}, fn {line, y}, {map, _y, _x} ->
        {map, xBound} =
          String.to_charlist(line)
          |> Enum.with_index()
          |> Enum.reduce({map, 0}, fn
            {char, x}, {map, _xBound} ->
              case fn_cell_value.(char) do
                nil ->
                  {map, x}

                value ->
                  coord = %Coords{x: x, y: y}
                  map = Map.put(map, coord, value)
                  {map, x}
              end
          end)

        {map, y, xBound}
      end)

    {map, %Coords{x: xBound, y: yBound}}
  end

  def map_to_graph(map, fn_edge?, opts \\ []) do
    Enum.reduce(map, %{}, fn
      {coord, value}, acc ->
        edges =
          find_edges(map, coord, value, fn_edge?, opts)

        node = %{
          value: value,
          edges: edges,
          coord: coord
        }

        Map.put(acc, coord, node)
    end)
  end

  defp find_edges(map, coord, value, fn_edge?, opts) do
    directions =
      Keyword.get(
        opts,
        :directions,
        ~w(up right down left diagonal_up_right diagonal_up_left diagonal_down_right diagonal_down_left)a
      )

    Enum.reduce(directions, [], fn direction, acc ->
      to_check = get_delta(coord, direction)

      case fn_edge?.(value, Map.get(map, to_check)) do
        {:edge, weigth} -> [{to_check, weigth} | acc]
        :no_edge -> acc
      end
    end)
  end

  def print_map(map, fn_value_to_char) do
    {chars, _y} =
      Enum.sort(map, fn {acoord, _}, {bcoord, _} -> Coords.sorter(acoord, bcoord) end)
      |> Enum.reduce({[], 0}, fn {coord, value}, {chars, last_y} ->
        char = fn_value_to_char.(value)
        chars = if last_y == coord.y, do: [char | chars], else: [char, ?\n | chars]

        {chars, coord.y}
      end)

    chars
    |> Enum.reverse()
    |> Kernel.to_string()
  end

  @invert_map %{
    up: :down,
    down: :up,
    right: :left,
    left: :right,
    diagonal_up_right: :diagonal_down_right,
    diagonal_up_left: :diagonal_down_left
  }

  def invert(direction), do: @invert_map[direction]

  def get_delta(%Coords{x: x, y: y}, :up), do: %Coords{x: x, y: y - 1}
  def get_delta(%Coords{x: x, y: y}, :down), do: %Coords{x: x, y: y + 1}
  def get_delta(%Coords{x: x, y: y}, :right), do: %Coords{x: x + 1, y: y}
  def get_delta(%Coords{x: x, y: y}, :left), do: %Coords{x: x - 1, y: y}
  def get_delta(%Coords{x: x, y: y}, :diagonal_up_right), do: %Coords{x: x + 1, y: y - 1}
  def get_delta(%Coords{x: x, y: y}, :diagonal_up_left), do: %Coords{x: x - 1, y: y - 1}
  def get_delta(%Coords{x: x, y: y}, :diagonal_down_right), do: %Coords{x: x + 1, y: y + 1}
  def get_delta(%Coords{x: x, y: y}, :diagonal_down_left), do: %Coords{x: x - 1, y: y + 1}
end
