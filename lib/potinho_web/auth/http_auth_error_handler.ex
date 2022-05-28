defmodule PotinhoWeb.HttpAuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, {:invalid_token, :invalid_token}, _) do
    send_resp(conn, 401, Jason.encode!(%{message: "invalid token"}))
  end
end
