defmodule Zout.Data.Ping do
  @moduledoc """
  Saves the result of a check.
  """
  use Ecto.Schema

  @primary_key false
  schema "pings" do
    field :stamp, :utc_datetime
    field :status, Ecto.Enum, values: [:working, :failing, :offline, :unchecked]
    field :message, :string
    field :response_time, :integer

    belongs_to :project, Zout.Data.Project
  end
end
