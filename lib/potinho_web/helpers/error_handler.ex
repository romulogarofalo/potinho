defmodule PotinhoWeb.Helpers.ErrorHandler do

  import Plug.Conn

  def bad_request(conn, msg \\ "bad_request") do
    send_resp(conn, 400, Jason.encode!(msg))
  end

  def conflict(conn) do
    send_resp(conn, 409, Jason.encode!("conflict"))
  end

  def internal_server_error(conn, msg \\ "internal_server_error") do
    send_resp(conn, 500, Jason.encode!(msg))
  end

  def not_found(conn, msg \\ "not_found") do
    send_resp(conn, 404, Jason.encode!(msg))
  end
end
