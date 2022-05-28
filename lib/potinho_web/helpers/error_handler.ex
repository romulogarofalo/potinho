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

  def internal_server_error(conn, msg \\ "internal_server_error") do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(500, Jason.encode!(%{message: msg}))
  end

  def not_found(conn, msg \\ "not_found") do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(%{message: msg}))
  end
end
