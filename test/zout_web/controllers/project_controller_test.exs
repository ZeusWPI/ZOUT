defmodule ZoutWeb.ProjectControllerTest do
  use ZoutWeb.ConnCase

  describe "index" do
    test "lists all undeleted projects", %{conn: conn} do
      project1 = insert(:project)
      project2 = insert(:project)
      project3 = insert(:project, deleted: true)
      conn = get(conn, ~p"/projects")
      assert html_response(conn, 200) =~ project1.name
      assert html_response(conn, 200) =~ project2.name
      refute html_response(conn, 200) =~ project3.name
    end
  end

  describe "new project" do
    test "renders form for admins", %{conn: conn} do
      admin = insert(:admin)
      conn = login(conn, admin)
      conn = get(conn, ~p"/projects/new")
      assert html_response(conn, 200) =~ "Nieuw project"
    end

    test "does not render form for normal users", %{conn: conn} do
      user = insert(:user)
      conn = login(conn, user)

      assert_raise Bodyguard.NotAuthorizedError, fn ->
        get(conn, ~p"/projects/new")
      end
    end

    test "does not render form for non-users", %{conn: conn} do
      assert_raise Bodyguard.NotAuthorizedError, fn ->
        get(conn, ~p"/projects/new")
      end
    end
  end

  describe "create project" do
    test "redirects to show when data is valid if admin", %{conn: conn} do
      conn = login(conn, insert(:admin))

      valid_attrs = %{
        "name" => "hallo",
        "checker" => "hydra_api"
      }

      conn = post(conn, ~p"/projects", project: valid_attrs)

      assert redirected_to(conn) == ~p"/projects"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = login(conn, insert(:admin))
      conn = post(conn, ~p"/projects", project: %{})
      assert html_response(conn, 422) =~ "Nieuw project"
    end

    test "fails if normal user", %{conn: conn} do
      conn = login(conn, insert(:user))

      valid_attrs = %{
        "name" => "hallo",
        "checker" => "hydra_api"
      }

      assert_raise Bodyguard.NotAuthorizedError, fn ->
        post(conn, ~p"/projects", project: valid_attrs)
      end
    end

    test "fails without user", %{conn: conn} do
      valid_attrs = %{
        "name" => "hallo",
        "checker" => "hydra_api"
      }

      assert_raise Bodyguard.NotAuthorizedError, fn ->
        post(conn, ~p"/projects", project: valid_attrs)
      end
    end
  end

  describe "edit project" do
    test "renders form for admins", %{conn: conn} do
      project = insert(:project)
      admin = insert(:admin)
      conn = login(conn, admin)
      conn = get(conn, ~p"/projects/#{project}/edit")
      assert html_response(conn, 200) =~ "#{project.name} bewerken"
    end

    test "does not render form for normal users", %{conn: conn} do
      project = insert(:project)
      user = insert(:user)
      conn = login(conn, user)

      assert_raise Bodyguard.NotAuthorizedError, fn ->
        get(conn, ~p"/projects/#{project}/edit")
      end
    end

    test "does not render form for non-users", %{conn: conn} do
      project = insert(:project)

      assert_raise Bodyguard.NotAuthorizedError, fn ->
        get(conn, ~p"/projects/#{project}/edit")
      end
    end
  end

  describe "update project" do
    test "redirects to show when data is valid if admin", %{conn: conn} do
      valid_attrs = %{
        "name" => "hallo",
        "checker" => "hydra_api"
      }

      project = insert(:project)
      conn = login(conn, insert(:admin))
      conn = patch(conn, ~p"/projects/#{project}", project: valid_attrs)

      assert redirected_to(conn) == ~p"/projects/#{project}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      attrs = %{
        "home" => "not an url"
      }

      project = insert(:project)
      conn = login(conn, insert(:admin))
      conn = patch(conn, ~p"/projects/#{project}", project: attrs)
      assert html_response(conn, 422) =~ "#{project.name} bewerken"
    end

    test "fails if normal user", %{conn: conn} do
      valid_attrs = %{
        "name" => "hallo",
        "checker" => "hydra_api"
      }

      project = insert(:project)
      conn = login(conn, insert(:user))

      assert_raise Bodyguard.NotAuthorizedError, fn ->
        patch(conn, ~p"/projects/#{project}", project: valid_attrs)
      end
    end

    test "fails without user", %{conn: conn} do
      valid_attrs = %{
        "name" => "hallo",
        "checker" => "hydra_api"
      }

      project = insert(:project)

      assert_raise Bodyguard.NotAuthorizedError, fn ->
        patch(conn, ~p"/projects/#{project}", project: valid_attrs)
      end
    end
  end

  describe "delete project" do
    # TODO
  end
end
