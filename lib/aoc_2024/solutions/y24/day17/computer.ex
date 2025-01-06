defmodule Aoc2024.Solutions.Y24.Day17.Computer do
  def run_program(%{pointer: pointer, program: program} = state) do
    case Map.get(program, pointer) do
      nil ->
        state

      [instruction, operand] ->
        do_instruction(state, instruction, operand)
        |> run_program()
    end
  end

  # adv
  def do_instruction(state, 0, operand) do
    %{state | A: division(state, operand)}
    |> next_pointer()
  end

  # bxl
  def do_instruction(%{B: b} = state, 1, operand),
    do: %{state | B: Bitwise.bxor(b, operand)} |> next_pointer()

  # bst
  def do_instruction(state, 2, operand) do
    %{state | B: mod_8(state, operand)}
    |> next_pointer()
  end

  # jnz
  def do_instruction(%{A: 0} = state, 3, _operand), do: next_pointer(state)

  def do_instruction(state, 3, operand), do: %{state | pointer: operand}

  # bxc
  def do_instruction(%{B: b, C: c} = state, 4, _operand) do
    %{state | B: Bitwise.bxor(b, c)}
    |> next_pointer()
  end

  # out
  def do_instruction(%{output: output} = state, 5, operand) do
    %{state | output: [mod_8(state, operand) | output]}
    |> next_pointer()
  end

  # bdv
  def do_instruction(state, 6, operand) do
    %{state | B: division(state, operand)}
    |> next_pointer()
  end

  # cdv
  def do_instruction(state, 7, operand) do
    %{state | C: division(state, operand)}
    |> next_pointer()
  end

  def division(%{A: a} = state, operand) do
    denominator_power = combo(state, operand)
    denominator = :math.pow(2, denominator_power)
      |> trunc()
    div(a, denominator)
  end

  defp mod_8(state, operand) do
    val = combo(state, operand)
    Integer.mod(val, 8)
  end

  defp next_pointer(%{pointer: p} = state), do: %{state | pointer: p + 2}

  defp combo(state, operand) do
    case operand do
      4 -> Map.get(state, :A)
      5 -> Map.get(state, :B)
      6 -> Map.get(state, :C)
      7 -> raise "not valid"
      _ -> operand
    end
  end
end
