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

    many_to_many :dependencies, Zout.Data.Project,
      join_through: Zout.Data.Dependency,
      join_keys: [from_id: :id, to_id: :id],
      on_replace: :delete

    many_to_many :dependants, Zout.Data.Project,
      join_through: Zout.Data.Dependency,
      join_keys: [to_id: :id, from_id: :id],
      on_replace: :delete

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
    |> put_assoc(:dependencies, Map.get(attrs, "dependencies", []))
  end
end
