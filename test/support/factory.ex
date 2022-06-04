defmodule Zout.Factory do
  use ExMachina.Ecto, repo: Zout.Repo

  defp database_datetime do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  def project_factory do
    %Zout.Data.Project{
      name: "Zeus WPI",
      slug: "zeus-site",
      checker: :http_ok,
      params: %{url: "https://zeus.ugent.be"},
      inserted_at: database_datetime(),
      updated_at: database_datetime()
    }
  end

  def downtime_factory do
    %Zout.Data.Downtime{
      start: database_datetime(),
      project: build(:project),
      status: :failing,
      inserted_at: database_datetime(),
      updated_at: database_datetime()
    }
  end

  def user_factory do
    %Zout.Accounts.User{
      id: sequence("user_id", & &1),
      nickname: sequence("username"),
      admin: false
    }
  end

  def admin_factory do
    struct!(
      user_factory(),
      %{
        admin: true
      }
    )
  end
end
