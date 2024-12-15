defmodule Aoc2024.Solutions.Y24.Day12Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day12, as: Solution, warn: false
  use ExUnit.Case, async: true

  # To run the test, run one of the following commands:
  #
  #     mix AoC.test --year 2024 --day 12
  #
  #     mix test test/2024/day12_test.exs
  #
  # To run the solution
  #
  #     mix AoC.run --year 2024 --day 12 --part 1
  #
  # Use sample input file:
  #
  #     # returns {:ok, "priv/input/2024/day-12-mysuffix.inp"}
  #     {:ok, path} = Input.resolve(2024, 12, "mysuffix")
  #
  # Good luck!

  defp solve(input, part) do
    problem =
      input
      |> Input.as_file()
      |> Solution.parse(part)

    apply(Solution, part, [problem])
  end

  test "part one example, large" do
    input = ~S"""
    RRRRIICCFF
    RRRRIICCCF
    VVRRRCCFFF
    VVRCCCJFFF
    VVVVCJJCFE
    VVIVCCJJEE
    VVIIICJJEE
    MIIIIIJJEE
    MIIISIJEEE
    MMMISSJEEE
    """

    assert 1930 == solve(input, :part_one)
  end

  test "part one example simple" do
    input = ~S"""
    BB
    BQ
    """

    assert 28 == solve(input, :part_one)
  end

  test "part one example" do
    input = ~S"""
    AAAA
    BBCD
    BBCC
    EEEC
    """

    assert 140 == solve(input, :part_one)
  end

  # Once your part one was successfully sumbitted, you may uncomment this test
  # to ensure your implementation was not altered when you implement part two.

  @part_one_solution 1_550_156

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 12, :part_one)
  end

  test "O example" do
    input = ~S"""
    OOOOO
    OXOXO
    OOOOO
    OXOXO
    OOOOO
    """

    assert 436 == solve(input, :part_two)
  end

  test "B example" do
    input = ~S"""
    AAAAAA
    AAABBA
    AAABBA
    ABBAAA
    ABBAAA
    AAAAAA
    """

    assert 368 == solve(input, :part_two)
  end

  test "E example" do
    input = ~S"""
    EEEEE
    EXXXX
    EEEEE
    EXXXX
    EEEEE
    """

    assert 236 == solve(input, :part_two)
  end

  # You may also implement a test to validate the part two to ensure that you
  # did not broke your shared modules when implementing another problem.

  # @part_two_solution CHANGE_ME
  #
  # test "part two solution" do
  #   assert {:ok, @part_two_solution} == AoC.run(2024, 12, :part_two)
  # end
end
