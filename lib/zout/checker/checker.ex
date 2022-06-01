defmodule Zout.Checker do
  @moduledoc """
  Behaviour for a checker.
  """

  @doc """
  Get the checker instance for a type.
  """
  def checker(:http_ok), do: Zout.Checker.HttpOk

  @doc """
  Get the identifier for this checker.
  """
  @callback identifier() :: Atom.t()

  @doc """
  Execute the check.

  A check can return three things:

  - `:working`, if the check was successful
  - `:failing`, if the service could be reached, but something is wrong
  - `:offline`, if the service is unreachable

  For failing and offline results, the check may return an error message that
  will be displayed to users.
  """
  @callback check(map()) :: :working | {:failing, String.t() | nil} | {:offline, String.t() | nil}
end
