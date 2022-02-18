defmodule PotinhoWeb.UserController do
  use PotinhoWeb, :controller

  alias Potinho.User.Create
  alias PotinhoWeb.Helpers.ErrorHandler

  def create(conn, params) do
    with {:ok, user} <- Create.run(params) do
      conn
      |> put_status(:created)
      |> render("created.json", %{user: user})
    else
      {:error, %Ecto.Changeset{}} ->
        IO.inspect("agora foi")
        ErrorHandler.bad_request(conn)

      {:error, _} ->
        ErrorHandler.bad_request(conn)
    end
  end

end
