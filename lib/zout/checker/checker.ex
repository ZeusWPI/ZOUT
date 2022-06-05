defmodule Zout.Checker do
  @moduledoc """
  Behaviour for a checker.
  """

  @doc """
  Get the checker instance for a type.
  """
  def checker(:http_ok), do: Zout.Checker.HttpOk
  def checker(:hydra_api), do: Zout.Checker.HydraApi

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
  @callback check(map()) ::
              :working
              | {:failing, String.t() | nil}
              | {:offline, String.t() | nil, integer() | nil}

  @doc """
  Extract the necessary params from the changeset.

  Implementations receive the changeset of a `Project` and the form params.
  They must put all required params in the `:params` structure. You must put
  something in the params structure, even if it the empty map.
  """
  @callback changeset(Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
end
