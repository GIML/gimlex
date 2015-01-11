defmodule GimlexTest do
  use ExUnit.Case

  @int_file """
  :num: my_int
  2
  """

  test "gimlex can parse integer" do
    assert Gimlex.parse_content(@int_file) == [{"my_int", 2}]
  end
end
