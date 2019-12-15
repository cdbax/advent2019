defmodule Advent2019.Intcode do
  @doc """
  Run Intcode programs

  ## Examples

    iex> Advent2019.Intcode.run([1,0,0,0,99], 0, self())
    {:halt, [2,0,0,0,99]}

    iex> Advent2019.Intcode.run([2,3,0,3,99], 0, self())
    {:halt, [2,3,0,6,99]}

    iex> Advent2019.Intcode.run([2,4,4,5,99,0], 0, self())
    {:halt, [2,4,4,5,99,9801]}

    iex> Advent2019.Intcode.run([1,1,1,4,99,5,6,0,99], 0, self())
    {:halt, [30,1,1,4,2,5,6,0,99]}

    iex> Advent2019.Intcode.run([1,9,10,3,2,3,11,0,99,30,40,50], 0, self())
    {:halt, [3500,9,10,70,2,3,11,0,99,30,40,50]}
  """
  def run(memory, address, receiver, rel_base \\ 0) do
    [opcode | _] = Enum.drop(memory, address)
    address = address + 1

    case process(parse_opcode(opcode), memory, address, rel_base) do
      {:halt, memory} ->
        send(receiver, {:halt, memory})

      {:input, memory, address, mode, rel_base} ->
        handle_input(memory, address, get_input(), receiver, mode, rel_base)

      {:output, memory, address, output} ->
        send(receiver, {:input, output})
        run(memory, address, receiver, rel_base)

      {:continue, memory, address, rel_base} ->
        run(memory, address, receiver, rel_base)
    end
  end

  def process({_, _, _, 99}, memory, _address, _rel_base), do: {:halt, memory}

  def process({mode_3, mode_2, mode_1, 1}, memory, address, rel_base) do
    [param_1, param_2, dest | _] = Enum.drop(memory, address)

    value =
      read_mem(memory, mode_1, param_1, rel_base) + read_mem(memory, mode_2, param_2, rel_base)

    new_memory = write_mem(memory, mode_3, dest, value, rel_base)

    {:continue, new_memory, address + 3, rel_base}
  end

  def process({mode_3, mode_2, mode_1, 2}, memory, address, rel_base) do
    [param_1, param_2, dest | _] = Enum.drop(memory, address)

    value =
      read_mem(memory, mode_1, param_1, rel_base) * read_mem(memory, mode_2, param_2, rel_base)

    new_memory = write_mem(memory, mode_3, dest, value, rel_base)

    {:continue, new_memory, address + 3, rel_base}
  end

  def process({_, _, mode, 3}, memory, address, rel_base) do
    {:input, memory, address, mode, rel_base}
  end

  def process({_, _, mode, 4}, memory, address, rel_base) do
    [param | _] = Enum.drop(memory, address)

    output = read_mem(memory, mode, param, rel_base)

    {:output, memory, address + 1, output}
  end

  def process({_, mode_2, mode_1, 5}, memory, address, rel_base) do
    [param_1, param_2 | _] = Enum.drop(memory, address)

    if read_mem(memory, mode_1, param_1, rel_base) != 0 do
      jump = read_mem(memory, mode_2, param_2, rel_base)
      {:continue, memory, jump, rel_base}
    else
      {:continue, memory, address + 2, rel_base}
    end
  end

  def process({_, mode_2, mode_1, 6}, memory, address, rel_base) do
    [param_1, param_2 | _] = Enum.drop(memory, address)

    if read_mem(memory, mode_1, param_1, rel_base) == 0 do
      jump = read_mem(memory, mode_2, param_2, rel_base)
      {:continue, memory, jump, rel_base}
    else
      {:continue, memory, address + 2, rel_base}
    end
  end

  def process({mode_3, mode_2, mode_1, 7}, memory, address, rel_base) do
    [param_1, param_2, param_3 | _] = Enum.drop(memory, address)

    new_memory =
      if read_mem(memory, mode_1, param_1, rel_base) < read_mem(memory, mode_2, param_2, rel_base) do
        write_mem(memory, mode_3, param_3, 1, rel_base)
      else
        write_mem(memory, mode_3, param_3, 0, rel_base)
      end

    {:continue, new_memory, address + 3, rel_base}
  end

  def process({mode_3, mode_2, mode_1, 8}, memory, address, rel_base) do
    [param_1, param_2, param_3 | _] = Enum.drop(memory, address)

    new_memory =
      if read_mem(memory, mode_1, param_1, rel_base) ==
           read_mem(memory, mode_2, param_2, rel_base) do
        write_mem(memory, mode_3, param_3, 1, rel_base)
      else
        write_mem(memory, mode_3, param_3, 0, rel_base)
      end

    {:continue, new_memory, address + 3, rel_base}
  end

  def process({_, _, mode, 9}, memory, address, rel_base) do
    [param | _] = Enum.drop(memory, address)
    change = read_mem(memory, mode, param, rel_base)
    {:continue, memory, address + 1, rel_base + change}
  end

  def process(wat, _, _, _), do: raise("Unknown OpCode #{Kernel.inspect(wat)}")

  def read_mem(memory, mode, param, rel_base) do
    case mode do
      2 ->
        read_at(memory, param + rel_base)

      1 ->
        param

      0 ->
        read_at(memory, param)

      m ->
        raise("Unknown parameter mode #{Kernel.inspect(m)}")
    end
  end

  def read_at(memory, position) when position >= 0 do
    case Enum.at(memory, position) do
      nil ->
        0

      val ->
        val
    end
  end

  @doc """
  ## Examples
    iex> Advent2019.Intcode.write_mem([0,0,0,0], 0, 1, 5, 0)
    [0, 5, 0, 0]

    iex> Advent2019.Intcode.write_mem([0,0,0,0], 2, 0, 5, 0)
    [5, 0, 0, 0]

    iex> Advent2019.Intcode.write_mem([0,0,0], 2, 0, 5, 5)
    [0, 0, 0, 0, 0, 5]
  """
  def write_mem(memory, mode, param, value, rel_base) do
    case mode do
      0 ->
        write_at(memory, param, value)

      2 ->
        write_at(memory, param + rel_base, value)

      1 ->
        raise("Attempted to write using immediate mode")
    end
  end

  @doc """
  ## Examples
    iex> Advent2019.Intcode.write_at([0,0,0,0], 2, 1)
    [0,0,1,0]

    iex> Advent2019.Intcode.write_at([1,1,1], 5, 1)
    [1,1,1,0,0,1]
  """
  def write_at(memory, dest, value) when dest >= 0 do
    case Enum.count(memory) < dest do
      false ->
        List.replace_at(memory, dest, value)

      true ->
        (memory ++ List.duplicate(0, dest - Enum.count(memory) + 1))
        |> List.replace_at(dest, value)
    end
  end

  def expand_mem(memory, target) do
    memory ++ List.duplicate(0, target - Enum.count(memory) + 1)
  end

  @doc """
    ## Examples
      
      iex> Advent2019.Intcode.parse_opcode(99)
      {0,0,0,99}

      iex> Advent2019.Intcode.parse_opcode(1002)
      {0,1,0,2}
  """
  def parse_opcode(opcode) do
    [a, b, c | op] =
      opcode
      |> Integer.to_string()
      |> String.pad_leading(5, "0")
      |> String.graphemes()

    {String.to_integer(a), String.to_integer(b), String.to_integer(c),
     op |> Enum.join() |> String.to_integer()}
  end

  def get_input() do
    receive do
      {:input, input} ->
        input
    end
  end

  def handle_input(memory, address, input, receiver, mode, rel_base) do
    [param | _] = Enum.drop(memory, address)

    new_memory = write_mem(memory, mode, param, input, rel_base)

    run(new_memory, address + 1, receiver, rel_base)
  end
end
