defmodule AdventOfCode.Day05 do
  def part1(_args) do
    file_lines =
      File.stream!("inputs/d05.txt")
      |> Enum.map(&String.trim(&1))

    seeds = Enum.reduce(file_lines, [], &seeds(&1, &2))
    maps = generate_maps(file_lines, %{})

    build_seed_to_location_map(seeds, maps, [])
    |> Enum.filter(&(&1 > 0))
    |> Enum.min()
  end

  def part2(_args) do
    file_lines =
      File.stream!("inputs/d05.txt")
      |> Enum.map(&String.trim(&1))

    seeds =
      Enum.reduce(file_lines, [], &seed_ranges(&1, &2))
      |> Enum.map(&seed_range(&1))

    maps = generate_maps(file_lines, %{})

    Enum.map(seeds, &seed_map_worker(&1, maps))

    IO.puts("Waiting for results")
    loop([])
  end

  def loop(all_locations) do
    receive do
      {:result, location_numbers} ->
        IO.puts("Received response: #{location_numbers}")
        loop([location_numbers | all_locations])
    after
      900_000 ->
        IO.puts("Processing Complete")
        all_locations
    end
  end

  def seed_map_worker(seeds, maps) do
    caller = self()
    IO.puts("Spawning a new process")

    spawn(fn ->
      send(
        caller,
        {:result, build_seed_to_location_wrapper(seeds, maps)}
      )
    end)
  end

  def build_seed_to_location_wrapper(seeds, maps) do
    location =
      build_seed_to_location_map(seeds, maps, [])
      |> Enum.filter(&(&1 > 0))

    IO.puts("Processing complete for #{inspect(self())}")

    if location do
      Enum.min(location)
    else
      0
    end
  end

  def seed_range(range) do
    [start, len] = range
    start = String.to_integer(start)
    seed_end = start + String.to_integer(len)
    Enum.to_list(start..seed_end)
  end

  def seeds(line, acc) do
    case Regex.run(~r/seeds\:\s(.*)/, line) do
      [_full_line, seed_lines] ->
        String.split(seed_lines, ~r/\s+/)
        |> Enum.map(&String.to_integer(&1))

      _ ->
        acc
    end
  end

  def print_range(range_stream) do
    Enum.map(range_stream, &IO.puts(&1))
  end

  def seed_ranges(line, acc) do
    case Regex.run(~r/seeds\:\s(.*)/, line) do
      [_full_line, seed_lines] ->
        Regex.scan(~r/(\d+\s\d+)/, seed_lines)
        |> Enum.map(&Enum.at(&1, 1))
        |> Enum.map(&String.split(&1))

      _ ->
        acc
    end
  end

  def generate_maps(lines, acc) do
    if lines == [] do
      acc
    else
      [line | remainder] = lines

      case Regex.run(~r/(.+?)\s+map\:/, line) do
        [_, file_line] ->
          key =
            String.replace(file_line, "-", "_")
            |> String.to_atom()

          acc =
            Map.put(acc, key, [])
            |> Map.put(:current_section, key)

          generate_maps(remainder, acc)

        _ ->
          case Regex.run(~r/(\d+)\s+(\d+)\s(\d+)/, line) do
            [_, dest_start, src_start, range_len] ->
              mapping = %{
                dst_start: String.to_integer(dest_start),
                src_start: String.to_integer(src_start),
                range_len: String.to_integer(range_len)
              }

              key = acc[:current_section]
              mappings = [mapping | acc[key]]
              acc = Map.put(acc, key, mappings)
              generate_maps(remainder, acc)

            _ ->
              generate_maps(remainder, acc)
          end
      end
    end
  end

  def build_seed_to_location_map(seeds, maps, complete_maps) do
    if seeds == [] do
      complete_maps
    else
      [seed | remainder] = seeds

      seed_to_soil = Enum.reduce(maps[:seed_to_soil], 0, &mapinator_3000(&1, &2, seed))

      soil_to_fertilizer =
        Enum.reduce(maps[:soil_to_fertilizer], 0, &mapinator_3000(&1, &2, seed_to_soil))

      fertilizer_to_water =
        Enum.reduce(maps[:fertilizer_to_water], 0, &mapinator_3000(&1, &2, soil_to_fertilizer))

      water_to_light =
        Enum.reduce(maps[:water_to_light], 0, &mapinator_3000(&1, &2, fertilizer_to_water))

      light_to_temperature =
        Enum.reduce(maps[:light_to_temperature], 0, &mapinator_3000(&1, &2, water_to_light))

      temperature_to_humidity =
        Enum.reduce(
          maps[:temperature_to_humidity],
          0,
          &mapinator_3000(&1, &2, light_to_temperature)
        )

      humidity_to_location =
        Enum.reduce(
          maps[:humidity_to_location],
          0,
          &mapinator_3000(&1, &2, temperature_to_humidity)
        )

      build_seed_to_location_map(remainder, maps, [humidity_to_location | complete_maps])
    end
  end

  def mapinator_3000(map_line, acc, seed) do
    min_value = map_line[:src_start]
    max_value = min_value + map_line[:range_len]

    if seed >= min_value and seed <= max_value do
      adder = seed - min_value

      map_line[:dst_start] + adder
    else
      acc
    end
  end
end
