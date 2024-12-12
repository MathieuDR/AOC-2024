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

  def part_one(blocks) do
    size = Enum.reduce(blocks, 0, &(&2 + &1.file_size + &1.empty_size))

    0..(size - 1)
    |> Enum.reduce_while({[], blocks}, fn
      idx, {acc, blocks} ->
        with {value, blocks} <- pop(blocks) do
          {:cont, {[%{id: idx, value: value} | acc], blocks}}
        else
          nil ->
            IO.puts("Halted at IDX: #{idx}")
            {:halt, acc}
        end
    end)
    |> Enum.reduce(0, &(&2 + &1.id * &1.value))
  end

  def pop([]), do: nil
  def pop([%__MODULE__.Block{file_size: 0, empty_size: 0} | rest]), do: pop(rest)

  def pop([%__MODULE__.Block{file_size: 0, empty_size: x} = current_block | rest]) do
    current_block = %__MODULE__.Block{current_block | empty_size: x - 1}
    {val, blocks} = pop_back(rest)

    {val, [current_block | blocks]}
  end

  def pop([%__MODULE__.Block{file_size: x, id: id} = current_block | rest]) do
    current_block = %__MODULE__.Block{current_block | file_size: x - 1}

    {id, [current_block | rest]}
  end

  def pop_back(blocks) do
    # If I need to take more then 1, because empty, this will be better then 2x last?
    reversed = Enum.reverse(blocks)

    idx = Enum.find_index(reversed, &(&1.file_size > 0))

    case idx do
      nil ->
        {0, []}

      _ ->
        [%__MODULE__.Block{id: value, file_size: x} = current_block | rest] =
          Enum.drop(reversed, idx)

        current_block = %__MODULE__.Block{current_block | file_size: x - 1}

        leftover =
          [current_block | rest]
          |> Enum.reverse()

        {value, leftover}
    end
  end

  # def part_two(problem) do
  #   problem
  # end
end
