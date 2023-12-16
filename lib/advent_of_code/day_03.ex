defmodule AdventOfCode.Day03 do
  def part1(_args) do
    {schematic, row_count, col_count} = load_schematic("inputs/d03.txt")

    {numbers, symbols} = walk_table(schematic, 0, 0, col_count, row_count, [], [])

    Enum.with_index(numbers)
    |> Enum.reduce(%{numbers: [], acc: []}, &number_accumulator(&1, &2, numbers))
    |> Enum.map(&cast_key_to_int(&1))
    |> Enum.map(&generate_adjacent_matrix(&1))
    |> Enum.reduce([], &find_part_numbers(&1, &2, symbols))
    |> Enum.map(&get_key(&1))
    |> Enum.sum()
  end

  def part2(_args) do
    {schematic, row_count, col_count} = load_schematic("inputs/d03.txt")

    {numbers, symbols} = walk_table(schematic, 0, 0, col_count, row_count, [], [])
    star_symbols = Enum.filter(symbols, &(get_key(&1) == "*"))
    # IO.inspect(star_symbols, limit: :infinity, charlists: :as_lists)

    Enum.with_index(numbers)
    |> Enum.reduce(%{numbers: [], acc: []}, &number_accumulator(&1, &2, numbers))
    |> Enum.map(&cast_key_to_int(&1))
    |> Enum.map(&generate_adjacent_matrix(&1))
    |> Enum.reduce([], &find_part_numbers(&1, &2, star_symbols))
    |> Enum.reverse()
    |> Enum.reduce(%{"" => []}, &transform_map(&1, &2))
    |> Enum.filter(&(length(elem(&1, 1)) > 1))
    |> Enum.map(&multiply_gears(&1))
    |> Enum.sum()

    # |> IO.inspect(limit: :infinity, charlists: :as_lists)
  end

  def load_schematic(filename) do
    schematic =
      File.stream!(filename)
      |> Enum.map(&String.trim(&1))
      |> Enum.map(&String.graphemes(&1))
      |> Enum.map(&List.to_tuple(&1))
      |> List.to_tuple()

    row_count = tuple_size(schematic)

    col_count =
      elem(schematic, 0)
      |> tuple_size()

    {schematic, row_count, col_count}
  end

  def walk_table(table, x, y, cols, rows, numbers, symbols) do
    val =
      elem(table, y)
      |> elem(x)

    {numbers, symbols} =
      cond do
        String.match?(val, ~r/\d/) ->
          {[%{val => {x, y}} | numbers], symbols}

        String.match?(val, ~r/\./) ->
          {numbers, symbols}

        true ->
          {numbers, [%{val => {x, y}} | symbols]}
      end

    case {x, y} do
      {x, y} when x == cols - 1 and y == rows - 1 ->
        {Enum.reverse(numbers), Enum.reverse(symbols)}

      {x, _} when x == cols - 1 ->
        walk_table(table, 0, y + 1, cols, rows, numbers, symbols)

      _ ->
        walk_table(table, x + 1, y, cols, rows, numbers, symbols)
    end
  end

  def number_accumulator(item, acc, numbers) do
    {number, index} = item

    case {number, index} do
      {_, 0} ->
        %{numbers: [], acc: [number]}

      _ ->
        prev = Enum.at(numbers, index - 1)

        prev_key = get_key(prev)

        prev_coords = prev[prev_key]
        prev_x = elem(prev_coords, 0)
        prev_y = elem(prev_coords, 1)

        cur = number

        cur_key = get_key(cur)

        cur_coords = cur[cur_key]
        cur_x = elem(cur_coords, 0)
        cur_y = elem(cur_coords, 1)

        cond do
          # accumulate contiguous numbers
          cur_x == prev_x + 1 and cur_y == prev_y ->
            if index < length(numbers) - 1 do
              %{numbers: acc[:numbers], acc: acc[:acc] ++ [cur]}
            else
              combined =
                Enum.reduce(acc[:acc] ++ [cur], %{"" => []}, &combine_accumulated_values(&1, &2))

              acc[:numbers] ++ [combined]
            end

          # if there a non-contiguous numbers, save off the accumulated values
          true ->
            combined =
              Enum.reduce(acc[:acc], %{"" => []}, &combine_accumulated_values(&1, &2))

            %{numbers: acc[:numbers] ++ [combined], acc: [cur]}
        end
    end
  end

  def combine_accumulated_values(acc, combined) do
    key = get_key(acc)
    values = acc[key]

    cmb_key = get_key(combined)

    cmb_vals = combined[cmb_key] ++ [values]
    %{"#{cmb_key}#{key}" => cmb_vals}
  end

  def cast_key_to_int(item) do
    key = get_key(item)
    %{String.to_integer(key) => item[key]}
  end

  def generate_adjacent_matrix(number) do
    key = get_key(number)

    coords = number[key]

    adjacent_coords =
      Enum.reduce(coords, [], &surrounding_coords(&1, &2))
      |> Enum.uniq()

    %{key => adjacent_coords}
  end

  def surrounding_coords(coords, acc) do
    {x, y} = coords

    Enum.concat(
      [
        {x - 1, y - 1},
        {x, y - 1},
        {x + 1, y - 1},
        {x - 1, y},
        {x + 1, y},
        {x - 1, y + 1},
        {x, y + 1},
        {x + 1, y + 1}
      ],
      acc
    )
  end

  def find_part_numbers(numbers, acc, symbols) do
    key = get_key(numbers)

    coords = numbers[key]

    matching_coordinates =
      Enum.reduce(symbols, [], &match_coordinates(&1, &2, coords))

    if matching_coordinates != [] do
      [%{key => matching_coordinates} | acc]
    else
      acc
    end
  end

  def match_coordinates(symbol, acc, coords) do
    key = get_key(symbol)

    sym_coords = symbol[key]

    if Enum.member?(coords, sym_coords) do
      [sym_coords | acc]
    else
      acc
    end
  end

  def get_key(item) do
    Map.keys(item)
    |> List.first()
  end

  def transform_map(item, acc) do
    key = get_key(item)
    new_key = Enum.at(item[key], 0)

    if Map.has_key?(acc, new_key) do
      %{acc | new_key => [key | acc[new_key]]}
    else
      Map.put(acc, new_key, [key | []])
    end
  end

  def multiply_gears(item) do
    {_, [gear_1, gear_2]} = item
    gear_1 * gear_2
  end
end
