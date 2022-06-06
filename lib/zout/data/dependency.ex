defmodule Zout.Data.Dependency do
  @moduledoc """
  Registers a dependency of one service onto another.

  This is currently mainly used to draw the graph, but we might do fancy
  stuff in the future.
  """
  use Ecto.Schema

  @primary_key false
  schema "dependencies" do
    belongs_to :from, Zout.Data.Project, foreign_key: :from_id
    belongs_to :to, Zout.Data.Project, foreign_key: :to_id
  end
end
