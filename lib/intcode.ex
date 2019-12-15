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
  def run(memory, receiver) do
    memory
    |> Enum.with_index()
    |> Enum.map(fn {value, index} -> {index, value} end)
    |> Map.new()
    |> (&Map.put(%{}, :memory, &1)).()
    |> Map.put(:address, 0)
    |> Map.put(:receiver, receiver)
    |> Map.put(:rel_base, 0)
    |> execute()

    # [opcode | _] = Enum.drop(memory, address)
    # address = address + 1

    # case process(parse_opcode(opcode), memory, address, rel_base) do
    #   {:halt, memory} ->
    #     send(receiver, {:halt, memory})

    #   {:input, memory, address, mode, rel_base} ->
    #     handle_input(memory, address, get_input(), receiver, mode, rel_base)

    #   {:output, memory, address, output} ->
    #     send(receiver, {:input, output})
    #     run(memory, address, receiver, rel_base)

    #   {:continue, memory, address, rel_base} ->
    #     run(memory, address, receiver, rel_base)
    # end
  end

  def execute(state) do
    opcode = Map.get(state.memory, state.address)
    state = put_in(state.address, state.address + 1)

    case process(parse_opcode(opcode), state) do
      {:halt, state} ->
        send(state.receiver, {:halt, state})

      {:input, state, mode} ->
        handle_input(state, mode, get_input())

      {:output, state, output} ->
        send(state.receiver, output)
        execute(state)

      {:continue, state} ->
        execute(state)
    end
  end

  def process({_, _, _, 99}, state), do: {:halt, state}

  def process({mode_3, mode_2, mode_1, 1}, state) do
    param_1 = Map.fetch!(state.memory, state.address)
    param_2 = Map.fetch!(state.memory, state.address + 1)
    dest = Map.fetch!(state.memory, state.address + 2)

    value =
      read_mem(state.memory, mode_1, param_1, state.rel_base) +
        read_mem(state.memory, mode_2, param_2, state.rel_base)

    new_memory = write_mem(state.memory, mode_3, dest, value, state.rel_base)

    new_state =
      state
      |> Map.put(:memory, new_memory)
      |> Map.put(:address, state.address + 3)

    {:continue, new_state}
  end

  def process({mode_3, mode_2, mode_1, 2}, state) do
    param_1 = Map.fetch!(state.memory, state.address)
    param_2 = Map.fetch!(state.memory, state.address + 1)
    dest = Map.fetch!(state.memory, state.address + 2)

    value =
      read_mem(state.memory, mode_1, param_1, state.rel_base) *
        read_mem(state.memory, mode_2, param_2, state.rel_base)

    new_memory = write_mem(state.memory, mode_3, dest, value, state.rel_base)

    new_state =
      state
      |> Map.put(:memory, new_memory)
      |> Map.put(:address, state.address + 3)

    {:continue, new_state}
  end

  def process({_, _, mode, 3}, state) do
    {:input, state, mode}
  end

  def process({_, _, mode, 4}, state) do
    param = Map.fetch!(state.memory, state.address)

    output = read_mem(state.memory, mode, param, state.rel_base)

    new_state =
      state
      |> Map.put(:address, state.address + 1)

    {:output, new_state, output}
  end

  def process({_, mode_2, mode_1, 5}, state) do
    param_1 = Map.fetch!(state.memory, state.address)
    param_2 = Map.fetch!(state.memory, state.address + 1)

    if read_mem(state.memory, mode_1, param_1, state.rel_base) != 0 do
      jump = read_mem(state.memory, mode_2, param_2, state.rel_base)
      new_state = Map.put(state, :address, jump)
      {:continue, new_state}
    else
      new_state = Map.put(state, :address, state.address + 2)
      {:continue, new_state}
    end
  end

  def process({_, mode_2, mode_1, 6}, state) do
    param_1 = Map.fetch!(state.memory, state.address)
    param_2 = Map.fetch!(state.memory, state.address + 1)

    if read_mem(state.memory, mode_1, param_1, state.rel_base) == 0 do
      jump = read_mem(state.memory, mode_2, param_2, state.rel_base)
      new_state = Map.put(state, :address, jump)
      {:continue, new_state}
    else
      new_state = Map.put(state, :address, state.address + 2)
      {:continue, new_state}
    end
  end

  def process({mode_3, mode_2, mode_1, 7}, state) do
    param_1 = Map.fetch!(state.memory, state.address)
    param_2 = Map.fetch!(state.memory, state.address + 1)
    param_3 = Map.fetch!(state.memory, state.address + 2)

    new_memory =
      if read_mem(state.memory, mode_1, param_1, state.rel_base) <
           read_mem(state.memory, mode_2, param_2, state.rel_base) do
        write_mem(state.memory, mode_3, param_3, 1, state.rel_base)
      else
        write_mem(state.memory, mode_3, param_3, 0, state.rel_base)
      end

    new_state =
      state
      |> Map.put(:memory, new_memory)
      |> Map.put(:address, state.address + 3)

    {:continue, new_state}
  end

  def process({mode_3, mode_2, mode_1, 8}, state) do
    param_1 = Map.fetch!(state.memory, state.address)
    param_2 = Map.fetch!(state.memory, state.address + 1)
    param_3 = Map.fetch!(state.memory, state.address + 2)

    new_memory =
      if read_mem(state.memory, mode_1, param_1, state.rel_base) ==
           read_mem(state.memory, mode_2, param_2, state.rel_base) do
        write_mem(state.memory, mode_3, param_3, 1, state.rel_base)
      else
        write_mem(state.memory, mode_3, param_3, 0, state.rel_base)
      end

    new_state =
      state
      |> Map.put(:memory, new_memory)
      |> Map.put(:address, state.address + 3)

    {:continue, new_state}
  end

  def process({_, _, mode, 9}, state) do
    param = Map.fetch!(state.memory, state.address)
    change = read_mem(state.memory, mode, param, state.rel_base)

    new_state =
      state
      |> Map.put(:address, state.address + 1)
      |> Map.put(:rel_base, state.rel_base + change)

    {:continue, new_state}
  end

  def process(wat, _), do: raise("Unknown OpCode #{Kernel.inspect(wat)}")

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
    Map.get(memory, position, 0)
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
    Map.put(memory, dest, value)
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
      input ->
        input
    end
  end

  def handle_input(state, mode, input) do
    param = Map.fetch!(state.memory, state.address)

    new_memory = write_mem(state.memory, mode, param, input, state.rel_base)

    new_state =
      state
      |> Map.put(:memory, new_memory)
      |> Map.put(:address, state.address + 1)

    execute(new_state)
  end
end
