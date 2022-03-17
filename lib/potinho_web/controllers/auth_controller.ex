defmodule PotinhoWeb.AuthController do
  use PotinhoWeb, :controller

  alias Potinho.Auth.Authenticate
  alias Potinho.Login
  alias PotinhoWeb.Helpers.ErrorHandler

  def login(conn, params) do
    with {:ok, changeset} <- Login.validate(params),
         {:ok, token} <- Authenticate.run(changeset) do
      conn
      |> put_status(:ok)
      |> render("login.json", %{token: token})
    else
      {:error, :invalid_credentials} ->
        ErrorHandler.bad_request(conn, "invalid_credentials")

      {:error, %Ecto.Changeset{}} ->
        ErrorHandler.bad_request(conn)

      {:error, :not_found} ->
        ErrorHandler.not_found(conn)
    end
  end
end
