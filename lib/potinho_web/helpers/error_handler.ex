defmodule PotinhoWeb.Helpers.ErrorHandler do

  import Plug.Conn

  def bad_request(conn) do
    send_resp(conn, 400, Jason.encode!("bad_request"))
  end
end
