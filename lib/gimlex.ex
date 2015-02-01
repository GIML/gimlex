defmodule Gimlex do
  def parse_content(data) do
    data
    |> String.split("\n", trim: true)
    |> parse_content([])
  end

  defp parse_content([head|tail], acc) do
    [parse_value(parse_type(head), tail) | acc]
  end

  defp parse_type(<<":num:", rest::binary>>) do
    {:num, parse_name(rest)}
  end

  defp parse_type(<<":text:", rest::binary>>) do
    {:text, parse_name(rest)}
  end

  defp parse_type(<<":list:", rest::binary>>) do
    {:list, parse_name(rest)}
  end

  defp parse_type(<<":vlist:", rest::binary>>) do
    {:vlist, parse_name(rest)}
  end

  defp parse_value({:num, name}, [head|tail]) do
    {name, parse_num(head)}
  end

  defp parse_value({:text, name}, rest) do
    {name, parse_text(rest)}
  end

  defp parse_value({:list, name}, rest) do
    {name, parse_list(rest)}
  end

  defp parse_value({:vlist, name}, rest) do
    {name, parse_vlist(rest)}
  end

  defp parse_num(num) do
    case String.contains?(num, ".") do
      false -> String.to_integer(num)
      true -> String.to_float(num)
    end
  end

  defp parse_text(str) do
    parse_text(str, [])
  end

  defp parse_list([str]) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&String.strip/1)
  end

  defp parse_vlist(rest) do
    parse_vlist(rest, [])
  end

  defp parse_vlist([], acc) do
    Enum.reverse(acc)
  end

  defp parse_vlist([<<"-", line::binary>>|tail], acc) do
    parse_vlist(tail, [String.strip(line)|acc])
  end

  defp parse_text([], acc) do
    acc |> Enum.reverse |> Enum.join("\n")
  end

  defp parse_text([head|tail], acc) do
    parse_text(tail, [head|acc])
  end

  defp parse_name(binary) do
    binary
    |> String.split
    |> List.first
  end
end
