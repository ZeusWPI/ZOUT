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
        extra: %Ueberauth.Auth.Extra{raw_info: %{admin: zauth_admin, roles: roles}}
      }) do
    user_roles = MapSet.new(roles)
    has_admin_role = MapSet.intersection(admin_roles(), user_roles) |> Enum.empty?()

    is_zout_admin = zauth_admin || has_admin_role

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

  defp admin_roles(), do: MapSet.new(["bestuur", "zout_admin"])
end
