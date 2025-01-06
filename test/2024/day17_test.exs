defmodule Aoc2024.Solutions.Y24.Day17Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day17, as: Solution, warn: false
  use ExUnit.Case, async: true

  # To run the test, run one of the following commands:
  #
  #     mix AoC.test --year 2024 --day 17
  #
  #     mix test test/2024/day17_test.exs
  #
  # To run the solution
  #
  #     mix AoC.run --year 2024 --day 17 --part 1
  #
  # Use sample input file:
  #
  #     # returns {:ok, "priv/input/2024/day-17-mysuffix.inp"}
  #     {:ok, path} = Input.resolve(2024, 17, "mysuffix")
  #
  # Good luck!

  defp solve(input, part) do
    problem =
      input
      |> Input.as_file()
      |> Solution.parse(part)

    apply(Solution, part, [problem])
  end

  test "part one example" do
    input = ~S"""
    Register A: 729
    Register B: 0
    Register C: 0

    Program: 0,1,5,4,3,0
    """

    assert "4,6,3,5,6,3,5,2,1,0" == solve(input, :part_one)
  end

  # Once your part one was successfully sumbitted, you may uncomment this test
  # to ensure your implementation was not altered when you implement part two.

  # @part_one_solution CHANGE_ME
  #
  # test "part one solution" do
  #   assert {:ok, @part_one_solution} == AoC.run(2024, 17, :part_one)
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
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 17, :part_two)
  # end
end
