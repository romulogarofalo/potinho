defmodule PotinhoWeb.TransactionController do
  use PotinhoWeb, :controller

  alias Potinho.Transaction.Input

  def create(conn, params) do
    IO.inspect("aaaaa")
    with %{"id" => user_sender_id} <- Guardian.Plug.current_resource(conn),
      new_map <- Map.merge(params, %{"id_sender" => user_sender_id}),
      {:ok, with_id} <- Input.validate(new_map),
      {:ok, transaction} <- Potinho.Transaction.Create.run(with_id) do
      conn
      |> put_status(:created)
      |> render("created.json", %{transaction: transaction})
    end
  end
end
