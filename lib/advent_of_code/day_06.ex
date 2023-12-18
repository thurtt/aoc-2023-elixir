defmodule AdventOfCode.Day06 do
  def part1(_args) do
    races =
      File.stream!("inputs/d06.txt")
      |> Enum.map(&Regex.scan(~r/(\w+)\:\s+(.*)/, &1))
      |> Enum.map(&build_input_map(&1))
      |> Enum.reduce(%{}, &Map.merge(&1, &2))

    find_ideal_hold_time(races[:Time], races[:Distance], [])
    |> Enum.map(&{trunc(&1[:x1]), trunc(&1[:x2])})
    |> Enum.map(&combine_values(&1))
    |> Enum.product()
  end

  def part2(_args) do
    races =
      File.stream!("inputs/d06.txt")
      |> Enum.map(&Regex.scan(~r/(\w+)\:\s+(.*)/, &1))
      |> Enum.map(&build_input_map_part_2(&1))
      |> Enum.reduce(%{}, &Map.merge(&1, &2))

    find_ideal_hold_time(races[:Time], races[:Distance], [])
    |> Enum.map(&{trunc(&1[:x1]), trunc(&1[:x2])})
    |> Enum.map(&combine_values(&1))
    |> Enum.product()
  end

  def build_input_map(file_line) do
    file_line = Enum.at(file_line, 0)
    key = String.to_atom(Enum.at(file_line, 1))

    values =
      String.split(Enum.at(file_line, 2))
      |> Enum.map(&String.to_integer(&1))

    %{key => values}
  end

  def build_input_map_part_2(file_line) do
    file_line = Enum.at(file_line, 0)
    key = String.to_atom(Enum.at(file_line, 1))

    value =
      String.split(Enum.at(file_line, 2))
      |> Enum.join()
      |> String.to_integer()

    %{key => [value]}
  end

  def find_ideal_hold_time(race_times, records, acc) do
    case race_times do
      [] ->
        acc

      _ ->
        [race_time | race_remainder] = race_times
        [record | record_remainder] = records

        result = quadradify(1, -race_time, record)
        find_ideal_hold_time(race_remainder, record_remainder, [result | acc])
    end
  end

  def combine_values({max, min}) do
    abs(min - max + 1)
  end

  def quadradify(a, b, c) do
    case b ** 2 - 4 * a * c do
      disc when disc > 0 ->
        x1 = (-b + :math.sqrt(disc)) / (2 * a)
        x2 = (-b - :math.sqrt(disc)) / (2 * a)
        %{x1: Float.ceil(x1), x2: Float.floor(x2)}

      disc when disc == 0 ->
        x = -b / (2 * a)
        %{x1: x, x2: x}

      disc ->
        # roots are imaginary
        real = -b / (2 * a)
        img = :math.sqrt(-disc) / (2 * a)
        %{x1: Complex.new(real, img), x2: Complex.new(real, -img)}
    end
  end
end
