defmodule Advent2019.Intcode do
  @doc """
  Run Intcode programs

  ## Examples

    iex> Advent2019.Intcode.run([1,0,0,0,99])
    {:halt, [2,0,0,0,99]}

    iex> Advent2019.Intcode.run([2,3,0,3,99])
    {:halt, [2,3,0,6,99]}

    iex> Advent2019.Intcode.run([2,4,4,5,99,0])
    {:halt, [2,4,4,5,99,9801]}

    iex> Advent2019.Intcode.run([1,1,1,4,99,5,6,0,99])
    {:halt, [30,1,1,4,2,5,6,0,99]}

    iex> Advent2019.Intcode.run([1,9,10,3,2,3,11,0,99,30,40,50])
    {:halt, [3500,9,10,70,2,3,11,0,99,30,40,50]}
  """
  def run(memory, address \\ 0, receiver) do
    [opcode | _] = Enum.drop(memory, address)
    address = address + 1

    case process(parse_opcode(opcode), memory, address) do
      {:halt, memory} ->
        send(receiver, {:halt, memory})

      {:input, memory, address} ->
        handle_input(memory, address, get_input(), receiver)

      {:output, memory, address, output} ->
        # IO.puts(output)
        send(receiver, {:input, output})
        run(memory, address, receiver)

      {:continue, memory, address} ->
        run(memory, address, receiver)
    end
  end

  def process({_, _, _, 99}, memory, _address), do: {:halt, memory}

  def process({_, mode_2, mode_1, 1}, memory, address) do
    [param_1, param_2, dest | _] = Enum.drop(memory, address)

    value = read_mem(memory, mode_1, param_1) + read_mem(memory, mode_2, param_2)
    new_memory = write_mem(memory, dest, value)

    {:continue, new_memory, address + 3}
  end

  def process({_, mode_2, mode_1, 2}, memory, address) do
    [param_1, param_2, dest | _] = Enum.drop(memory, address)

    value = read_mem(memory, mode_1, param_1) * read_mem(memory, mode_2, param_2)
    new_memory = write_mem(memory, dest, value)

    {:continue, new_memory, address + 3}
  end

  def process({_, _, _, 3}, memory, address) do
    {:input, memory, address}
  end

  def process({_, _, mode, 4}, memory, address) do
    [param | _] = Enum.drop(memory, address)

    output = read_mem(memory, mode, param)

    {:output, memory, address + 1, output}
  end

  def process({_, mode_2, mode_1, 5}, memory, address) do
    [param_1, param_2 | _] = Enum.drop(memory, address)

    if read_mem(memory, mode_1, param_1) != 0 do
      jump = read_mem(memory, mode_2, param_2)
      {:continue, memory, jump}
    else
      {:continue, memory, address + 2}
    end
  end

  def process({_, mode_2, mode_1, 6}, memory, address) do
    [param_1, param_2 | _] = Enum.drop(memory, address)

    if read_mem(memory, mode_1, param_1) == 0 do
      jump = read_mem(memory, mode_2, param_2)
      {:continue, memory, jump}
    else
      {:continue, memory, address + 2}
    end
  end

  def process({_, mode_2, mode_1, 7}, memory, address) do
    [param_1, param_2, param_3 | _] = Enum.drop(memory, address)

    new_memory =
      if read_mem(memory, mode_1, param_1) < read_mem(memory, mode_2, param_2) do
        write_mem(memory, param_3, 1)
      else
        write_mem(memory, param_3, 0)
      end

    {:continue, new_memory, address + 3}
  end

  def process({_, mode_2, mode_1, 8}, memory, address) do
    [param_1, param_2, param_3 | _] = Enum.drop(memory, address)

    new_memory =
      if read_mem(memory, mode_1, param_1) == read_mem(memory, mode_2, param_2) do
        write_mem(memory, param_3, 1)
      else
        write_mem(memory, param_3, 0)
      end

    {:continue, new_memory, address + 3}
  end

  def process(wat, _, _), do: raise("Unknown OpCode #{wat}")

  def read_mem(memory, mode, param) do
    case mode do
      1 ->
        param

      _ ->
        Enum.at(memory, param)
    end
  end

  def write_mem(memory, dest, value) do
    List.replace_at(memory, dest, value)
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
    # IO.read(:line) |> String.trim() |> String.to_integer
    # require IEx; IEx.pry;
    receive do
      {:input, input} ->
        input
    end
  end

  def handle_input(memory, address, input, receiver) do
    [dest | _] = Enum.drop(memory, address)

    new_memory = write_mem(memory, dest, input)

    run(new_memory, address + 1, receiver)
  end
end
