defmodule ZoutWeb.PageController do
  use ZoutWeb, :controller

  def index(conn, _params) do
    # TODO, do something useful here.
    redirect(conn, to: Routes.project_path(conn, :index))
  end

  def crash(conn, _params) do
    text conn, "𝕯𝖔𝖒𝖎𝖓𝖚𝖘 𝖓𝖔𝖓 𝖘𝖈𝖗𝖎𝖇𝖎𝖙 𝕻𝖞𝖙𝖍𝖔𝖓𝖎𝖘"
  end
end
