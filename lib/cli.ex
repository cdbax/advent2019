defmodule Advent2019.CLI do

  def main(argv) do
    {[day: day], _, _} = OptionParser.parse(argv, strict: [day: :integer])
    case day do
      1 ->
        IO.puts(Advent2019.One.main("input_one.txt"))
      _ ->
        IO.puts("Day not implemented")
    end
  end
end
