defmodule PotinhoWeb.UserController do
  use PotinhoWeb, :controller

  alias Potinho.User.Create
  alias Potinho.User.Get
  alias PotinhoWeb.Helpers.ErrorHandler

  def create(conn, params) do
    case Create.run(params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("created.json", %{user: user})

      {:error,
       %Ecto.Changeset{
         errors: [
           cpf:
             {"has already been taken", [constraint: :unique, constraint_name: "users_cpf_index"]}
         ]
       }} ->
        ErrorHandler.conflict(conn)

      {:error, %Ecto.Changeset{}} ->
        ErrorHandler.bad_request(conn)

      {:error, _} ->
        ErrorHandler.internal_server_error(conn)
    end
  end

  def show(conn) do
    with %{"id" => user_sender_id} <- Guardian.Plug.current_resource(conn),
         {:ok, user} <- Get.balance(user_sender_id) do
      conn
      |> put_status(:ok)
      |> render("show.json", %{user: user})
    end
  end
end
