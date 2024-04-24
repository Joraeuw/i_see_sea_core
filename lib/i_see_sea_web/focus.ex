defprotocol ISeeSeaWeb.Focus do
  @fallback_to_any true
  def view(entity, lens)
end

defimpl ISeeSeaWeb.Focus,
  for: [Atom, String, BitString, Integer, Float, Decimal, DateTime, NaiveDateTime] do
  def view(value, _), do: value
end

defimpl ISeeSeaWeb.Focus, for: Map do
  def view(entity, lens) do
    entity
    |> Enum.map(fn {k, v} -> {k, ISeeSeaWeb.Focus.view(v, lens)} end)
    |> Enum.into(%{})
  end
end

defimpl ISeeSeaWeb.Focus, for: List do
  def view(entity, lens) do
    Enum.map(entity, &ISeeSeaWeb.Focus.view(&1, lens))
  end
end

defimpl ISeeSeaWeb.Focus, for: Keyword do
  def view(entity, lens) do
    Enum.map(entity, fn {k, v} -> {k, ISeeSeaWeb.Focus.view(v, lens)} end)
  end
end

defimpl ISeeSeaWeb.Focus, for: Any do
  defmacro __deriving__(module, struct, opts) do
    fields = fields_to_encode(struct, opts)
    kv = Enum.map(fields, &{&1, Macro.var(&1, __MODULE__)})

    quote do
      defimpl ISeeSeaWeb.Focus, for: unquote(module) do
        def view(%{unquote_splicing(kv)} = object, lens) do
          ISeeSeaWeb.Focus.view(%{unquote_splicing(kv)}, lens)
        end
      end
    end
  end

  def view(%_{} = struct, _lens) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: struct,
      description: """
      Protocol Focus not implemented for struct #{struct.__struct__}!
      """
  end

  def view(value, _opts) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: value,
      description: "Protocol not implemented for #{value}"
  end

  defp fields_to_encode(struct, opts) do
    fields = Map.keys(struct)
    attrs = Keyword.get(opts, :attrs)

    if is_nil(attrs) do
      raise ArgumentError, "All modules MUST implement the ISeeSeaWeb.Focus Protocol"
      fields -- [:__struct__]
    else
      case attrs -- fields do
        [] ->
          attrs

        error_keys ->
          raise ArgumentError,
                "`:attrs` specified keys (#{inspect(error_keys)}) that are not defined in defstruct: " <>
                  "#{inspect(fields -- [:__struct__])}"
      end
    end
  end
end
