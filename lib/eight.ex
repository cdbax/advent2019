defmodule Advent2019.Eight do
  def main(input_filename) do
    File.stream!(input_filename, [], 25)
    |> Stream.filter(&(&1 |> String.trim() |> String.length() > 0))
    |> Stream.map(fn chunk -> chunk |> String.codepoints() |> Enum.map(&String.to_integer/1) end)
    |> Stream.chunk_every(6)
    # |> layer_with_fewest_zeros()
    # |> (&(count_value(&1, 1) * count_value(&1, 2))).()
    |> build_image()
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.replace(&1, "1", "X"))
    |> Enum.map(&String.replace(&1, "0", " "))
    |> Enum.each(&IO.inspect/1)
  end

  @doc """
  ## Examples
  iex> Advent2019.Eight.layer_with_fewest_zeros([[[0,1,2],[1,2,3]],[[1,2,3],[2,3,4]]]) |> Enum.to_list
  [[0,1,2],[1,2,3]]
  """
  def layer_with_fewest_zeros(layers_stream) do
    layers_stream
    |> Enum.reduce(fn layer, acc ->
      (count_value(layer, 0) < count_value(acc, 0) && layer) || acc
    end)
  end

  def count_value(layer, val) do
    layer
    |> Enum.map(fn row -> Enum.count(row, &(&1 == val)) end)
    |> Enum.sum()
  end

  @doc """
    all layers
    |> group rows
    |> convert rows back to lists
    |> group pixels by row
    |> convert pixel tuples back to lists
    |> drop 2s and output first non-2
  """
  def build_image(layers) do
    layers
    |> Stream.zip()
    |> Stream.map(&Tuple.to_list/1)
    |> Stream.map(&Enum.zip/1)
    |> Stream.map(fn row -> row |> Enum.map(&Tuple.to_list/1) end)
    |> Stream.map(fn row ->
      row
      |> Enum.map(fn pixels ->
        pixels
        |> Enum.drop_while(&(&1 == 2))
        |> hd()
      end)
    end)
  end
end
