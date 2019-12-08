defmodule Advent2019.Four do
  def main(lower, upper) do
    list_potentials(lower, upper)
    |> Enum.count()
  end

  def list_potentials(lower, upper) do
    for v <- lower..upper, is_valid?(v) == true, do: v
  end

  def is_valid?(num) do
    digits = Integer.digits(num)

    digits == Enum.sort(digits) &&
      Enum.count(Enum.dedup(digits)) <= 5 &&
      Enum.chunk_by(digits, & &1) |> Enum.map(&Enum.count/1) |> Enum.member?(2)
  end
end
