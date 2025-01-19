defmodule ZoutWeb.ImportView do
  use ZoutWeb, :view

  def title("index.html", _assigns) do
    "Projectstructuur importeren"
  end

  def title(_, _), do: ""
end
