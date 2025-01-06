defmodule Aoc2024.Solutions.Y24.Day17 do
  alias AoC.Input

  def parse(input, _part) do
    [registers, program] =
      Input.read!(input)
      |> String.split("\n\n", trim: true)

    registers = parse_registers(registers)

    {raw, parsed} =
      String.split(program)
      |> List.last()
      |> parse_program()

    create_state(registers, parsed, raw)
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
    program =
      String.split(program_string, ",", trim: true)
      |> Enum.map(&String.to_integer/1)

    parsed =
      Enum.chunk_every(program, 2, 2, :discard)
      |> Enum.with_index(fn elem, i -> {i * 2, elem} end)

    {program, parsed}
  end

  def create_state([a, b, c], program, raw),
    do: %{pointer: 0, output: [], A: a, B: b, C: c, program: Map.new(program), raw: raw}

  def part_one(state) do
    %{output: solution} = __MODULE__.Computer.run_program(state)

    Enum.reverse(solution)
    |> Enum.join(",")
  end

  def part_two(%{raw: raw} = state) do
    desired = Enum.reverse(raw)

    Stream.from_index()
    |> Stream.transform(false, fn
      _a, true ->
        {:halt, nil}

      a, false ->
        if Integer.mod(a, 1_000_000) == 0 do
          IO.puts("A: #{div(a, 1_000_000)}M")
        end

        %{output: s} =
          %{state | A: a}
          |> __MODULE__.Computer.run_program()

        if s == desired do
          {[a], true}
        else
          {[], false}
        end
    end)
    |> Enum.to_list()
    |> List.last()
  end
end
