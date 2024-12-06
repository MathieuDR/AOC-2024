defmodule Aoc2024.Helpers.Coords do
  defstruct [:x, :y]

  def add(%__MODULE__{x: x, y: y} = _coord, %__MODULE__{x: dx, y: dy} = _delta) do
    %__MODULE__{x: x + dx, y: y + dy}
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
end
