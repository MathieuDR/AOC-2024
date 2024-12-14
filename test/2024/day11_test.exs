defmodule Aoc2024.Solutions.Y24.Day11Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day11, as: Solution, warn: false
  use ExUnit.Case, async: true

  # To run the test, run one of the following commands:
  #
  #     mix AoC.test --year 2024 --day 11
  #
  #     mix test test/2024/day11_test.exs
  #
  # To run the solution
  #
  #     mix AoC.run --year 2024 --day 11 --part 1
  #
  # Use sample input file:
  #
  #     # returns {:ok, "priv/input/2024/day-11-mysuffix.inp"}
  #     {:ok, path} = Input.resolve(2024, 11, "mysuffix")
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
    input =
      "0 1 10 99 999"
      |> Input.as_file()
      |> Solution.parse(:part_one)

    assert [1, 2024, 1, 0, 9, 9, 2_021_976] == Solution.blink_stones(input, 1, 1)
  end

  test "part one example two" do
    input = "125 17"
    assert 55312 == solve(input, :part_one)
  end

  # Once your part one was successfully sumbitted, you may uncomment this test
  # to ensure your implementation was not altered when you implement part two.

  @part_one_solution 216_996

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 11, :part_one)
  end

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
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 11, :part_two)
  # end
end
