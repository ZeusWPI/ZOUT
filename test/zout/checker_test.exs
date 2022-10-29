defmodule Zout.CheckerTest do
  use Zout.DataCase, async: true

  alias Zout.Checker.Unchecked
  alias Zout.Checker.HttpOk
  alias Zout.Checker.HydraApi

  defp setup_server(_context) do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "unchecked" do
    result = Unchecked.check(%{})
    assert result == {:unchecked, nil, nil}
  end

  describe "http_ok" do
    setup [:setup_server]

    test "ok", %{bypass: bypass} do
      for http_code <- [200, 202, 203, 204, 206] do
        Bypass.expect_once(bypass, "GET", "/ok", fn conn ->
          Plug.Conn.resp(conn, http_code, ~s<>)
        end)

        result = HttpOk.check(%{"url" => "http://localhost:#{bypass.port}/ok"})
        assert result == {:working, nil, nil}
      end
    end

    test "failing", %{bypass: bypass} do
      for http_code <- [400, 404, 500] do
        Bypass.expect_once(bypass, "GET", "/failing", fn conn ->
          Plug.Conn.resp(conn, http_code, ~s<>)
        end)

        result = HttpOk.check(%{"url" => "http://localhost:#{bypass.port}/failing"})
        assert result == {:failing, nil, nil}
      end
    end

    test "offline", %{bypass: bypass} do
      result = HttpOk.check(%{"url" => "http://localhost:#{bypass.port + 25}/failing"})
      assert result == {:offline, nil, nil}
    end
  end

  describe "hydra_api" do
    setup [:setup_server]

    test "ok", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/ok", fn conn ->
        now = DateTime.utc_now() |> Timex.format!("{0D}-{Mshort}-{YYYY} {h24}:{m}")

        Plug.Conn.resp(conn, 200, ~s"""
          <html>
          <head><title>Index of /api/2.0/</title></head>
          <body>
          <h1>Index of /api/2.0/</h1><hr><pre><a href="../">../</a>
          <a href="association/">association/</a>                    #{now}   -
          <a href="info/">info/</a>                                  #{now}   -
          <a href="news/">news/</a>                                  #{now}   -
          <a href="resto/">resto/</a>                                #{now}   -
          <a href="urgentfm/">urgentfm/</a>                          #{now}   -
          </pre><hr></body>
          </html>
        """)
      end)

      result = HydraApi.check(%{"url" => "http://localhost:#{bypass.port}/ok"})
      assert result == {:working, nil, nil}
    end

    test "failing old data", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/ok", fn conn ->
        now =
          DateTime.utc_now()
          |> DateTime.add(-31_556_926, :second)
          |> Timex.format!("{0D}-{Mshort}-{YYYY} {h24}:{m}")

        Plug.Conn.resp(conn, 200, ~s"""
          <html>
          <head><title>Index of /api/2.0/</title></head>
          <body>
          <h1>Index of /api/2.0/</h1><hr><pre><a href="../">../</a>
          <a href="association/">association/</a>                    #{now}   -
          <a href="info/">info/</a>                                  #{now}   -
          <a href="news/">news/</a>                                  #{now}   -
          <a href="resto/">resto/</a>                                #{now}   -
          <a href="urgentfm/">urgentfm/</a>                          #{now}   -
          </pre><hr></body>
          </html>
        """)
      end)

      result = HydraApi.check(%{"url" => "http://localhost:#{bypass.port}/ok"})
      assert result == {:failing, "Scraper has not run in the last 24 hours", nil}
    end

    test "failing http", %{bypass: bypass} do
      for http_code <- [400, 404, 500] do
        Bypass.expect_once(bypass, "GET", "/failing", fn conn ->
          Plug.Conn.resp(conn, http_code, ~s<>)
        end)

        result = HydraApi.check(%{"url" => "http://localhost:#{bypass.port}/failing"})
        assert result == {:failing, nil, nil}
      end
    end

    test "offline", %{bypass: bypass} do
      result = HydraApi.check(%{"url" => "http://localhost:#{bypass.port + 25}/failing"})
      assert result == {:offline, nil, nil}
    end
  end
end
