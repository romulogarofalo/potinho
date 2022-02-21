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
      {:error, %Ecto.Changeset{errors: [
        cpf: {"has already been taken",
         [constraint: :unique, constraint_name: "users_cpf_index"]}
      ]}} ->
        ErrorHandler.conflict(conn)

      {:error, %Ecto.Changeset{}} ->
        ErrorHandler.bad_request(conn)

      {:error, _} ->
        ErrorHandler.internal_server_error(conn)
    end
  end

end
