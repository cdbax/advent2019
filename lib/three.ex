defmodule Advent2019.Three do
  def main(input_filename) do
    File.stream!(input_filename)
    #|> calc_closest()
    |> calc_shortest()
  end

  @doc """
    Do the thing

    ## Examples

      iex> Advent2019.Three.calc_closest(["R8,U5,L5,D3","U7,R6,D4,L4"])
      6
      
      iex> Advent2019.Three.calc_closest(["R75,D30,R83,U83,L12,D49,R71,U7,L72\\n","U62,R66,U55,R34,D71,R55,D58,R83"])
      159
      
      iex> Advent2019.Three.calc_closest(["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51","U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"])
      135
  """
  def calc_closest(input) do
    paths = 
      input
      |> Enum.map(&build_instructions/1)
      |> Enum.map(&calculate_path/1)

    [path_a | [path_b | []]] = paths
    intersections = find_intersections(path_a, path_b)
    closest_intersection(intersections)
  end

  @doc """
    ## Examples
      
      iex> Advent2019.Three.calc_shortest(["R8,U5,L5,D3","U7,R6,D4,L4"])
      30

      iex> Advent2019.Three.calc_shortest(["R75,D30,R83,U83,L12,D49,R71,U7,L72\\n","U62,R66,U55,R34,D71,R55,D58,R83"])
      610

      iex> Advent2019.Three.calc_shortest(["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51","U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"])
      410
  """
  def calc_shortest(input) do
    paths =
      input
      |> Enum.map(&build_instructions/1)
      |> Enum.map(&calculate_path/1)
      |> Enum.map(&Enum.reverse/1)
    [path_a | [path_b | []]] = paths
    intersections = find_intersections(path_a, path_b) 
    shortest_path(path_a, path_b, intersections)
  end

  @doc """
    Take a string representation of instructions, and turn it into a list of
    tuples in the format {direction, distance}

    ## Examples

      iex> Advent2019.Three.build_instructions("R10,L20,U30,D40\\n")
      [{"R",10},{"L",20},{"U",30},{"D",40}]
  """
  def build_instructions(string) do
    string
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn <<direction::utf8, distance::binary>> ->
      {<<direction::utf8>>, String.to_integer(distance)}
    end)
  end

  @doc """
    Take a list of route instructions, and build a matrix of points that define that path.

    ## Examples

      iex> Advent2019.Three.calculate_path([{"R",3}, {"U",2}])
      [{3,2},{3,1},{3,0},{2,0},{1,0}]
  """
  def calculate_path(instructions) do
    instructions
    |> Enum.reduce([{0,0}], fn {dir,dist}, [start|_]= acc -> route(start, dir, dist) ++ acc end)
    |> List.delete({0,0})  
  end

  def route(start, "R", dist), do: for(x <- dist..1, do: {elem(start, 0) + x, elem(start, 1)})
  def route(start, "L", dist), do: for(x <- dist..1, do: {elem(start, 0) - x, elem(start, 1)})
  def route(start, "U", dist), do: for(y <- dist..1, do: {elem(start, 0), elem(start, 1) + y})
  def route(start, "D", dist), do: for(y <- dist..1, do: {elem(start, 0), elem(start, 1) - y})

  @doc """
    Take 2 paths and find the points at which they intersect each other, ignoring self-intersections
  """
  def find_intersections(path_a, path_b) do
    ms_path_a = MapSet.new(path_a)
    ms_path_b = MapSet.new(path_b)

    MapSet.intersection(ms_path_a, ms_path_b)
    |> MapSet.to_list()
  end

  def closest_intersection(intersections),
    do: intersections |> Enum.map(&manhattan_dist/1) |> Enum.min()

  def manhattan_dist({x,y}), do: abs(x) + abs(y)

  def shortest_path(path_a, path_b, intersections) do
    Enum.map(intersections, fn target ->
      dist_a = distance_to_point(path_a, target)
      dist_b = distance_to_point(path_b, target)
      dist_a + dist_b
    end) |> Enum.min()
  end

  def distance_to_point(path, target) do
    Enum.reduce_while(path, 0, fn pt, acc ->
      if pt == target do
        {:halt, acc + 1}
      else
        {:cont, acc + 1}
      end
    end)
    #    Enum.reduce_while(path, %{steps: 0, prev: {0,0}}, fn {x,y} = pt, %{steps: count, prev: {prev_x,prev_y}} = acc ->
    #  steps = count + (abs(x - prev_x) + abs(y - prev_y))  
    #  if pt == target do
    #    {:halt, Map.put(acc, :steps, steps)}
    #  else
    #    {:cont, acc |> Map.put(:steps, steps) |> Map.put(:prev, pt)}
    #  end
    #end) |> IO.inspect |> Map.pop(:steps)
  end
end
