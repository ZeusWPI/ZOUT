defmodule Zout.Checker.HttpOk do
  @moduledoc """
  Perform a HTTP GET request and expect a 200 response.

  This is a very simple health checker, which uses HTTP statuses. If the service
  is running, a 200 result is expected. The actual content of the page does not
  matter. To be as useful as possible, the following status codes are accepted
  as working: 200, 202, 203, 204 and 206.

  This is the easiest checker to use, as most sites have at least one normal
  endpoint which returns 200 (e.g. the start page). Because it is so simple, it
  does not support self-diagnosed error messages.

  All other responses (including 1XX, 2XX, 3XX, 4XX and 5XX) are considered
  "failing".

  If the server could not be reached, i.e. no status code could be obtained,
  the service is considered offline.

  This check requires one param: the `url` to which the request will be sent.
  """
  import Ecto.Changeset
  require Logger

  @behaviour Zout.Checker

  @impl true
  def identifier(), do: :http_ok

  @impl true
  def check(params) do
    url = params["url"]

    Logger.debug("Doing HTTP/200 check on #{url}")

    case Req.head(url, finch: ZoutFinch, max_retries: 2) do
      {:ok, %Req.Response{status: 200}} -> {:working, nil, nil}
      {:ok, %Req.Response{status: 202}} -> {:working, nil, nil}
      {:ok, %Req.Response{status: 203}} -> {:working, nil, nil}
      {:ok, %Req.Response{status: 204}} -> {:working, nil, nil}
      {:ok, %Req.Response{status: 206}} -> {:working, nil, nil}
      {:ok, _} -> {:failing, nil, nil}
      _ -> {:offline, nil, nil}
    end
  end

  @impl true
  def changeset(changeset, attrs) do
    # Migrate properties to a nested changeset
    data =
      case changeset.data.params do
        nil -> %{}
        p -> p
      end

    fields = %{url: EctoFields.URL}
    attrs = %{"url" => Map.get(attrs, "params_url")}

    # Put the changes in the big changeset now; it is validated later.
    changeset = put_change(changeset, :params, attrs)

    # Validate the nested changeset
    {data, fields}
    |> cast(attrs, Map.keys(fields))
    |> validate_required([:url])
    # Get the errors from it
    |> traverse_errors(&Function.identity/1)
    # Add field information in each error message.
    |> Enum.flat_map(fn
      {field, messages} ->
        Enum.map(messages, fn {message, other} -> {"#{field}: #{message}", other} end)
    end)
    # Add the error messages to the big changeset.
    |> Enum.reduce(
      changeset,
      fn error, chg ->
        validate_change(chg, :params, fn field, _ -> [{field, error}] end)
      end
    )
    # Delete form params.
    |> delete_change(:params_url)
  end
end
