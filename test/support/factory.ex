defmodule Zout.Factory do
  use ExMachina.Ecto, repo: Zout.Repo

  defp database_datetime do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  def project_factory do
    %Zout.Data.Project{
      name: sequence("name"),
      checker: :http_ok,
      deleted: false,
      params: %{"url" => "https://zeus.ugent.be"},
      inserted_at: database_datetime(),
      updated_at: database_datetime()
    }
  end

  def ping_factory do
    %Zout.Data.Ping{
      stamp: database_datetime(),
      project: build(:project),
      status: :failing
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
