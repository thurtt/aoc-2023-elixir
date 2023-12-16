defmodule AdventOfCode.Day04 do
  def part1(_args) do
    {winning_numbers, card_numbers} =
      File.stream!("inputs/d04.txt")
      |> Stream.map(&Regex.scan(~r/.*?\:\s((?:\d|\s)+)\|((?:\d|\s)+)/, &1))
      |> Enum.map(&Enum.at(&1, 0))
      |> Enum.reduce(
        {[], []},
        &{elem(&2, 0) ++ [Enum.at(&1, 1)], elem(&2, 1) ++ [Enum.at(&1, 2)]}
      )

    winning_numbers = Enum.map(winning_numbers, &process_number_set(&1))

    card_numbers = Enum.map(card_numbers, &process_number_set(&1))

    Enum.zip([winning_numbers, card_numbers])
    |> Enum.reduce([], &match_against_winning_numbers(&1, &2))
    |> Enum.reduce([], &total_points(&1, &2))
    |> Enum.sum()
  end

  def part2(_args) do
    {game, winning_numbers, card_numbers} =
      File.stream!("inputs/d04.txt")
      |> Stream.map(&Regex.scan(~r/.*?(\d+)\:\s((?:\d|\s)+)\|((?:\d|\s)+)/, &1))
      |> Enum.map(&Enum.at(&1, 0))
      |> Enum.reduce(
        {[], [], []},
        &{elem(&2, 0) ++ [String.to_integer(Enum.at(&1, 1))], elem(&2, 1) ++ [Enum.at(&1, 2)],
         elem(&2, 2) ++ [Enum.at(&1, 3)]}
      )

    winning_numbers = Enum.map(winning_numbers, &process_number_set(&1))

    card_numbers = Enum.map(card_numbers, &process_number_set(&1))

    wins =
      Enum.zip([winning_numbers, card_numbers])
      |> Enum.reduce([], &match_against_winning_numbers(&1, &2))

    win_table =
      Enum.zip([game, wins])
      |> Enum.reduce(
        [],
        &(&2 ++ [%{game: elem(&1, 0), wins: length(elem(&1, 1)), copies: 1}])
      )

    Enum.reduce(win_table, win_table, &process_game(&1, &2))
    |> Enum.reduce(0, &(&1[:copies] + &2))
  end

  def process_number_set(number_set) do
    String.trim(number_set)
    |> String.split(~r/\s+/)
  end

  def match_against_winning_numbers({winning_numbers, card_numbers}, acc) do
    winning = MapSet.new(winning_numbers)
    cards = MapSet.new(card_numbers)

    matching =
      MapSet.intersection(winning, cards)
      |> MapSet.to_list()

    acc ++ [matching]
  end

  def total_points(matching, acc) do
    match_count = length(matching)

    case match_count do
      0 ->
        acc

      _ ->
        [2 ** (length(matching) - 1) | acc]
    end
  end

  def process_game(win_table_item, acc) do
    index = win_table_item[:game]
    acc_item = Enum.at(acc, index - 1)
    amount = acc_item[:copies]
    win_counter = win_table_item[:wins]
    distribute_cards(win_counter, amount, index, acc)
  end

  def distribute_cards(win_counter, amount, index, win_table) do
    case win_counter do
      0 ->
        win_table

      _ ->
        win_table = Enum.map(win_table, &modify_win_table(&1, index + 1, amount))
        distribute_cards(win_counter - 1, amount, index + 1, win_table)
    end
  end

  def modify_win_table(table_entry, game, amount) do
    if game == table_entry[:game] do
      Map.put(table_entry, :copies, amount + table_entry[:copies])
    else
      table_entry
    end
  end
end
