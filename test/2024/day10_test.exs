defmodule Aoc2024.Solutions.Y24.Day10Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day10, as: Solution, warn: false
  use ExUnit.Case, async: true

  # To run the test, run one of the following commands:
  #
  #     mix AoC.test --year 2024 --day 10
  #
  #     mix test test/2024/day10_test.exs
  #
  # To run the solution
  #
  #     mix AoC.run --year 2024 --day 10 --part 1
  #
  # Use sample input file:
  #
  #     # returns {:ok, "priv/input/2024/day-10-mysuffix.inp"}
  #     {:ok, path} = Input.resolve(2024, 10, "mysuffix")
  #
  # Good luck!

  defp solve(input, part) do
    problem =
      input
      |> Input.as_file()
      |> Solution.parse(part)

    apply(Solution, part, [problem])
  end

  test "multiple pathways" do
    input = ~S"""
    0123
    1234
    8765
    9876
    """

    assert 1 == solve(input, :part_one)
  end

  test "impassable terrain" do
    input = """
    ...0...
    ...1...
    ...2...
    6543456
    7.....7
    8.....8
    9.....9
    """

    assert 2 == solve(input, :part_one)
  end

  test "multiple endings" do
    input = """
    ..90..9
    ...1.98
    ...2..7
    6543456
    765.987
    876....
    987....
    """

    assert 4 == solve(input, :part_one)
  end

  # Once your part one was successfully sumbitted, you may uncomment this test
  # to ensure your implementation was not altered when you implement part two.

  # @part_one_solution CHANGE_ME
  #
  # test "part one solution" do
  #   assert {:ok, @part_one_solution} == AoC.run(2024, 10, :part_one)
  # end

  # test "part two example" do
  #   input = ~S"""
  #   This is an
  #   example input.
  #   replace with
  #   an example from
  #   the AoC website.
  #   """
  #
  #   assert CHANGE_ME == solve(input, :part_two)
  # end

  # You may also implement a test to validate the part two to ensure that you
  # did not broke your shared modules when implementing another problem.

  # @part_two_solution CHANGE_ME
  #
  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 10, :part_two)
  # end
end
