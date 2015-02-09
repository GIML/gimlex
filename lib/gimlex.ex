defmodule Gimlex do
  def parse_content(data) do
    data
    |> String.split("\n", trim: true)
    |> parse_content([])
  end

  defp parse_content([], acc), do: acc

  defp parse_content([head|tail], acc) do
    parse_value(parse_type(head), tail, acc)
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

  defp parse_value({:num, name}, [head|tail], acc) do
    parse_content(tail, [{name, parse_num(head)} | acc])
  end

  defp parse_value({:text, name}, rest, acc) do
    {text, tail} = parse_text(rest)
    parse_content(tail, [{name, text} | acc])
  end

  defp parse_value({:list, name}, rest, acc) do
    {list, tail} = parse_list(rest)
    parse_content(tail, [{name, list} | acc])
  end

  defp parse_value({:vlist, name}, rest, acc) do
    {vlist, tail} = parse_vlist(rest)
    parse_content(tail, [{name, vlist} | acc])
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

  defp parse_list(rest) do
    parse_list(rest, "")
  end

  defp parse_list([], acc) do
    {str_to_list(acc), []}
  end

  defp parse_list(rest = [<<":", _::binary>>|_], acc) do
    {str_to_list(acc), rest}
  end

  defp parse_list([str|tail], acc) do
    parse_list(tail, acc <> str)
  end

  defp parse_vlist(rest) do
    parse_vlist(rest, [])
  end

  defp parse_vlist([], acc) do
    {Enum.reverse(acc), []}
  end

  defp parse_vlist(rest = [<<":", _::binary>>|_], acc) do
    {Enum.reverse(acc), rest}
  end

  defp parse_vlist([<<"-", line::binary>>|tail], acc) do
    parse_vlist(tail, [String.strip(line)|acc])
  end

  defp parse_text([], acc) do
    {acc |> Enum.reverse |> Enum.join("\n"), []}
  end

  defp parse_text(rest = [<<":", _::binary>>|_], acc) do
    {acc |> Enum.reverse |> Enum.join("\n"), rest}
  end

  defp parse_text([head|tail], acc) do
    parse_text(tail, [head|acc])
  end

  defp parse_name(binary) do
    binary
    |> String.split
    |> List.first
  end

  defp str_to_list(str) do
    str
    |> String.split(",", trim: true)
    |> Enum.map(&String.strip/1)
  end
end
