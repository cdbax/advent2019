defmodule Advent2019.Nine do
  alias Advent2019.Intcode

  def main(input_filename) do
    File.read!(input_filename)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> boost()
  end

  def boost(program) do
    me = self()
    cpu = spawn(fn -> Intcode.run(program, me) end)
    send(cpu, 2)
    check_output(nil)
  end

  def check_output(last) do
    receive do
      {:halt, _} ->
        last

      inp ->
        IO.puts(inp)
        check_output(inp)
    end
  end
end
