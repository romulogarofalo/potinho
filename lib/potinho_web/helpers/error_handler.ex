defmodule PotinhoWeb.Helpers.ErrorHandler do
  import Plug.Conn

  def bad_request(conn, msg \\ "bad_request") do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(%{message: msg}))
  end

  def conflict(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(409, Jason.encode!(%{message: "conflict"}))
  end

  def internal_server_error(conn, msg \\ %{message: "internal_server_error"}) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(500, Jason.encode!(msg))
  end

  def not_found(conn, msg \\ %{message: "not_found"}) do
    send_resp(conn, 404, Jason.encode!(msg))
  end
end
