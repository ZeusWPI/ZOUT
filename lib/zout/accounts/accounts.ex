defmodule Zout.Accounts do
  import Ecto.Query, warn: false
  alias Zout.Repo
  alias Zout.Accounts.User

  @doc """
  Update or create our user instance from the auth data.
  """
  def update_or_create!(%Ueberauth.Auth{
        uid: id,
        info: info,
        extra: %Ueberauth.Auth.Extra{raw_info: %{admin: admin, roles: roles}}
      }) do

    is_zout_admin = admin || Enum.member?(roles, "bestuur")

    case Repo.get(User, id) do
      nil -> %User{id: id}
      user -> user
    end
    |> User.changeset(%{
      nickname: info.nickname,
      admin: is_zout_admin
    })
    |> Repo.insert_or_update!()
  end

  @doc """
  Get the user with the given ID.
  """
  def get_user(id), do: Repo.get(User, id)
end
