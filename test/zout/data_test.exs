defmodule Zout.DataTest do
  use Zout.DataCase, async: true

  alias Zout.Data
  alias Zout.Data.Project

  describe "list_projects/1" do
    test "lists all non-deleted projects" do
      normal_project = insert(:project)
      _deleted_project = insert(:project, deleted: true)

      assert Data.list_projects() |> Repo.preload(:dependencies) == [normal_project]
    end

    test "lists deleted projects when asked" do
      _normal_project = insert(:project)
      deleted_project = insert(:project, deleted: true)

      assert Data.list_projects(true) |> Repo.preload(:dependencies) == [deleted_project]
    end
  end

  describe "get_project!/1" do
    test "gets existing projects" do
      expected_project = insert(:project)
      actual_project = Data.get_project!(expected_project.id)

      assert actual_project == expected_project
    end

    test "does not get non-existing user" do
      assert_raise Ecto.NoResultsError, fn ->
        Data.get_project!(-1)
      end
    end
  end

  describe "create_project/1" do
    test "with valid data creates a project" do
      valid_attrs = %{
        "name" => "hallo",
        "checker" => "hydra_api"
      }

      assert {:ok, %Project{} = project} = Data.create_project(valid_attrs)
      assert project.name == "hallo"
      assert project.checker == :hydra_api
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_project(%{})
    end
  end

  describe "update_project/2" do
    test "with valid data updates the project" do
      existing_project = insert(:project)
      update_attrs = %{"name" => existing_project.name <> existing_project.name}

      assert {:ok, %Project{} = project} = Data.update_project(existing_project, update_attrs)
      assert project.name == existing_project.name <> existing_project.name
      assert project.checker == existing_project.checker
      assert project.source == existing_project.source
      assert project.home == existing_project.home
      assert project.params == existing_project.params
    end

    test "with invalid data returns error changeset" do
      existing_project = insert(:project)
      update_attrs = %{"source" => "bliep not an url"}
      assert {:error, %Ecto.Changeset{}} = Data.update_project(existing_project, update_attrs)
      new_project = Repo.get!(Project, existing_project.id) |> Repo.preload(:dependencies)
      assert existing_project == new_project
    end
  end

  describe "delete_project/1" do
    # TODO
  end

  test "change_project/1 returns a project changeset" do
    project = build(:project)
    assert %Ecto.Changeset{} = Data.change_project(project)
  end
end
