defmodule Zout.Checker.HydraApi do
  @moduledoc """
  Checks the Hydra (resto) API. Nobody else should use it.
  """
  import Ecto.Changeset
  require Logger

  @behaviour Zout.Checker

  @impl true
  def identifier(), do: :hydra_api

  # This is ugly
  defp parse_directory_listing(body) do
    regex = ~r/<a.*<\/a> +(\d.* \d\d:\d\d)/iu
    Regex.scan(regex, body)
  end

  defp check_recentness(last_run) do
    oldest_allowed = Timex.subtract(Timex.now(), Timex.Duration.from_hours(24))

    if Timex.compare(last_run, oldest_allowed) == -1 do
      {:failing, "Scraper has not run in the last 24 hours", nil}
    else
      {:working, nil, nil}
    end
  end

  defp check_api_date(body) do
    dir_listing = parse_directory_listing(body)

    if length(dir_listing) != 5 do
      {:failing, "API format changed, adjust checker", nil}
    else
      date = Enum.at(dir_listing, 3) |> Enum.at(1)

      case Timex.parse(date, "{0D}-{Mshort}-{YYYY} {h24}:{m}") do
        {:ok, datetime} -> check_recentness(datetime)
        _ -> {:failing, "Could not parse date", nil}
      end
    end
  end

  @impl true
  def check(params \\ %{}) do
    url = Map.get(params, "url", "https://hydra.ugent.be/api/2.0/")

    Logger.debug("Doing Hydra check on #{url}")

    case Req.get(url, finch: ZoutFinch, max_retries: 2) do
      {:ok, %Req.Response{status: 200, body: body}} -> check_api_date(body)
      {:ok, _} -> {:failing, nil, nil}
      _ -> {:offline, nil, nil}
    end
  end

  @impl true
  def changeset(changeset, _attrs) do
    put_change(changeset, :params, %{})
  end
end
