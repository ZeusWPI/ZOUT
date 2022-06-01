defmodule Zout.DataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zout.Data` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{})
      |> Zout.Data.create_project()

    project
  end
end
