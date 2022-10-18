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

  describe "get_project_by_slug/1" do
    test "gets existing projects" do
      expected_project = insert(:project)
      actual_project = Data.get_project_by_slug(expected_project.slug)

      assert actual_project == expected_project
    end

    test "returns nil if project does not exist" do
      assert Data.get_project_by_slug("does-not-exist") == nil
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

  test "list_projects_and_status/1 returns projects and latest ping for each project" do
    p1 = insert(:project, name: "Project 1")
    p2 = insert(:project, name: "Project 2")
    p3 = insert(:project, name: "Project 3")

    _p1_ping_1 =
      insert(:ping,
        project: p1,
        start: ~U[1999-01-01 23:00:07Z],
        stop: ~U[1999-01-01 23:00:17Z],
        status: :unchecked
      )

    _p1_ping_2 =
      insert(:ping,
        project: p1,
        start: ~U[2000-01-02 23:00:17Z],
        stop: ~U[2000-01-02 23:00:27Z],
        status: :failing
      )

    p1_ping_3 =
      insert(:ping,
        project: p1,
        start: ~U[2000-01-02 23:00:27Z],
        stop: ~U[2000-01-02 23:00:37Z],
        status: :working
      )

    p2_ping_1 =
      insert(:ping, project: p2, start: ~U[2000-01-01 23:00:07Z], stop: ~U[2000-01-01 23:00:17Z])

    expected = [
      %{
        project: p1.id,
        ping: Map.delete(p1_ping_3, :project)
      },
      %{
        project: p2.id,
        ping: Map.delete(p2_ping_1, :project)
      },
      %{
        project: p3.id,
        ping: nil
      }
    ]

    actual =
      Enum.map(
        Data.list_projects_and_status(),
        fn
          %{project: project, ping: nil} ->
            %{project: project.id, ping: nil}

          %{project: project, ping: ping} ->
            %{project: project.id, ping: Map.delete(ping, :project)}
        end
      )

    assert actual == expected
  end

  describe "recent_pings/2" do
    test "returns recent pings within duration" do
      now = DateTime.utc_now()
      now_minus_one = DateTime.add(now, -3600, :second)
      now_minus_two = DateTime.add(now_minus_one, -3600, :second)
      now_minus_three = DateTime.add(now_minus_two, -3600, :second)

      p = insert(:project)
      p_other = insert(:project)
      insert(:ping, project: p_other, start: now_minus_three, stop: now_minus_two)

      _p1 = insert(:ping, project: p, start: now_minus_three, stop: now_minus_two)
      _p2 = insert(:ping, project: p, start: now_minus_two, stop: now_minus_one)
      p3 = insert(:ping, project: p, start: now_minus_one, stop: now)

      actual =
        Enum.map(
          Data.recent_pings(p, minutes: -30),
          fn ping -> Map.delete(ping, :project) end
        )

      assert actual == [Map.delete(p3, :project)]
    end

    test "returns empty list with no pings" do
      now = DateTime.utc_now()
      now_minus_one = DateTime.add(now, -3600, :second)
      now_minus_two = DateTime.add(now_minus_one, -3600, :second)
      now_minus_three = DateTime.add(now_minus_two, -3600, :second)

      p = insert(:project)
      p_other = insert(:project)
      insert(:ping, project: p, start: now_minus_three, stop: now_minus_two)
      insert(:ping, project: p, start: now_minus_two, stop: now_minus_one)
      insert(:ping, project: p, start: now_minus_one, stop: now)

      assert Data.recent_pings(p_other, minutes: -30) == []
    end
  end

  describe "all_recent_pings/2" do
    test "returns all recent pings within duration" do
      now = DateTime.utc_now()
      now_minus_one = DateTime.add(now, -3600, :second)
      now_minus_two = DateTime.add(now_minus_one, -3600, :second)
      now_minus_three = DateTime.add(now_minus_two, -3600, :second)

      p = insert(:project, name: "Project 1")
      p_other = insert(:project, name: "Project 2")
      p4 = insert(:ping, project: p_other, start: now_minus_one, stop: now)

      _p1 = insert(:ping, project: p, start: now_minus_three, stop: now_minus_two)
      _p2 = insert(:ping, project: p, start: now_minus_two, stop: now_minus_one)
      p3 = insert(:ping, project: p, start: now_minus_one, stop: now)

      actual =
        Enum.map(
          Data.all_recent_pings(minutes: -30),
          fn %{project: project, ping: ping} ->
            %{project: project.id, ping: Map.delete(ping, :project)}
          end
        )

      expected = [
        %{
          project: p.id,
          ping: Map.delete(p3, :project)
        },
        %{
          project: p_other.id,
          ping: Map.delete(p4, :project)
        }
      ]

      assert actual == expected
    end
  end

  describe "handle_check_result/2" do
    test "appends to existing interval if same status" do
      project = insert(:project)
      now = DateTime.utc_now()
      start_date = DateTime.add(now, -3600, :second)
      stop_date = DateTime.add(now, -1800, :second)
      ping = insert(:ping, project: project, status: :working, start: start_date, stop: stop_date)

      Data.handle_check_result(project, {:working, nil, nil})

      all_pings = Data.Ping |> where(project_id: ^project.id) |> Repo.all()
      assert Enum.count(all_pings) == 1

      existing_ping = Enum.at(all_pings, 0)
      assert DateTime.compare(ping.start, existing_ping.start) == :eq
      assert DateTime.compare(ping.stop, existing_ping.stop) == :lt
    end

    test "appends to existing interval even if message differs" do
      project = insert(:project)
      now = DateTime.utc_now()
      start_date = DateTime.add(now, -3600, :second)
      stop_date = DateTime.add(now, -1800, :second)

      ping =
        insert(:ping,
          project: project,
          status: :working,
          start: start_date,
          stop: stop_date,
          message: "Hello"
        )

      _other_ping = insert(:ping)

      Data.handle_check_result(project, {:working, "Hello 2", nil})

      all_pings =
        Data.Ping
        |> order_by([p], p.start)
        |> Repo.all()

      assert Enum.count(all_pings) == 2

      existing_ping = Enum.at(all_pings, 0)
      assert DateTime.compare(ping.start, existing_ping.start) == :eq
      assert DateTime.compare(ping.stop, existing_ping.stop) == :lt
    end

    test "creates new interval if status differs" do
      project = insert(:project)
      now = DateTime.utc_now()
      start_date = DateTime.add(now, -3600, :second)
      stop_date = DateTime.add(now, -1800, :second)

      ping =
        insert(:ping,
          project: project,
          status: :working,
          start: start_date,
          stop: stop_date
        )

      _other_ping = insert(:ping)

      Data.handle_check_result(project, {:failing, nil, nil})

      all_pings =
        Data.Ping
        |> order_by([p], p.start)
        |> Repo.all()

      assert Enum.count(all_pings) == 3

      existing_ping = Enum.at(all_pings, 0)
      new_ping = Enum.at(all_pings, 1)
      assert DateTime.compare(ping.start, existing_ping.start) == :eq
      assert DateTime.compare(existing_ping.stop, new_ping.start) == :eq
      assert new_ping.status == :failing
      assert existing_ping.status == :working
    end

    test "only uses latest interval with same status" do
      project = insert(:project)
      now = DateTime.utc_now()
      date_1 = DateTime.add(now, -3600, :second)
      date_2 = DateTime.add(date_1, -3600, :second)
      date_3 = DateTime.add(date_2, -3600, :second)

      stop_date = DateTime.add(date_1, 1800, :second)

      # We create three intervals:
      # 1. Working
      # 2. Failing
      # 3. Working
      # We then insert a new interval that is working, and expect interval 3 to be modified.

      working_ping_1 =
        insert(:ping, project: project, status: :working, start: date_1, stop: stop_date)
        |> Map.delete(:project)

      failing_ping =
        insert(:ping, project: project, status: :failing, start: date_2, stop: date_1)
        |> Map.delete(:project)

      working_ping_2 =
        insert(:ping, project: project, status: :working, start: date_3, stop: date_2)
        |> Map.delete(:project)

      Data.handle_check_result(project, {:working, nil, nil})

      all_pings =
        Data.Ping
        |> order_by([p], p.start)
        |> Repo.all()

      assert Enum.count(all_pings) == 3

      resulting_ping_3 = Enum.at(all_pings, 0) |> Map.delete(:project)
      resulting_ping_2 = Enum.at(all_pings, 1) |> Map.delete(:project)
      _resulting_ping_1 = Enum.at(all_pings, 2) |> Map.delete(:project)

      assert resulting_ping_3 == working_ping_2
      assert resulting_ping_2 == failing_ping

      assert DateTime.compare(working_ping_1.stop, resulting_ping_3.stop) == :lt
      assert DateTime.compare(working_ping_1.start, resulting_ping_3.start) == :eq
      assert resulting_ping_3.status == :working
    end

    test "does not use previous interval with same status" do
      project = insert(:project)
      now = DateTime.utc_now()
      date_1 = DateTime.add(now, -3600, :second)
      date_2 = DateTime.add(date_1, -3600, :second)
      date_3 = DateTime.add(date_2, -3600, :second)

      stop_date = DateTime.add(date_1, 1800, :second)

      # We create three intervals:
      # 1. Working
      # 2. Failing
      # 3. Working
      # We then insert a new ping that is failing, and expect a new interval to be made.

      working_ping_1 =
        insert(:ping, project: project, status: :working, start: date_1, stop: stop_date)
        |> Map.delete(:project)

      failing_ping =
        insert(:ping, project: project, status: :failing, start: date_2, stop: date_1)
        |> Map.delete(:project)

      working_ping_2 =
        insert(:ping, project: project, status: :working, start: date_3, stop: date_2)
        |> Map.delete(:project)

      Data.handle_check_result(project, {:failing, nil, nil})

      all_pings =
        Data.Ping
        |> order_by([p], p.start)
        |> Repo.all()

      assert Enum.count(all_pings) == 4

      resulting_ping_3 = Enum.at(all_pings, 0) |> Map.delete(:project)
      resulting_ping_2 = Enum.at(all_pings, 1) |> Map.delete(:project)
      resulting_ping_1 = Enum.at(all_pings, 2) |> Map.delete(:project)
      resulting_ping_0 = Enum.at(all_pings, 3) |> Map.delete(:project)

      assert resulting_ping_3 == working_ping_2
      assert resulting_ping_2 == failing_ping

      assert DateTime.compare(resulting_ping_1.stop, resulting_ping_0.start) == :eq
      assert resulting_ping_1.status == :working
      assert DateTime.compare(resulting_ping_1.start, working_ping_1.start) == :eq
      assert resulting_ping_0.status == :failing
    end
  end
end
