defmodule Advent2019.Seven do
  alias Advent2019.Intcode

  def main(input_filename) do
    File.read!(input_filename)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> find_max_output()
  end

  def find_max_output(program) do
    get_permutations(0..4)
    |> Enum.map(&amplifier(&1, program, 0))
    |> Enum.max()
  end

  def main2(input_filename) do
    File.read!(input_filename)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> find_max_feedback()
  end

  def find_max_feedback(program) do
    get_permutations(5..9)
    |> Enum.map(&amplifier_loop(&1, program, 0))
    |> Enum.max()
  end

  @doc """
    Just brute force it to get the permutations for phase inputs
  """
  def get_permutations(range) do
    all =
      for a <- range do
        for b <- range do
          for c <- range do
            for d <- range do
              for e <- range do
                {a, b, c, d, e}
              end
            end
          end
        end
      end

    all
    |> List.flatten()
    |> Enum.filter(fn el ->
      el |> Tuple.to_list() |> Enum.uniq() |> Enum.count() == 5
    end)
    |> Enum.uniq()
  end

  def amplifier({a, b, c, d, e}, program, init_value) do
    me = self()
    amp_e = spawn(fn -> Intcode.run(program, me) end)
    amp_d = spawn(fn -> Intcode.run(program, amp_e) end)
    amp_c = spawn(fn -> Intcode.run(program, amp_d) end)
    amp_b = spawn(fn -> Intcode.run(program, amp_c) end)
    amp_a = spawn(fn -> Intcode.run(program, amp_b) end)
    send(amp_e, e)
    send(amp_d, d)
    send(amp_c, c)
    send(amp_b, b)
    send(amp_a, a)
    send(amp_a, init_value)

    check(nil)
  end

  def check(last) do
    receive do
      {:halt, _} ->
        last

      inp ->
        IO.puts(inp)
        check(inp)
    end
  end

  def amplifier_loop({a, b, c, d, e}, program, init_value) do
    me = self()
    amp_e = spawn(fn -> Intcode.run(program, me) end)
    amp_d = spawn(fn -> Intcode.run(program, amp_e) end)
    amp_c = spawn(fn -> Intcode.run(program, amp_d) end)
    amp_b = spawn(fn -> Intcode.run(program, amp_c) end)
    amp_a = spawn(fn -> Intcode.run(program, amp_b) end)
    send(amp_e, e)
    send(amp_d, d)
    send(amp_c, c)
    send(amp_b, b)
    send(amp_a, a)
    send(amp_a, init_value)
    check_forward(nil, amp_a)
  end

  def check_forward(last, forward_to) do
    receive do
      {:halt, _} ->
        last

      inp ->
        send(forward_to, inp)
        check_forward(inp, forward_to)
    end
  end
end
