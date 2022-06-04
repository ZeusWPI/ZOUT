defmodule Zout.Data.Project do
  @moduledoc """
  Represents one project.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :source, EctoFields.URL
    field :home, EctoFields.URL
    field :checker, Ecto.Enum, values: [:http_ok, :hydra_api]
    field :params, :map
    field :deleted, :boolean

    timestamps()
  end

  defp handle_checker(changeset, attrs) do
    case fetch_change(changeset, :checker) do
      {:ok, data} -> Zout.Checker.checker(data).changeset(changeset, attrs)
      _ -> changeset
    end
  end

  def changeset(project, attrs \\ %{}) do
    project
    |> cast(attrs, [:name, :source, :home, :checker])
    |> validate_required([:name, :checker])
    |> unique_constraint(:name)
    |> handle_checker(attrs)
    |> validate_required([:params])
  end
end
