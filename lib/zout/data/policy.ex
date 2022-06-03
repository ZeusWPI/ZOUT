defmodule Zout.Data.Policy do
  @behaviour Bodyguard.Policy

  alias Zout.Accounts.User

  @impl true
  def authorize(:project_index, _user, _params), do: :ok

  # Default action: admins can do anything
  @impl true
  def authorize(_action, %User{admin: admin}, _project), do: admin

  @impl true
  def authorize(_action, nil, _project), do: :error
end
