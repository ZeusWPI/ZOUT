defmodule ZoutWeb.Auth.Guardian do
  use Guardian, otp_app: :zout

  alias Zout.Accounts
  alias Zout.Accounts.User

  @impl true
  def subject_for_token(%User{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :unknown_error}
  end

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In above `subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    case Accounts.get_user(id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
