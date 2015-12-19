defmodule Erlsom.Mapper do
  def xml_name_to_action(name) do
    name
    |> Erlsom.Records.xml_remove_namespace
    |> Macro.underscore
    |> String.to_atom
  end

  def xml_name_to_module(name) do
    name
    |> Erlsom.Records.xml_remove_namespace
    |> String.replace("/", "_") # TODO: split, camel, and "."
    |> String.replace("-", "_") # TODO: split, camel, and "."
    |> Macro.camelize
  end

#  # map :undefined to nil
#  defp nillify(:undefined), do: nil
#  defp nillify([h | t]), do: [nillify(h) | nillify(t)]
#  defp nillify(tuple) when tuple |> is_tuple do
#    for n <- 0..tuple_size(tuple)-1, do: put_elem(tuple, n, nillify(elem(tuple, n)))
#  end
#  defp nillify(other), do: other
#
#  # map nil back to :undefined
#  defp undefine(nil), do: :undefined
#  defp undefine([h | t]), do: [undefine(h) | undefine(t)]
#  defp undefine(tuple) when tuple |> is_tuple do
#    for n <- 0..tuple_size(tuple)-1, do: put_elem(tuple, n, undefine(elem(tuple, n)))
#  end
#  defp undefine(other), do: other

  defmacro __using__(opts) do

    quote bind_quoted: [opts: opts] do

      require Record

      @namespace __MODULE__

      model = Erlsom.Records.get_model(opts)

      records = Erlsom.Model.extract_records(model)

      for {tag, record_def} <- records do
        module = tag |> Erlsom.Mapper.xml_name_to_module
        module = Module.concat([@namespace, module])

        record_def = record_def
          |> Erlsom.Records.record_def_underscore

        defmodule module do
          @fields record_def
          @tag tag
          def fields, do: @fields
          def tag, do: @tag
          defstruct @fields
        end

        fun_name = tag |> Erlsom.Records.xml_name_to_atom
        Record.defrecordp fun_name, tag, record_def
        defp to_kwlist(unquote(tag), record), do: unquote(fun_name)(record)
      end

      # https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/file/stat.ex
#      def to_record2(%{__struct__: module, unquote_splicing(pairs)}) do
#        {module.tag, unquote_splicing(vals)}
#      end

      def to_record(%{__struct__: module} = struct) do
        map = Map.from_struct(struct)
        for {key, default} <- module.fields, into: [module.tag] do
          case Map.get(map, key, default) do
            string when is_binary(string) -> to_char_list(string)
            map when is_map(map) -> to_record(map)
            other -> other
          end
        end |> List.to_tuple
      end

      def to_struct(record) when record |> is_tuple do
        tag = elem(record, 0)
        params = to_kwlist(tag, record)
          |> Enum.map(fn {key, value} -> {key, to_struct(value)} end)

        module = elem(record, 0)
          |> Erlsom.Mapper.xml_name_to_module
        module = Module.concat([@namespace, module])

        struct(module, params)
      end
      def to_struct([]), do: []
      def to_struct([c|_] = chardata) when c |> is_integer, do: IO.chardata_to_string(chardata) # this will fail badly if the schema has integers in lists
      def to_struct([h|t]), do: [to_struct(h) | to_struct(t)]
      def to_struct(:undefined), do: nil
      def to_struct(other), do: other
    end
  end
end
