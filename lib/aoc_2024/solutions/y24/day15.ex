defmodule Aoc2024.Solutions.Y24.Day15 do
  alias Aoc2024.Helpers.GridMap
  alias Aoc2024.Helpers.Coords
  alias AoC.Input

  def parse(input, _part) do
    [room_string, commands_string] =
      Input.read!(input)
      |> String.split("\n\n", trim: true)

    {room, _bounds} = GridMap.string_to_map(room_string, &char_to_room_value/1)

    commands =
      commands_string
      |> String.to_charlist()
      |> parse(:commands, [])

    %{warehouse: room, commands: commands}
  end

  def parse([], :commands, acc), do: acc |> Enum.reject(&(&1 == :noop)) |> Enum.reverse()

  def parse([command | rest], :commands, acc) do
    command =
      case command do
        ?^ -> :up
        ?< -> :left
        ?> -> :right
        ?v -> :down
        ?\n -> :noop
      end

    parse(rest, :commands, [command | acc])
  end

  def value_to_char(:wall), do: ?#
  def value_to_char(:floor), do: ?.
  def value_to_char(:box), do: ?O
  def value_to_char(:robot), do: ?@

  def char_to_room_value(?#), do: :wall
  def char_to_room_value(?.), do: :floor
  def char_to_room_value(?O), do: :box
  def char_to_room_value(?@), do: :robot

  def part_one(%{warehouse: warehouse, commands: commands}) do
    {warehouse, _robot_position} = do_commands(warehouse, commands)

    str = GridMap.print_map(warehouse, &value_to_char/1)
    IO.puts("\n#{str}\n\n")

    sum_boxes(warehouse)
  end

  def do_commands(state, commands) do
    {robot_position, :robot} =
      Enum.find(state, &(elem(&1, 1) == :robot))

    Enum.reduce(commands, {state, robot_position}, fn command, {map, position} ->
      move(position, map, command)
    end)
  end

  def move(position, map, command) do
    if Map.get(map, position) != :robot, do: raise("We're not the robot, abort")

    delta = GridMap.get_delta(position, command)

    case Map.get(map, delta) do
      nil -> {map, position}
      :wall -> {map, position}
      :box -> maybe_switch(map, position, delta, command)
      :floor -> switch(map, position, delta)
    end
  end

  def maybe_switch(map, position, wished_position, direction) do
    case maybe_switch_boxes(map, wished_position, direction) do
      {:not_switched, _res} -> {map, position}
      {:switched, {map, _}} -> switch(map, position, wished_position)
    end
  end

  def maybe_switch_boxes(map, position, direction) do
    new_position =
      Stream.from_index()
      |> Enum.reduce_while(position, fn _i, position ->
        delta = GridMap.get_delta(position, direction)

        case Map.get(map, delta) do
          :wall -> {:halt, nil}
          :floor -> {:halt, delta}
          _ -> {:cont, delta}
        end
      end)

    case new_position do
      nil -> {:not_switched, {map, position}}
      x -> {:switched, switch(map, position, x)}
    end
  end

  def switch(map, position, nil), do: {map, position}

  def switch(map, position, new_position) do
    a = Map.get(map, position)
    map = Map.put(map, position, Map.get(map, new_position))
    map = Map.put(map, new_position, a)

    {map, new_position}
  end

  def sum_boxes(map) do
    Enum.reduce(map, 0, fn
      {coords, :box}, acc -> acc + gps(coords)
      _, acc -> acc
    end)
  end

  def gps(%Coords{x: x, y: y}), do: y * 100 + x

  # def part_two(problem) do
  #   problem
  # end
end
