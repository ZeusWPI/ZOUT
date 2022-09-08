defmodule Zout.Data.Ping do
  @moduledoc """
  Saves the result of a check.

  A ping is an interval in time, denoting a period where the status of the checks
  stayed the same.
  """
  use Ecto.Schema

  @primary_key false
  schema "pings" do
    field :start, :utc_datetime
    field :stop, :utc_datetime
    field :status, Ecto.Enum, values: [:working, :failing, :offline, :unchecked]
    field :message, :string

    belongs_to :project, Zout.Data.Project
  end
end
