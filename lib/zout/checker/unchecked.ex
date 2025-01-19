defmodule Zout.Checker.Unchecked do
  @moduledoc """
  To not perform a check.
  """
  import Ecto.Changeset

  @behaviour Zout.Checker

  @impl true
  def identifier(), do: :unchecked

  @impl true
  def check(_params) do
    {:unchecked, nil, nil}
  end

  @impl true
  def changeset(changeset, _attrs) do
    put_change(changeset, :params, %{})
  end
end
