defmodule Zout.Checker.Unchecked do
  @moduledoc """
  To not perform a check.
  """
  import Ecto.Changeset

  @behaviour Zout.Checker

  @impl true
  def identifier(), do: :unchecked

  @impl true
  def check(params) do
    {:unchecked, nil, nil}
  end

  @impl true
  def changeset(changeset, attrs) do
    put_change(changeset, :params, %{})
  end
end
