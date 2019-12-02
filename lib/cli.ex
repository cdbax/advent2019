defmodule Advent2019.CLI do
  def main(argv) do
    {[day: day], _, _} = OptionParser.parse(argv, strict: [day: :string])

    case day do
      "1" ->
        IO.puts(Advent2019.One.main("input_one.txt"))

      "2" ->
        IO.inspect(Advent2019.Two.main("input_two.txt"))

      "2.1" ->
        IO.inspect(Advent2019.Two.reverse_search(19_690_720, "input_two.txt"))

      _ ->
        IO.puts("Day not implemented")
    end
  end
end
