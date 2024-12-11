defmodule Aoc2024.Solutions.Y24.Day09 do
  alias AoC.Input

  defmodule Block do
    defstruct [:id, :file_size, :empty_size]
  end

  def parse(input, _part) do
    input =
      Input.read!(input)
      |> String.trim()

    case rem(String.length(input), 2) do
      0 -> input
      1 -> input <> "0"
    end
    |> parse(0, [])
    |> Enum.reverse()
  end

  @asci_0 ?0

  def parse("", _idx, acc), do: acc

  def parse(<<file>> <> <<empty>> <> rest, idx, acc) do
    parse(rest, idx + 1, [
      %__MODULE__.Block{
        id: idx,
        file_size: file - @asci_0,
        empty_size: empty - @asci_0
      }
      | acc
    ])
  end

  def part_one(problem) do
    # This function receives the problem returned by parse/2 and must return
    # today's problem solution for part one.

    problem
  end

  # def part_two(problem) do
  #   problem
  # end
end
