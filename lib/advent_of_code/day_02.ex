defmodule AdventOfCode.Day02 do
  def part1(_args) do
    cubes = %{
      red: 12,
      green: 13,
      blue: 14
    }

    # break the data up for each color
    File.stream!("inputs/d02.txt")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.split(&1, ";"))
    |> Enum.map(&extract_game_id(&1))
    |> Enum.map(&find_largest_color_count(&1))
    |> Enum.reduce(0, &find_possible_games(&1, &2, cubes))
    |> Enum.uniq()
  end

  def part2(_args) do
    File.stream!("inputs/d02.txt")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.split(&1, ";"))
    |> Enum.map(&extract_game_id(&1))
    |> Enum.map(&find_largest_color_count(&1))
    |> Enum.map(&get_game_powers(&1))
    |> Enum.sum()
  end

  def extract_game_id(game) do
    # Separate game id from cube counts
    [head | tail] = game
    [game_id, round_one] = String.split(head, ":")
    all_colors = [round_one | tail]

    all_colors =
      Enum.map(all_colors, &map_color_to_value(&1))

    game_id =
      Regex.scan(~r/.*?(\d+)/, game_id)
      |> List.flatten()
      |> List.last()

    %{game_id => all_colors}
  end

  def map_color_to_value(game) do
    parsed_colors = String.split(game, ",")

    Enum.map(parsed_colors, &Regex.scan(~r/(\d+)\s+(.*)/, &1))
    |> Enum.map(&List.flatten(&1))
    |> Enum.map(&make_color_map(&1))
    |> Enum.reduce(&Map.merge(&1, &2))
  end

  def make_color_map(item) do
    [_ | tail] = item
    [value | color] = tail
    %{String.to_atom(List.first(color)) => value}
  end

  def find_largest_color_count(entry) do
    key =
      Map.keys(entry)
      |> List.first()

    grabs = entry[key]

    max_values = Enum.reduce(grabs, %{red: 0, green: 0, blue: 0}, &max_colors(&1, &2))

    %{key => max_values}
  end

  def max_colors(item, acc) do
    %{
      red: max_color(item, acc, :red),
      green: max_color(item, acc, :green),
      blue: max_color(item, acc, :blue)
    }
  end

  def max_color(item, acc, color) do
    if Map.has_key?(item, color) do
      value = String.to_integer(item[color])

      if value > acc[color] do
        value
      else
        acc[color]
      end
    else
      acc[color]
    end
  end

  def find_possible_games(max_grabs, acc, max_cubes) do
    key =
      Map.keys(max_grabs)
      |> List.first()
      |> String.to_integer()

    grabs =
      Map.values(max_grabs)
      |> List.first()

    if max_cubes[:green] >= grabs[:green] and max_cubes[:red] >= grabs[:red] and
         max_cubes[:blue] >= grabs[:blue] do
      key + acc
    else
      acc
    end
  end

  def get_game_powers(item) do
    key =
      Map.keys(item)
      |> List.first()

    colors = item[key]
    colors[:red] * colors[:green] * colors[:blue]
  end
end
