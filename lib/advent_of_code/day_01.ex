defmodule AdventOfCode.Day01 do
  def part1(_args) do
    File.stream!("inputs/d01p1.txt")
    |> Stream.map(&Regex.scan(~r/\D*?(\d)+?/, &1))
    |> Enum.map(&filter_item_values(&1))
    |> Enum.reduce(0, &(elem(&1, 0) + &2))
  end

  def part2(_args) do
    File.stream!("inputs/d01p1.txt")
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&words_to_values(&1))
    |> Enum.reduce(0, &(elem(&1, 0) + &2))
  end

  def filter_item_values(item) do
    head = List.first(item)
    t1 = List.last(head)

    tail = List.last(item)
    t2 = List.last(tail)
    IO.puts("#{t1}#{t2}")
    Integer.parse("#{t1}#{t2}")
  end

  def words_to_values(item) do
    lookup_table = %{
      "1" => "1",
      "2" => "2",
      "3" => "3",
      "4" => "4",
      "5" => "5",
      "6" => "6",
      "7" => "7",
      "8" => "8",
      "9" => "9",
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "four" => "4",
      "five" => "5",
      "six" => "6",
      "seven" => "7",
      "eight" => "8",
      "nine" => "9"
    }

    number_words =
      Enum.map(lookup_table, fn {k, _v} -> find_all_number_words(item, k) end)
      |> List.flatten()
      |> Enum.filter(&(!is_nil(&1)))

    begin_number_word =
      Enum.reduce(number_words, {nil, nil}, &find_first_number_word(&1, &2))
      |> elem(1)

    end_number_word =
      Enum.reduce(number_words, {nil, nil}, &find_last_number_word(&1, &2))
      |> elem(1)

    Integer.parse("#{lookup_table[begin_number_word]}#{lookup_table[end_number_word]}")
  end

  def find_all_number_words(item, number, acc \\ [], start \\ 0) do
    case :binary.match(item, number) do
      {index, len} ->
        remainder = String.slice(item, (index + len)..-1)

        find_all_number_words(
          remainder,
          number,
          [{start + index, number} | acc],
          start + index + len
        )

      _ ->
        acc
    end
  end

  def find_first_number_word(numberword, acc) do
    case acc do
      {nil, nil} ->
        numberword

      {idx, _} when elem(numberword, 0) < idx ->
        numberword

      _ ->
        acc
    end
  end

  def find_last_number_word(numberword, acc) do
    case acc do
      {nil, nil} ->
        numberword

      {idx, _} when elem(numberword, 0) > idx ->
        numberword

      _ ->
        acc
    end
  end
end
