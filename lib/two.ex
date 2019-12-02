defmodule Advent2019.Two do
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

    iex> Advent2019.Two.run_program([1,0,0,0,99])
    [2,0,0,0,99]

    iex> Advent2019.Two.run_program([2,3,0,3,99])
    [2,3,0,6,99]

    iex> Advent2019.Two.run_program([2,4,4,5,99,0])
    [2,4,4,5,99,9801]

    iex> Advent2019.Two.run_program([1,1,1,4,99,5,6,0,99])
    [30,1,1,4,2,5,6,0,99]

    iex> Advent2019.Two.run_program([1,9,10,3,2,3,11,0,99,30,40,50])
    [3500,9,10,70,2,3,11,0,99,30,40,50]
  """
  def run_program(program) do
    [op_code | _] = program
    process(op_code, 1, program)
  end

  def process(99, _offset, memory), do: memory

  def process(1, offset, memory) do
    [input_1, input_2, dest | _] = Enum.drop(memory, offset)

    new_memory =
      List.replace_at(memory, dest, Enum.at(memory, input_1) + Enum.at(memory, input_2))

    [next_op | _] = Enum.drop(new_memory, offset + 3)
    process(next_op, offset + 4, new_memory)
  end

  def process(2, offset, memory) do
    [input_1, input_2, dest | _] = Enum.drop(memory, offset)

    new_memory =
      List.replace_at(memory, dest, Enum.at(memory, input_1) * Enum.at(memory, input_2))

    [next_op | _] = Enum.drop(new_memory, offset + 3)
    process(next_op, offset + 4, new_memory)
  end

  def process(_, _, _), do: raise("Unknown OpCode")

  def reverse_search(search_value, input_filename) do
    initial_memory =
      File.read!(input_filename)
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    for noun <- 0..99,
        verb <- 0..99,
        test_mem =
          initial_memory
          |> List.replace_at(1, noun)
          |> List.replace_at(2, verb),
        hd(run_program(test_mem)) == search_value do
      noun * 100 + verb
    end
  end
end
