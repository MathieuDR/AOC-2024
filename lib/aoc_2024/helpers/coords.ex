defmodule Aoc2024.Helpers.Coords do
  defstruct [:x, :y]

  def add(%__MODULE__{x: x, y: y} = _coord, %__MODULE__{x: dx, y: dy} = _delta) do
    %__MODULE__{x: x + dx, y: y + dy}
  end

  def calculate_delta(%__MODULE__{x: x, y: y}, %__MODULE__{x: x2, y: y2}) do
    %__MODULE__{
      x: x - x2,
      y: y - y2
    }
  end

  def out_of_bounds(
        %__MODULE__{x: x, y: y} = _current,
        %__MODULE__{x: xBound, y: yBound} = _bounds
      ) do
    cond do
      x < 0 -> true
      x > xBound -> true
      y < 0 -> true
      y > yBound -> true
      true -> false
    end
  end

  def sorter(a, b) do
    cond do
      a.y < b.y -> true
      a.y == b.y and a.x <= b.x -> true
      true -> false
    end
  end

  def manhatten_distance(%__MODULE__{x: ax, y: ay}, %__MODULE__{x: bx, y: by}) do
    y = abs(ay - by)
    x = abs(ax - bx)

    y + x
  end

  defimpl Inspect do
    def inspect(%__MODULE{x: x, y: y}, _opts) do
      "{#{x}, #{y}}"
    end
  end
end
