defmodule Aoc2024.Solutions.Y24.Day04 do
  alias __MODULE__.Detection
  alias AoC.Input

  @directions ~w(horizontal horizontal_inverse vertical vertical_inverse right_diagonal right_diagonal_inverse left_diagonal left_diagonal_inverse)a

  def parse(input, _part) do
    Input.read!(input)
    |> String.split("\n", trim: true)
    |> Enum.map(fn str ->
      str
      |> String.to_charlist()
      |> Enum.with_index(&{&2, &1})
      |> Map.new()
    end)
    |> Enum.with_index(&{&2, &1})
    |> Map.new()
  end

  def detect(input, word) do
    word_list = String.to_charlist(word)
    first_char = hd(word_list)

    Enum.flat_map_reduce(input, 0, fn {y, row}, acc ->
      {elems, detections} = detect_in_row(input, row, y, word_list, first_char)
      {elems, detections + acc}
    end)
  end

  def detect_in_row(map, row, y, word_list, first_char) do
    Enum.flat_map_reduce(row, 0, fn {x, char}, acc ->
      if char == first_char do
        {elems, detections} = detect_for_directions(map, {x, y}, word_list)
        {elems, acc + detections}
      else
        {[], acc}
      end
    end)
  end

  def detect_for_directions(map, coords, word_list) do
    Enum.flat_map_reduce(@directions, 0, fn d, acc ->
      res = detect(map, coords, d, word_list)

      if res == word_list do
        detection = %Detection{
          coords: coords,
          direction: d
        }

        {[detection], acc + 1}
      else
        {[], acc}
      end
    end)
  end

  def detect(map, {x, y}, direction, word) do
    length = Enum.count(word) - 1
    {delta_x, delta_y} = get_delta_for_direction(direction)

    Enum.reduce_while(0..length, [], fn i, acc ->
      x = x + delta_x * i
      y = y + delta_y * i

      char = get_in(map, [y, x]) || ?-

      new_acc = acc ++ [char]

      if partial_or_complete?(word, new_acc) do
        {:cont, new_acc}
      else
        {:halt, acc}
      end
    end)
  end

  def partial_or_complete?(expected, value) do
    not Enum.zip_reduce(expected, value, false, fn a, b, acc -> acc or a != b end)
  end

  def get_direction_for_delta(direction) do
    case direction do
      {1, 0} -> :horizontal
      {-1, 0} -> :horizontal_inverse
      {0, 1} -> :vertical
      {0, -1} -> :vertical_inverse
      {1, 1} -> :right_diagonal
      {1, -1} -> :right_diagonal_inverse
      {-1, -1} -> :left_diagonal_inverse
      {-1, 1} -> :left_diagonal
    end
  end

  def get_delta_for_direction(direction) do
    case direction do
      :horizontal -> {1, 0}
      :horizontal_inverse -> {-1, 0}
      :vertical -> {0, 1}
      :vertical_inverse -> {0, -1}
      :right_diagonal -> {1, 1}
      :right_diagonal_inverse -> {1, -1}
      :left_diagonal_inverse -> {-1, -1}
      :left_diagonal -> {-1, 1}
    end
  end

  def part_one(problem) do
    {_detections, count} = detect(problem, "XMAS")
    count
  end

  @xmas_directions ~w(left_diagonal right_diagonal left_diagonal_inverse right_diagonal_inverse)a

  def part_two(problem) do
    {detections, _count} = detect(problem, "MAS")
    {_mirrors, count} = detect_mirrors(detections)
    count
  end

  def detect_mirrors(detections) do
    lmap =
      Map.new(detections, fn %{direction: d, coords: coords} ->
        {%Detection{direction: d, coords: coords}, true}
      end)

    {ds, _acc} =
      Enum.flat_map_reduce(detections, lmap, fn
        %{direction: d} = detection, lookup when d not in @xmas_directions ->
          {[], Map.drop(lookup, [detection])}

        detection, lookup ->
          mirror_detections =
            get_mirror_detections(detection)
            |> Enum.reduce([], fn detection, acc ->
              if Map.get(lookup, detection, false) == true do
                [detection | acc]
              else
                acc
              end
            end)

          lookup = Map.drop(lookup, [detection | mirror_detections])

          case mirror_detections do
            [] -> {[], lookup}
            [mirror] -> {[{detection, mirror}], lookup}
            [_mirror, _second_mirror] -> raise "uh oh what now? #{inspect(detection)}"
          end
      end)

    {ds, Enum.count(ds)}
  end

  def get_mirror_detections(%{direction: dir, coords: {x, y}}) do
    {dx, dy} = get_delta_for_direction(dir)
    dir1 = get_direction_for_delta({dx * -1, dy})
    dir2 = get_direction_for_delta({dx, dy * -1})

    coord1 = {x + 2 * dx, y}
    coord2 = {x, y + 2 * dy}

    [%Detection{coords: coord1, direction: dir1}, %Detection{coords: coord2, direction: dir2}]
  end
end
