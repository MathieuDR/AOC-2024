defmodule Aoc2024.Solutions.Y24.Day16Test do
  alias AoC.Input, warn: false
  alias Aoc2024.Solutions.Y24.Day16, as: Solution, warn: false
  use ExUnit.Case, async: true

  # To run the test, run one of the following commands:
  #
  #     mix AoC.test --year 2024 --day 16
  #
  #     mix test test/2024/day16_test.exs
  #
  # To run the solution
  #
  #     mix AoC.run --year 2024 --day 16 --part 1
  #
  # Use sample input file:
  #
  #     # returns {:ok, "priv/input/2024/day-16-mysuffix.inp"}
  #     {:ok, path} = Input.resolve(2024, 16, "mysuffix")
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
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """

    assert 7036 == solve(input, :part_one)
  end

  test "part one example, 2" do
    input = ~S"""
    ##.##.#.#E
    ....#...#.
    .##.#.#.#.
    .##.#.#.#.
    .##.#.#.#.
    S.#...#...
    """

    assert 9030 == solve(input, :part_one)
  end

  # Once your part one was successfully sumbitted, you may uncomment this test
  # to ensure your implementation was not altered when you implement part two.

  @part_one_solution 85396
  #
  test "part one solution" do
    assert {:ok, @part_one_solution} == AoC.run(2024, 16, :part_one)
  end

  test "part two example, simple" do
    input = ~S"""
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
    """

    assert 45 == solve(input, :part_two)
  end

  test "part two example" do
    input = ~S"""
    #################
    #...#...#...#..E#
    #.#.#.#.#.#.#.#.#
    #.#.#.#...#...#.#
    #.#.#.#.###.#.#.#
    #...#.#.#.....#.#
    #.#.#.#.#.#####.#
    #.#...#.#.#.....#
    #.#.#####.#.###.#
    #.#.#.......#...#
    #.#.###.#####.###
    #.#.#...#.....#.#
    #.#.#.#####.###.#
    #.#.#.........#.#
    #.#.#.#########.#
    #S#.............#
    #################
    """

    assert 64 == solve(input, :part_two)
  end

  test "part two example, 2" do
    input = ~S"""
    ..E..
    .###.
    .....
    ##S##
    """

    assert 13 == solve(input, :part_two)
  end

  # You may also implement a test to validate the part two to ensure that you
  # did not broke your shared modules when implementing another problem.

  # @part_two_solution CHANGE_ME
  #
  test "part two solution" do
    assert {:ok, part_two_solution} = AoC.run(2024, 16, :part_two)
    assert part_two_solution > 414
    assert part_two_solution < 8466
  end
end
