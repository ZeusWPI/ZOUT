defmodule ZoutWeb.FormatHelpers do
  def human_datetime(nil), do: "-"

  def human_datetime(datetime) do
    case ZoutWeb.Cldr.DateTime.to_string(datetime) do
      {:ok, format} ->
        format

      {:error, error} ->
        IO.inspect(error)
        DateTime.to_iso8601(datetime)
    end
  end
end
