defmodule Aoc2024.Solutions.Y24.Day07 do
  alias AoC.Input

  defmodule Operation do
    defstruct [:left, :right, :result, :operand]

    defimpl Inspect do
      def inspect(%Operation{left: left, right: right, operand: operand}, _opts) do
        operator =
          case operand do
            :concat -> "||"
            :mul -> "*"
            :add -> "+"
          end

        "#{left}, #{right} #{operator}"
      end
    end
  end

  defmodule Equation do
    defstruct [:operations, :result]

    defimpl Inspect do
      def inspect(%Equation{operations: operations, result: result}, _opts) do
        operations_string =
          operations
          |> Enum.map(&Inspect.inspect(&1, %{}))
          |> Enum.join(", ")

        "#{result} = #{operations_string}"
      end
    end
  end

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [result | rest] =
        String.split(line, ~r/[: ]/, trim: true)
        |> Enum.map(&String.to_integer/1)

      {result, rest}
    end)
  end

  def solve(problem, operators \\ [:mul, :add]) do
    problem
    |> Enum.map(fn {start, rest} ->
      [f | rest] = rest

      equations =
        [%__MODULE__.Equation{result: f, operations: []}]
        |> calculate_to(rest, start, operators)

      {start, equations}
    end)
    |> Enum.filter(fn
      {_start, []} -> false
      {_start, _operations} -> true
    end)
    |> Enum.reduce(0, fn {start, _}, acc -> acc + start end)
  end

  def part_one(problem), do: solve(problem, [:mul, :add])
  def part_two(problem), do: solve(problem, [:mul, :add, :concat])

  def to_equation(
        :mul,
        %__MODULE__.Equation{result: operand_left, operations: operations},
        operand_right,
        goal
      ) do
    case operand_left * operand_right do
      x when x <= goal ->
        operation = %__MODULE__.Operation{
          left: operand_left,
          right: operand_right,
          result: x,
          operand: :mul
        }

        %__MODULE__.Equation{
          result: x,
          operations: [operation | operations]
        }

      _ ->
        nil
    end
  end

  def to_equation(
        :add,
        %__MODULE__.Equation{result: operand_left, operations: operations},
        operand_right,
        goal
      ) do
    case operand_left + operand_right do
      x when x <= goal ->
        operation = %__MODULE__.Operation{
          left: operand_left,
          right: operand_right,
          result: x,
          operand: :add
        }

        %__MODULE__.Equation{
          result: x,
          operations: [operation | operations]
        }

      _ ->
        nil
    end
  end

  def to_equation(
        :concat,
        %__MODULE__.Equation{result: operand_left, operations: operations},
        operand_right,
        goal
      ) do
    digits = trunc(:math.log10(operand_right)) + 1
    powed = trunc(:math.pow(10, digits))

    case operand_left * powed + operand_right do
      x when x <= goal ->
        operation = %__MODULE__.Operation{
          left: operand_left,
          right: operand_right,
          result: x,
          operand: :concat
        }

        %__MODULE__.Equation{
          result: x,
          operations: [operation | operations]
        }

      _ ->
        nil
    end
  end

  def calculate_to(equations, [], working_towards, _operators) do
    Enum.filter(equations, &(&1.result == working_towards))
  end

  def calculate_to(equations, [num | leftovers], working_towards, operators) do
    Enum.flat_map(equations, fn equation ->
      Enum.map(operators, &to_equation(&1, equation, num, working_towards))
      |> Enum.reject(&is_nil(&1))
    end)
    |> calculate_to(leftovers, working_towards, operators)
  end
end
