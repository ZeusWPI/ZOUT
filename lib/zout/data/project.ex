defmodule Zout.Data.Project do
  @moduledoc """
  Represents one project.
  """
  use Ecto.Schema
  import Ecto.Changeset

  defmodule Slug do
    use EctoAutoslugField.Slug, from: :name, to: :slug
  end

  schema "projects" do
    field :name, :string
    field :slug
    Zout.Project.Slug
    field :source, :string
    field :home, :string
    field :checker, Ecto.Enum, values: [:http_ok]
    field :params, :map

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :source, :home, :check_type])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> Slug.maybe_generate_slug()
    |> Slug.unique_constraint()
  end
end
