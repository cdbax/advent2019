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

      "3" ->
        IO.inspect(Advent2019.Three.main("input_three.txt"))

      "4" ->
        IO.inspect(Advent2019.Four.main(109_165, 576_723))

      "5" ->
        IO.inspect(Advent2019.Five.main("input_five.txt"))

      "6" ->
        IO.inspect(Advent2019.Six.main("input_six.txt"))

      _ ->
        IO.puts("Day not implemented")
    end
  end
end
