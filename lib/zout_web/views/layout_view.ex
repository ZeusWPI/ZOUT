defmodule ZoutWeb.LayoutView do
  use ZoutWeb, :view

  # Needed to check permissions in the navigation bar.
  alias Zout.Data

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}
end
