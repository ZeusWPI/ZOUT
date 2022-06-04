defmodule Zout.Data.Downtime do
  use Ecto.Schema
  import Ecto.Changeset

  schema "downtimes" do
    field :end, :utc_datetime
    field :start, :utc_datetime
    belongs_to :project, Zout.Data.Project
    field :status, Ecto.Enum, values: [:working, :failing, :offline]

    timestamps()
  end
end
