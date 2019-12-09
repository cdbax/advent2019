defmodule Advent2019.Six do
  def main(input_filename) do
    File.stream!(input_filename)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_orbit/1)
    # |> sum_orbits()
    |> round_2
  end

  def parse_orbit(orbit) do
    <<inner::bytes-size(3), ")", outer::bytes-size(3)>> = orbit
    %{inner: inner, outer: outer}
  end

  def sum_orbits(orbits) do
    graph = :digraph.new()

    Enum.reduce(orbits, MapSet.new(), fn orbit, acc ->
      :digraph.add_vertex(graph, orbit[:inner])
      :digraph.add_vertex(graph, orbit[:outer])
      :digraph.add_edge(graph, orbit[:inner], orbit[:outer])
      acc = MapSet.put(acc, orbit[:inner])
      MapSet.put(acc, orbit[:outer])
    end)
    |> MapSet.to_list()
    |> Enum.reduce(0, fn v, acc ->
      :digraph_utils.reaching([v], graph)
      |> Enum.count()
      |> Kernel.-(1)
      |> Kernel.+(acc)
    end)
  end

  def round_2(orbits) do
    graph = :digraph.new()

    Enum.each(orbits, fn orbit ->
      :digraph.add_vertex(graph, orbit[:inner])
      :digraph.add_vertex(graph, orbit[:outer])
      :digraph.add_edge(graph, orbit[:inner], orbit[:outer])
    end)

    count_orbital_xfers(graph, "YOU", "SAN")
  end

  def count_orbital_xfers(graph, vert_a, vert_b) do
    a_parents = :digraph_utils.reaching([vert_a], graph) |> MapSet.new()
    b_parents = :digraph_utils.reaching([vert_b], graph) |> MapSet.new()
    shared = MapSet.intersection(a_parents, b_parents)

    closest_shared =
      shared
      |> Enum.map(fn v -> {v, :digraph_utils.reaching([v], graph) |> Enum.count()} end)
      |> Enum.max_by(fn {_, count} -> count end)
      |> elem(0)

    path_a = :digraph.get_path(graph, closest_shared, vert_a) |> Enum.count() |> Kernel.-(2)
    path_b = :digraph.get_path(graph, closest_shared, vert_b) |> Enum.count() |> Kernel.-(2)
    path_a + path_b
  end
end
