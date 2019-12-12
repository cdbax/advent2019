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
    amp_e = spawn(fn -> Intcode.run(program, 0, me) end)
    amp_d = spawn(fn -> Intcode.run(program, 0, amp_e) end)
    amp_c = spawn(fn -> Intcode.run(program, 0, amp_d) end)
    amp_b = spawn(fn -> Intcode.run(program, 0, amp_c) end)
    amp_a = spawn(fn -> Intcode.run(program, 0, amp_b) end)
    send(amp_e, {:input, e})
    send(amp_d, {:input, d})
    send(amp_c, {:input, c})
    send(amp_b, {:input, b})
    send(amp_a, {:input, a})
    send(amp_a, {:input, init_value})

    receive do
      x -> x
    end
  end

  def amplifier_loop({a, b, c, d, e}, program, init_value) do
    me = self()
    amp_e = spawn(fn -> Intcode.run(program, 0, me) end)
    amp_d = spawn(fn -> Intcode.run(program, 0, amp_e) end)
    amp_c = spawn(fn -> Intcode.run(program, 0, amp_d) end)
    amp_b = spawn(fn -> Intcode.run(program, 0, amp_c) end)
    amp_a = spawn(fn -> Intcode.run(program, 0, amp_b) end)
    send(amp_e, {:input, e})
    send(amp_d, {:input, d})
    send(amp_c, {:input, c})
    send(amp_b, {:input, b})
    send(amp_a, {:input, a})
    send(amp_a, {:input, init_value})
    check(nil, amp_a)
  end

  def check(last, forward_to) do
    receive do
      {:input, inp} ->
        send(forward_to, {:input, inp})
        check(inp, forward_to)

      {:halt, _} ->
        last
    end
  end
end
