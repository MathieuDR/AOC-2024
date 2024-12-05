defmodule Aoc2024.Solutions.Y24.Day04Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day04, as: Solution, warn: false
  use ExUnit.Case, async: true

  # To run the test, run one of the following commands:
  #
  #     mix AoC.test --year 2024 --day 4
  #
  #     mix test test/2024/day04_test.exs
  #
  # To run the solution
  #
  #     mix AoC.run --year 2024 --day 4 --part 1
  #
  # Use sample input file:
  #
  #     # returns {:ok, "priv/input/2024/day-04-mysuffix.inp"}
  #     {:ok, path} = Input.resolve(2024, 4, "mysuffix")
  #
  # Good luck!

  defp solve(input, part) do
    problem =
      input
      |> Input.as_file()
      |> Solution.parse(part)

    apply(Solution, part, [problem])
  end

  @input ~S"""
  MMMSXXMASM
  MSAMXMSMSA
  AMXSXMAAMM
  MSAMASMSMX
  XMASAMXAMM
  XXAMMXXAMA
  SMSMSASXSS
  SAXAMASAAA
  MAMMMXMMMM
  MXMXAXMASX
  """

  test "part one example" do
    assert 18 == solve(@input, :part_one)
  end

  describe "detection" do
    test "right diagonal" do
      input = ~S"""
      ..X....
      ...M...
      ....A..
      .....S.
      """

      assert {_, 1} =
               Input.as_file(input)
               |> Solution.parse(nil)
               |> Solution.detect("XMAS")
    end

    test "right diagonal backwards" do
      input = ~S"""
      ..S....
      ...A...
      ....M..
      .....X.
      """

      assert {_, 1} =
               Input.as_file(input)
               |> Solution.parse(nil)
               |> Solution.detect("XMAS")
    end

    test "VERTICAL backwards" do
      input = ~S"""
      ..S....
      ..A....
      ..M....
      ..X....
      """

      assert {_, 1} =
               Input.as_file(input)
               |> Solution.parse(nil)
               |> Solution.detect("XMAS")
    end

    test "left diagonal reverse" do
      input = ~S"""
      ..S....
      ...A...
      ....M..
      .....X.
      """

      assert {_, 1} =
               Input.as_file(input)
               |> Solution.parse(nil)
               |> Solution.detect("XMAS")
    end

    test "left diagonal" do
      input = ~S"""
      ..X....
      ...M...
      ....A..
      .....S.
      """

      assert {_, 1} =
               Input.as_file(input)
               |> Solution.parse(nil)
               |> Solution.detect("XMAS")
    end

    test "VERTICAL" do
      input = ~S"""
      ..X....
      ..M....
      ..A....
      ..S....
      """

      assert {_, 1} =
               Input.as_file(input)
               |> Solution.parse(nil)
               |> Solution.detect("XMAS")
    end

    test "backwards" do
      input = "..SAMX.."

      assert {_, 1} =
               Input.as_file(input)
               |> Solution.parse(nil)
               |> Solution.detect("XMAS")
    end

    test "horizontal" do
      input = "..XMAS.."

      assert {_, 1} =
               Input.as_file(input)
               |> Solution.parse(nil)
               |> Solution.detect("XMAS")
    end
  end

  # Once your part one was successfully sumbitted, you may uncomment this test
  # to ensure your implementation was not altered when you implement part two.

  @part_one_solution 2414

  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 4, :part_one)
  end

  test "part two example" do
    assert 9 == solve(@input, :part_two)
  end

  # You may also implement a test to validate the part two to ensure that you
  # did not broke your shared modules when implementing another problem.

  @part_two_solution 1871

  test "part two solution" do
    assert {:ok, @part_two_solution} == AoC.run(2024, 4, :part_two)
  end
end
