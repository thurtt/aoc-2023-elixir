defmodule AdventOfCode.Day07 do
  @rank_table %{
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "T" => 10,
    "J" => 11,
    "Q" => 12,
    "K" => 13,
    "A" => 14
  }

  @hand_table %{
    [5] => :five_of_a_kind,
    [4, 1] => :four_of_a_kind,
    [3, 2] => :full_house,
    [3, 1, 1] => :three_of_a_kind,
    [2, 2, 1] => :two_pair,
    [2, 1, 1, 1] => :one_pair,
    [1, 1, 1, 1, 1] => :high_card
  }

  @hand_rank %{
    five_of_a_kind: 7,
    four_of_a_kind: 6,
    full_house: 5,
    three_of_a_kind: 4,
    two_pair: 3,
    one_pair: 2,
    high_card: 1
  }

  def part1(_args) do
    hands =
      File.stream!("inputs/d07.txt")
      |> Enum.map(&String.split(&1))

    hand_types =
      Enum.map(hands, &rank_cards(Enum.at(&1, 0), @rank_table))
      |> Enum.map(&determine_hand(&1))

    analyzed_hands =
      Enum.zip(hands, hand_types)
      |> Enum.map(&rank_hand(&1))
      |> Enum.sort(&(&1[:hand_rank] > &2[:hand_rank]))

    sorted_hands =
      Enum.reduce(
        Map.keys(@hand_rank),
        [],
        &(&2 ++ filter_and_sort_hand_type(analyzed_hands, &1))
      )

    Enum.reverse(sorted_hands)
    |> Enum.with_index(fn hand, index -> Map.put(hand, :overall_rank, index + 1) end)
    |> Enum.reverse()
    |> Enum.map(&Map.put(&1, :combined_value, &1[:overall_rank] * &1[:bet]))
    |> Enum.reduce(0, &(&1[:combined_value] + &2))
  end

  def part2(_args) do
    rank_table = Map.put(@rank_table, "J", 1)

    hands =
      File.stream!("inputs/d07.txt")
      |> Enum.map(&String.split(&1))

    hand_types =
      Enum.map(hands, &rank_cards(Enum.at(&1, 0), rank_table))
      |> Enum.map(&determine_hand_with_wilds(&1))

    analyzed_hands =
      Enum.zip(hands, hand_types)
      |> Enum.map(&rank_hand(&1))
      |> Enum.sort(&(&1[:hand_rank] > &2[:hand_rank]))

    sorted_hands =
      Enum.reduce(
        Map.keys(@hand_rank),
        [],
        &(&2 ++ filter_and_sort_hand_type(analyzed_hands, &1))
      )

    Enum.reverse(sorted_hands)
    |> Enum.with_index(fn hand, index -> Map.put(hand, :overall_rank, index + 1) end)
    |> Enum.reverse()
    |> Enum.map(&Map.put(&1, :combined_value, &1[:overall_rank] * &1[:bet]))
    |> Enum.reduce(0, &(&1[:combined_value] + &2))
  end

  def rank_cards(hand, rank_table) do
    String.graphemes(hand)
    |> Enum.reduce([], &[rank_table[&1] | &2])
    |> Enum.reverse()
  end

  def determine_hand(hand) do
    ranked_cards =
      Enum.frequencies_by(hand, & &1)
      |> Map.values()
      |> Enum.sort(:desc)

    %{
      hand: @hand_table[ranked_cards],
      ranked_cards: ranked_cards,
      raw_hand: hand
    }
  end

  def determine_hand_with_wilds(hand) do
    card_frequencies = Enum.frequencies_by(hand, & &1)
    joker_count = Enum.reduce(card_frequencies, {}, &if(elem(&1, 0) == 1, do: &1, else: &2))

    highest_value = Enum.reduce(card_frequencies, {0, 0}, &max_value(&1, &2))

    case joker_count do
      {1, count} ->
        key = elem(highest_value, 0)
        val = elem(highest_value, 1)

        ranked_cards =
          Map.put(card_frequencies, key, val + count)
          |> Map.delete(1)
          |> Map.values()
          |> Enum.sort(:desc)

        %{
          hand: @hand_table[ranked_cards],
          ranked_cards: ranked_cards,
          raw_hand: hand
        }

      _ ->
        ranked_cards =
          Map.values(card_frequencies)
          |> Enum.sort(:desc)

        %{
          hand: @hand_table[ranked_cards],
          ranked_cards: ranked_cards,
          raw_hand: hand
        }
    end
  end

  def max_value(item, acc) do
    cond do
      elem(item, 1) > elem(acc, 1) and elem(item, 0) != 1 ->
        item

      elem(item, 0) > elem(acc, 0) && elem(item, 1) == elem(acc, 1) ->
        item

      true ->
        acc
    end
  end

  def rank_hand({hand, ranked_cards}) do
    rank_name = ranked_cards[:hand]

    %{
      cards: Enum.at(hand, 0),
      bet: String.to_integer(Enum.at(hand, 1)),
      hand_rank: @hand_rank[rank_name],
      rank_name: rank_name,
      card_rank: ranked_cards[:ranked_cards],
      raw_hand: ranked_cards[:raw_hand]
    }
  end

  def sort_by_hand(filtered_hand) do
    Enum.sort(filtered_hand, &(&1[:raw_hand] > &2[:raw_hand]))
  end

  def filter_and_sort_hand_type(analyzed_hands, type) do
    Enum.filter(analyzed_hands, &(&1[:rank_name] == type))
    |> sort_by_hand()
  end

  def filter_and_sort_by_card_rank(subset, index) do
    Enum.filter(subset, &Enum.at(&1[:card_rank], index))
    |> Enum.sort(&(&1 > &2))
  end
end
