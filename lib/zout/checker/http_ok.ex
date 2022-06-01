defmodule Zout.Checker.HttpOk do
  @moduledoc """
  Health check where the health is checked by sending an HTTP GET request,
  for which the check expects an 200 OK result.

  This check does not support the "failing" status.

  The check expects an URL as param, which will be queried.
  """
  @behaviour Zout.Checker

  @impl true
  def identifier(), do: :http_ok

  @impl true
  def check(params) do
    url = params["url"]
    IO.inspect(params)

    request = Finch.build(:get, url)

    case Finch.request(request, ZoutFinch) do
      {:ok, %Finch.Response{status: 200}} -> :working
      {:ok, %Finch.Response{status: 500}} -> {:failing, nil}
      _ -> {:offline, nil}
    end
  end
end
