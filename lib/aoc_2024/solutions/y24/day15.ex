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
  def value_to_char(:left_part_box), do: ?[
  def value_to_char(:right_part_box), do: ?]
  def value_to_char(:robot), do: ?@

  def char_to_room_value(?#), do: :wall
  def char_to_room_value(?.), do: :floor
  def char_to_room_value(?O), do: :box
  def char_to_room_value(?@), do: :robot

  def part_one(%{warehouse: warehouse, commands: commands}) do
    {warehouse, _robot_position} = do_commands(warehouse, commands)

    sum_boxes(warehouse)
  end

  def part_two(%{warehouse: warehouse, commands: commands}) do
    # I imagine this can be done the same way, without really expanding,
    # but the boxes being in 2 places trips me up a bit

    warehouse = expand_warehouse(warehouse)
    str = GridMap.print_map(warehouse, &value_to_char/1)
    IO.puts("\n#{str}\n\n")

    {warehouse, _robot_position} = do_commands(warehouse, commands)
    sum_boxes(warehouse)
  end

  def expand_warehouse(warehouse) do
    Enum.reduce(warehouse, %{}, fn {k, v}, acc ->
      c1 = %Coords{x: k.x * 2, y: k.y}
      c2 = %Coords{x: k.x * 2 + 1, y: k.y}

      case v do
        :wall ->
          Map.put(acc, c1, :wall)
          |> Map.put(c2, :wall)

        :floor ->
          Map.put(acc, c1, :floor)
          |> Map.put(c2, :floor)

        :box ->
          Map.put(acc, c1, :left_part_box)
          |> Map.put(c2, :right_part_box)

        :robot ->
          Map.put(acc, c1, :robot)
          |> Map.put(c2, :floor)
      end
    end)
  end

  def do_commands(state, commands) do
    {robot_position, :robot} =
      Enum.find(state, &(elem(&1, 1) == :robot))

    Enum.reduce(commands, {state, robot_position}, fn command, {map, position} ->
      execute_command(position, map, command)
    end)
  end

  def execute_command(position, map, command) do
    # if Map.get(map, position) != :robot, do: raise("We're not the robot, abort")
    delta = GridMap.get_delta(position, command)

    case Map.get(map, delta) do
      # nil -> {map, position}
      :wall -> {map, position}
      :box -> maybe_move(map, position, delta, command, &switch/4)
      :left_part_box -> maybe_move(map, position, delta, command, &push/4)
      :right_part_box -> maybe_move(map, position, delta, command, &push/4)
      :floor -> switch(map, position, delta, command)
    end
  end

  def next_open_spot(map, position, direction) do
    fork = direction in [:up, :down]

    Stream.from_index()
    |> Enum.reduce_while(position, fn _i, position ->
      delta = GridMap.get_delta(position, direction)
      delta_value = Map.get(map, delta)

      cond do
        :floor == delta_value ->
          {:halt, delta}

        fork and delta_value == :left_part_box and
            next_open_spot(map, %Coords{y: delta.y, x: delta.x + 1}, direction) != nil ->
          {:cont, delta}

        fork and delta_value == :right_part_box and
            next_open_spot(map, %Coords{y: delta.y, x: delta.x - 1}, direction) != nil ->
          {:cont, delta}

        :box == delta_value ->
          {:cont, delta}

        true ->
          {:halt, nil}
      end
    end)
  end

  def maybe_move(map, position, wished_position, direction, fn_move) do
    case maybe_move_boxes(map, wished_position, direction, fn_move) do
      {:not_moved, _res} -> {map, position}
      {:moved, {map, _}} -> switch(map, position, wished_position, direction)
    end
  end

  def maybe_move_boxes(map, position, direction, fn_move) do
    case next_open_spot(map, position, direction) do
      nil -> {:not_moved, {map, position}}
      free_spot -> {:moved, fn_move.(map, position, free_spot, direction)}
    end
  end

  def push(map, position, nil, _direction), do: {map, position}

  def push(map, from, to, direction) do
  end

  def switch(map, position, nil, _direction), do: {map, position}

  def switch(map, position, new_position, _direction) do
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
end
