defmodule GimlexTest do
  use ExUnit.Case, async: true

  @int_file """
  :num: my_int
  2
  """

  @float_file """
  :num: my_float
  2.4
  """

  @oneline_string_file """
  :text: my_string
  test
  """

  @multiline_string_file """
  :text: my_string
  one
  two
  """

  @list_file """
  :list: my_list
  a, b, c
  """

  @vlist_file """
  :vlist: my_vlist
  - a
  - b
  - c
  """

  test "gimlex can parse integer" do
    assert Gimlex.parse_content(@int_file) == [{"my_int", 2}]
  end

  test "gimlex can parse float" do
    assert Gimlex.parse_content(@float_file) == [{"my_float", 2.4}]
  end

  test "gimlex can parse oneline string" do
    assert Gimlex.parse_content(@oneline_string_file) == [{"my_string", "test"}]
  end

  test "gimlex can parse multiline string" do
    expected = [{"my_string", "one\ntwo"}]
    assert Gimlex.parse_content(@multiline_string_file) == expected
  end

  test "gimlex can parse list" do
    expected = [{"my_list", ~W[a b c]}]
    assert Gimlex.parse_content(@list_file) == expected
  end

  test "gimlex can parse vlist" do
    expected = [{"my_vlist", ~W[a b c]}]
    assert Gimlex.parse_content(@vlist_file) == expected
  end

  test "gimlex can parse multiple values" do
    expected = [{"str", "abc"}, {"num_var", 1}, {"list", ~W[a b c]}]
    data = """
    :list: list
    a, b, c
    :num: num_var
    1
    :text: str
    abc
    """
    assert Gimlex.parse_content(data) == expected
  end

  test "gimlex parse properly handle ending line" do
    data = ":list: list\na, b, c\n"
    expected = [{"list", ~W[a b c]}]

    assert Gimlex.parse_content(data) == expected
  end

  test "gimlex parse list properly handle beginning and ending line" do
    data = ":list: list\n\na, b, c\n\n"
    expected = [{"list", ~W[a b c]}]

    assert Gimlex.parse_content(data) == expected
  end

  test "gimlex parse list properly handle ending line comma" do
    data = ":list: list\na, b, c,\n"
    expected = [{"list", ~W[a b c]}]

    assert Gimlex.parse_content(data) == expected
  end

  test "gimlex parse list properly handle multiline defenition" do
    data = ":list: list\na, b, c,\nd, e, f,\n"
    expected = [{"list", ~W[a b c d e f]}]

    assert Gimlex.parse_content(data) == expected
  end

  test "gimlex parse text properly handle beginning and ending line" do
    data = ":list: list\na, b, c,\nd, e, f,\n"
    expected = [{"list", ~W[a b c d e f]}]

    assert Gimlex.parse_content(data) == expected
  end
end
