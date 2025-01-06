defmodule Aoc2024.Solutions.Y24.Day17 do
  alias AoC.Input

  def parse(input, _part) do
    [registers, program] =
      Input.read!(input)
      |> String.split("\n\n", trim: true)

    registers = parse_registers(registers)

    program =
      String.split(program)
      |> List.last()
      |> parse_program()

    create_state(registers, program)
  end

  def parse_registers(registers) do
    registers
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line)
      |> List.last()
      |> String.to_integer()
    end)
  end

  def parse_program(program_string) do
    String.split(program_string, ",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2, 2, :discard)
    |> Enum.with_index(fn elem, i -> {i * 2, elem} end)
  end

  def create_state([a, b, c], program),
    do: %{pointer: 0, output: [], A: a, B: b, C: c, program: Map.new(program)}

  def part_one(state) do
    %{output: solution} = __MODULE__.Computer.run_program(state)

    Enum.reverse(solution)
    |> Enum.join(",")
  end

  # def part_two(problem) do
  #   problem
  # end
end
