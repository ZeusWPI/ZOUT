defmodule Zout.Accounts do
  import Ecto.Query, warn: false
  alias Zout.Repo
  alias Zout.Accounts.User

  @doc """
  Update or create our user instance from the auth data.
  """
  def update_or_create(%Ueberauth.Auth{
        uid: id,
        info: info,
        extra: %Ueberauth.Auth.Extra{raw_info: %{admin: admin}}
      }) do
    case Repo.get(User, id) do
      nil -> %User{id: id}
      user -> user
    end
    |> User.changeset(%{
      nickname: info.nickname,
      admin: admin
    })
    |> Repo.insert_or_update!()
  end

  def get_user(id), do: Repo.get(User, id: id)
end
