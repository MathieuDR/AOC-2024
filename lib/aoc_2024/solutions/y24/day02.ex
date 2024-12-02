defmodule Aoc2024.Solutions.Y24.Day02 do
  alias AoC.Input

  def parse(input, _part) do
    # This function will receive the input path or an %AoC.Input.TestInput{}
    # struct. To support the test you may read both types of input with either:
    #
    # * Input.stream!(input), equivalent to File.stream!/1
    # * Input.stream!(input, trim: true), equivalent to File.stream!/2
    # * Input.read!(input), equivalent to File.read!/1
    #
    # The role of your parse/2 function is to return a "problem" for the solve/2
    # function.
    #
    # For instance:
    #
    # input
    # |> Input.stream!()
    # |> Enum.map!(&my_parse_line_function/1)

    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn report ->
      String.split(report)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def part_one(problem) do
    problem
    |> Enum.map(&safe?/1)
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def part_two(problem) do
    problem
    |> Enum.map(&safe?(&1, 1))
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  # It fails if the first one is wrong. lets fix that later
  def safe?(levels, ignores \\ 0) do
    {fails, _, _} =
      Enum.reduce(levels, {0, nil, nil}, fn
        # _, {false, _, _} ->
        #   {false, nil, nil}
        #
        elem, {fails, nil, nil} ->
          {fails, elem, elem}

        elem, {fails, previous, first}
        when 3 < abs(elem - previous) or abs(elem - previous) == 0 ->
          {fails + 1, previous, first}

        elem, {fails, previous, first} when first > previous and previous < elem ->
          {fails + 1, previous, first}

        elem, {fails, previous, first} when first < previous and previous > elem ->
          {fails + 1, previous, first}

        elem, {fails, _, first} ->
          {fails, elem, first}
      end)

    cond do
      fails <= ignores -> true
      ignores > 0 -> safe?(Enum.drop(levels, 1), ignores - 1)
      true -> false
    end
  end
end
