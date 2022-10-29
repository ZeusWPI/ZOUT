defmodule ZoutWeb.FallbackController do
  use ZoutWeb, :controller

  # Handle unauthorized calls.
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(ZoutWeb.ErrorView)
    |> render(:"403")
  end
end

# Handle view exceptions
defimpl Plug.Exception, for: Phoenix.Template.UndefinedError do
  def status(_exception), do: 406
  def actions(_e), do: []
end
