defmodule Zout.Accounts.User do
  @moduledoc """
  Our internal user.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, []}
  @derive {Phoenix.Param, key: :nickname}
  schema "users" do
    field :nickname, :string
    field :admin, :boolean

    timestamps()
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:id, :nickname, :admin])
    |> validate_required([:id, :nickname])
    |> unique_constraint(:id)
    |> unique_constraint(:name)
  end
end
