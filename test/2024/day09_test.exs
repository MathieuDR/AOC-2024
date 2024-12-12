defmodule Aoc2024.Solutions.Y24.Day09Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day09, as: Solution, warn: false
  use ExUnit.Case, async: true

  # To run the test, run one of the following commands:
  #
  #     mix AoC.test --year 2024 --day 9
  #
  #     mix test test/2024/day09_test.exs
  #
  # To run the solution
  #
  #     mix AoC.run --year 2024 --day 9 --part 1
  #
  # Use sample input file:
  #
  #     # returns {:ok, "priv/input/2024/day-09-mysuffix.inp"}
  #     {:ok, path} = Input.resolve(2024, 9, "mysuffix")
  #
  # Good luck!

  defp solve(input, part) do
    problem =
      input
      |> Input.as_file()
      |> Solution.parse(part)

    apply(Solution, part, [problem])
  end
  @input "2333133121414131402"

  test "part one example" do
    assert 1928 == solve(@input, :part_one)
  end

  # Once your part one was successfully sumbitted, you may uncomment this test
  # to ensure your implementation was not altered when you implement part two.

  @part_one_solution 6200294120911

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 9, :part_one)
  end

  test "part two example" do
    assert 2858 == solve(@input, :part_two)
  end

  # You may also implement a test to validate the part two to ensure that you
  # did not broke your shared modules when implementing another problem.

  # @part_two_solution CHANGE_ME
  #
  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 9, :part_two)
  # end
end
