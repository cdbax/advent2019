defmodule Advent2019.One do
  def main(input_filename) do
    File.stream!(input_filename)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&Advent2019.One.calculate_fuel/1)
    |> Enum.sum()
  end

  @doc """
  Calculate total fuel needed by a module

  ## Examples
    
    iex> Advent2019.One.calculate_fuel(14)
    2

    iex> Advent2019.One.calculate_fuel(1969)
    966
  """
  def calculate_fuel(mass) do
    fuel =
      mass
      |> div(3)
      |> Kernel.-(2)

    cond do
      fuel >= 0 ->
        fuel + calculate_fuel(fuel)

      true ->
        0
    end
  end
end
