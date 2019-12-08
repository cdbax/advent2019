defmodule Advent2019.Five do
  def main(input_filename) do
    File.read!(input_filename)
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> run_program
  end

  @doc """
  Run Intcode programs

  ## Examples

    iex> Advent2019.Five.run_program([1,0,0,0,99])
    [2,0,0,0,99]

    iex> Advent2019.Five.run_program([2,3,0,3,99])
    [2,3,0,6,99]

    iex> Advent2019.Five.run_program([2,4,4,5,99,0])
    [2,4,4,5,99,9801]

    iex> Advent2019.Five.run_program([1,1,1,4,99,5,6,0,99])
    [30,1,1,4,2,5,6,0,99]

    iex> Advent2019.Five.run_program([1,9,10,3,2,3,11,0,99,30,40,50])
    [3500,9,10,70,2,3,11,0,99,30,40,50]
  """
  def run_program(program) do
    [op_code | _] = program

    parse_opcode(op_code)
    |> process(1, program)
  end

  def process({_, _, _, 99}, _offset, memory), do: memory

  def process({_, mode_2, mode_1, 1}, offset, memory) do
    [param_1, param_2, dest | _] = Enum.drop(memory, offset)

    value = read_mem(memory, mode_1, param_1) + read_mem(memory, mode_2, param_2)
    new_memory = write_mem(memory, dest, value)

    [next_op | _] = Enum.drop(new_memory, offset + 3)

    parse_opcode(next_op)
    |> process(offset + 4, new_memory)
  end

  def process({_, mode_2, mode_1, 2}, offset, memory) do
    [param_1, param_2, dest | _] = Enum.drop(memory, offset)

    value = read_mem(memory, mode_1, param_1) * read_mem(memory, mode_2, param_2)
    new_memory = write_mem(memory, dest, value)

    [next_op | _] = Enum.drop(new_memory, offset + 3)

    parse_opcode(next_op)
    |> process(offset + 4, new_memory)
  end

  def process({_, _, _, 3}, offset, memory) do
    [dest | _] = Enum.drop(memory, offset)

    input = IO.read(:line) |> String.trim() |> String.to_integer()
    new_memory = write_mem(memory, dest, input)

    [next_op | _] = Enum.drop(new_memory, offset + 1)

    parse_opcode(next_op)
    |> process(offset + 2, new_memory)
  end

  def process({_, _, mode, 4}, offset, memory) do
    [param | _] = Enum.drop(memory, offset)

    IO.puts(read_mem(memory, mode, param))

    [next_op | _] = Enum.drop(memory, offset + 1)

    parse_opcode(next_op)
    |> process(offset + 2, memory)
  end

  def process({_, mode_2, mode_1, 5}, offset, memory) do
    [param_1, param_2 | _] = Enum.drop(memory, offset)

    if read_mem(memory, mode_1, param_1) != 0 do
      jump = read_mem(memory, mode_2, param_2)
      [next_op | _] = Enum.drop(memory, jump)

      parse_opcode(next_op)
      |> process(jump + 1, memory)
    else
      [next_op | _] = Enum.drop(memory, offset + 2)

      parse_opcode(next_op)
      |> process(offset + 3, memory)
    end
  end

  def process({_, mode_2, mode_1, 6}, offset, memory) do
    [param_1, param_2 | _] = Enum.drop(memory, offset)

    if read_mem(memory, mode_1, param_1) == 0 do
      jump = read_mem(memory, mode_2, param_2)
      [next_op | _] = Enum.drop(memory, jump)

      parse_opcode(next_op)
      |> process(jump + 1, memory)
    else
      [next_op | _] = Enum.drop(memory, offset + 2)

      parse_opcode(next_op)
      |> process(offset + 3, memory)
    end
  end

  def process({_, mode_2, mode_1, 7}, offset, memory) do
    [param_1, param_2, param_3 | _] = Enum.drop(memory, offset)

    new_memory =
      if read_mem(memory, mode_1, param_1) < read_mem(memory, mode_2, param_2) do
        write_mem(memory, param_3, 1)
      else
        write_mem(memory, param_3, 0)
      end

    [next_op | _] = Enum.drop(new_memory, offset + 3)

    parse_opcode(next_op)
    |> process(offset + 4, new_memory)
  end

  def process({_, mode_2, mode_1, 8}, offset, memory) do
    [param_1, param_2, param_3 | _] = Enum.drop(memory, offset)

    new_memory =
      if read_mem(memory, mode_1, param_1) == read_mem(memory, mode_2, param_2) do
        write_mem(memory, param_3, 1)
      else
        write_mem(memory, param_3, 0)
      end

    [next_op | _] = Enum.drop(new_memory, offset + 3)

    parse_opcode(next_op)
    |> process(offset + 4, new_memory)
  end

  def process(_, _, _), do: raise("Unknown OpCode")

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
      
      iex> Advent2019.Five.parse_opcode(99)
      {0,0,0,99}

      iex> Advent2019.Five.parse_opcode(1002)
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
end
