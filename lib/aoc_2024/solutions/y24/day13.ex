defmodule Aoc2024.Solutions.Y24.Day13 do
  alias AoC.Input
  alias Aoc2024.Helpers.Coords

  defmodule ClawMachine do
    defstruct [:prize, :a_button, :b_button]
  end

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn block ->
      [a, b, prize] =
        String.split(block, "\n", trim: true)
        |> Enum.map(fn line ->
          [_, x, y] =
            ~r/X.(\d*).*Y.(\d*)/u
            |> Regex.run(line)

          %Coords{x: String.to_integer(x), y: String.to_integer(y)}
        end)

      %ClawMachine{prize: prize, a_button: a, b_button: b}
    end)
  end

  def part_one(problem), do: solve(problem)

  @error 10_000_000_000_000
  def part_two(problem) do
    Enum.map(problem, fn %{prize: prize} = machine ->
      %ClawMachine{machine | prize: %Coords{x: prize.x + @error, y: prize.y + @error}}
    end)
    |> solve()
  end

  def solve(problem) do
    problem
    |> Enum.map(fn machine ->
      solve_machine(machine)
      |> calculate_machine_cost()
      |> case do
        [] -> 0
        x -> Enum.min(x)
      end
    end)
    |> Enum.sum()
  end

  def calculate_machine_cost(solutions) do
    Enum.map(solutions, fn {a, b} ->
      a * 3 + b
    end)
  end

  def solve_machine(%ClawMachine{prize: prize, a_button: a, b_button: b}) do
    x =
      diophantine_equation(prize.x, a.x, b.x)
      |> Enum.to_list()

    y =
      diophantine_equation(prize.y, a.y, b.y)
      |> Enum.to_list()

    MapSet.intersection(MapSet.new(x), MapSet.new(y))
  end

  def diophantine_equation(p, a, b) do
    {gcd, s, t} = Integer.extended_gcd(a, b)

    if rem(p, gcd) == 0 do
      factor = div(p, gcd)
      s_add = fn k -> k * div(b, gcd) end
      t_add = fn k -> k * div(a, gcd) end
      n = s * factor
      m = t * factor

      k = Kernel.round(m / div(a, gcd)) + 1_000

      a_stream =
        0..100_000
        |> Stream.map(fn i -> n + s_add.(k - i) end)

      b_stream =
        0..100_000
        |> Stream.map(fn i -> m - t_add.(k - i) end)

      Stream.zip(a_stream, b_stream)
      |> Stream.reject(fn {a, b} ->
        a <= 0 or b <= 0
      end)
    else
      []
    end
  end
end
