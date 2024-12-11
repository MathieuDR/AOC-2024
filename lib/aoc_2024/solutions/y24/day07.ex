defmodule Aoc2024.Solutions.Y24.Day07 do
  alias AoC.Input

  # defstruct [:leftovers, :result, :children, :parent]

  defmodule Operation do
    defstruct [:left, :right, :result, :operand]

    defimpl Inspect do
      def inspect(%Operation{left: left, right: right, operand: operand}, _opts) do
        operator =
          case operand do
            :div -> "/"
            :mul -> "*"
            :add -> "+"
            :sub -> "-"
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

  def part_one(problem) do
    problem
    |> Enum.map(fn {start, rest} ->
      # reverse =
      #   rest
      #   |> Enum.reverse()

      [f | rest] = rest
      #
      equations =
        [%__MODULE__.Equation{result: f, operations: []}]
        |> calculate_to(rest, start)

      {start, equations}
    end)
    |> Enum.filter(fn
      {_start, []} -> false
      {_start, _operations} -> true
    end)
    # |> Enum.map(&elem(&1, 0))

    |> Enum.reduce(0, fn {start, _}, acc -> acc + start end)
  end

  def calculate_to(equations, [], working_towards) do
    Enum.filter(equations, &(&1.result == working_towards))
  end

  def calculate_to(equations, [num | leftovers], working_towards) do
    Enum.flat_map(equations, fn %__MODULE__.Equation{result: result, operations: operations} ->
      mul_equation =
        case num * result do
          x when x <= working_towards ->
            operation = %__MODULE__.Operation{
              left: result,
              right: num,
              result: x,
              operand: :mul
            }

            %__MODULE__.Equation{
              result: operation.result,
              operations: [operation | operations]
            }

          _ ->
            nil
        end

      add_equation =
        case result + num do
          x when x <= working_towards ->
            operation = %__MODULE__.Operation{
              left: result,
              right: num,
              result: x,
              operand: :add
            }

            %__MODULE__.Equation{
              result: operation.result,
              operations: [operation | operations]
            }

          _ ->
            nil
        end

      [mul_equation, add_equation]
      |> Enum.reject(&is_nil(&1))
    end)
    |> calculate_to(leftovers, working_towards)
  end

  def calculate_to_zero(equations, []) do
    Enum.filter(equations, &(&1.result == 0))
  end

  def calculate_to_zero(
        equations,
        [num | leftovers]
      ) do
    Enum.flat_map(equations, fn %__MODULE__.Equation{result: result, operations: operations} ->
      div_equation =
        case rem(result, num) do
          0 ->
            operation = %__MODULE__.Operation{
              left: result,
              right: num,
              result: div(result, num),
              operand: :div
            }

            %__MODULE__.Equation{
              result: operation.result,
              operations: [operation | operations]
            }

          _ ->
            nil
        end

      sub_equation =
        case result - num do
          x when x >= 0 ->
            operation = %__MODULE__.Operation{
              left: result,
              right: num,
              result: result - num,
              operand: :sub
            }

            %__MODULE__.Equation{
              result: operation.result,
              operations: [operation | operations]
            }

          _ ->
            nil
        end

      [div_equation, sub_equation]
      |> Enum.reject(&is_nil(&1))
    end)
    |> calculate_to_zero(leftovers)
  end

  # def part_two(problem) do
  #   problem
  # end
end
