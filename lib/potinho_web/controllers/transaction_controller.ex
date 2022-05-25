defmodule PotinhoWeb.TransactionController do
  use PotinhoWeb, :controller

  alias Potinho.Transaction.Create.Input, as: CreateInput
  alias Potinho.Transaction.Create
  alias Potinho.Transaction.Index.Input, as: IndexInput
  alias Potinho.Transaction.Index

  def create(conn, params) do
    with %{"id" => user_sender_id} <- Guardian.Plug.current_resource(conn),
      new_map <- Map.merge(params, %{"id_sender" => user_sender_id}),
      {:ok, with_id} <- CreateInput.validate(new_map),
      {:ok, transaction} <- Create.run(with_id) do
        conn
        |> put_status(:created)
        |> render("created.json", transaction)
    end
  end

  def index(conn, params) do
    with %{"id" => user_sender_id} <- Guardian.Plug.current_resource(conn),
      new_map <- Map.merge(params, %{"user_id" => user_sender_id}),
      {:ok, %{user_id: user_id, initial_date: initial_date, end_date: end_date}} <- IndexInput.validate(new_map),
      {:ok, transactions} <- Index.run(user_id, initial_date, end_date) do
        IO.inspect(transactions)
        conn
        |> put_status(:ok)
        |> render("index.json", transactions)
    end
  end
end
