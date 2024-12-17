defmodule Aoc2024.Solutions.Y24.Day13 do
  @moduledoc """
  # Linear Diophantine equation with 2 variables

  I tried the [diophantine equation](https://mathworld.wolfram.com/DiophantineEquation.html) first, to give all solutions, especially working with the extended gdc

  The math went like this
  ```
  Px = jAx + iBx
  Py = jAy + iBy

  Works for both X and Y, but lets take X as an example
  {gcd, s, t} = Integer.extended_gcd(Ax, Bx)
  if Px % gcd != 0 -> no solution
  gcdFactor = Px / gcd
  n = s * gcdFactor
  m = t * gcdFactor
  One possible solution is Px = nAx + mBx
  This will most likely result into n / m that is not above 0
  Since we calculate all solutions, it starts with negative ones we need a factor *k* to scale our solution
  To get the k factor we can use the following formula to get around one of the tipping point
  round( m / (a/gcd))
  Or for the other one
  round( n / (b/gcd))
  To do this, we can use the following equation
  j = n + k * (Bx / gcd)
  i = m - k * (Ax / gcd)
  ```

  # Cramer's rule

  Looking on the internet I found an interesting page that I only partially get [Cramer's rule](https://en.wikipedia.org/wiki/Cramer%27s_rule)

  > In linear algebra, Cramer's rule is an explicit formula for the solution of a system of linear equations with as many equations as unknowns, valid whenever the system has a unique solution.
  The worrying part is the *unique* solution. What if there are multiple solutions?

  It uses matrices, so we need to rewrite our equations from before in the following form
  See the [Applications section](https://en.wikipedia.org/wiki/Cramer%27s_rule#Applications) for it written in nice math.

  ```
  [Ax Bx][j] = [Px]
  [Ay By][i]   [Py]
  ```

  ## Determinants
  Cramer's rule uses [determinants](https://en.wikipedia.org/wiki/Determinant). Lets try to decipher what these are:
  It's basically a constant that we calculate using the diagonals of a square matrix.

  It can tell us the following: If the determinant is 0, we don't have a solution. If the determinant is not 0, we have exactly one solution and Cramer's rule will work.

  Our determinants are

  ```
  AxBy - BxAy
  ``` 

  ## Putting it together

  ```
      [Px  Bx]
      [Py  By]     PxBy - BxPy
  x = --------  =  -----------
      [Ax  Bx]     AxBy - BxAy
      [Ay  By]

      [Ax  Px]
      [Ay  Py]     AxPy - PxAy
  y = --------  =  -----------
      [Ax  Bx]     AxBy - BxAy
      [Ay  By]
  ```
  """
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
    diophantine_equation(prize.x - prize.y, a.x - a.y, b.x - b.y)
    |> Enum.take(5)
    |> IO.inspect()

    # x = diophantine_equation(prize.x, a.x, b.x)
    # y = diophantine_equation(prize.y, a.y, b.y)
    #
    # match_streams(x, y)
    # |> Enum.take(1)
  end

  def match_streams(stream_a, stream_b) do
    Stream.resource(
      fn ->
        a = Enum.take(stream_a, 1)
        b = Enum.take(stream_b, 1)
        {stream_a, stream_b, a, b}
      end,
      fn
        {_, _, [], _b} ->
          {:halt, []}

        {_, _, _a, []} ->
          {:halt, []}

        {stream_a, stream_b, [a], [b]} ->
          cond do
            a == b ->
              {[a],
               {Stream.drop(stream_a, 1), Stream.drop(stream_b, 1), Enum.take(stream_a, 1),
                Enum.take(stream_b, 1)}}

            elem(a, 1) <= elem(b, 1) ->
              {[], {Stream.drop(stream_a, 1), stream_b, Enum.take(stream_a, 1), [b]}}

            true ->
              {[], {stream_a, Stream.drop(stream_b, 1), [a], Enum.take(stream_b, 1)}}
          end
      end,
      fn _ -> :ok end
    )
  end

  def diophantine_equation(p, a, b) do
    {gcd, s, t} = Integer.extended_gcd(a, b)

    if rem(p, gcd) == 0 do
      factor = div(p, gcd)
      s_add = fn k -> k * div(b, gcd) end
      t_add = fn k -> k * div(a, gcd) end
      n = s * factor
      m = t * factor

      k = Kernel.round(m / div(a, gcd)) + 10
      # k = Kernel.round(n / div(b, gcd))

      a_stream =
        0..100
        |> Stream.map(fn i -> n + s_add.(k - i) end)

      b_stream =
        0..100
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
