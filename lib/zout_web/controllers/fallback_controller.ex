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
