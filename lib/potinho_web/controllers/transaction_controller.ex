defmodule PotinhoWeb.TransactionController do
  use PotinhoWeb, :controller

  require Logger

  alias Potinho.Transaction.Create.Input, as: CreateInput
  alias Potinho.Transaction.Create
  alias Potinho.Transaction.Chargeback
  alias Potinho.Transaction.Index.Input, as: IndexInput
  alias Potinho.Transaction.Index
  alias PotinhoWeb.Helpers.ErrorHandler
  alias Potinho.Guardian

  def create(conn, params) do
    with %{"id" => user_sender_id} <- Guardian.Plug.current_resource(conn),
         new_map <- Map.merge(params, %{"id_sender" => user_sender_id}),
         {:ok, with_id} <- CreateInput.validate(new_map),
         {:ok, transaction} <- Create.run(with_id) do
      conn
      |> put_status(:created)
      |> render("created.json", transaction)
    else
      {:error, :verify_balances_step, :balance_too_low, _} ->
        ErrorHandler.bad_request(conn, "balance too low")

      {:error, :get_reciever_step, :user_not_found, _} ->
        ErrorHandler.not_found(conn, "cpf not found")

      {:error, :tabela_ta_em_lock} ->
        ErrorHandler.internal_server_error(conn)

      {:error, %Ecto.Changeset{}} ->
        ErrorHandler.bad_request(conn)

      error ->
        Logger.error("#{__MODULE__}.create error=#{error}")
        ErrorHandler.internal_server_error(conn)
    end
  end

  def index(conn, params) do
    with %{"id" => user_sender_id} <- Guardian.Plug.current_resource(conn),
         new_map <- Map.merge(params, %{"user_id" => user_sender_id}),
         {:ok, %{user_id: user_id, initial_date: initial_date, end_date: end_date}} <-
           IndexInput.validate(new_map),
         transactions <- Index.run(user_id, initial_date, end_date) do
      conn
      |> put_status(:ok)
      |> render("index.json", %{transactions: transactions})
    else
      {:error, %Ecto.Changeset{}} ->
        ErrorHandler.bad_request(conn)

      error ->
        Logger.error("#{__MODULE__}.create error=#{error}")
        ErrorHandler.internal_server_error(conn)
    end
  end

  def chargeback(conn, %{"transaction_id" => transaction_id}) do
    with %{"id" => user_id} <- Guardian.Plug.current_resource(conn),
         {:ok, _transaction} <- Chargeback.run(transaction_id, user_id) do
      conn
      |> put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(204, "")
    else
      {:error, :verify_charback_step, :chargeback_already_done, _} ->
        ErrorHandler.bad_request(conn, "chargeback already done")

      {:error, :verify_balance_step, :balance_too_low, _} ->
        ErrorHandler.bad_request(conn, "chargeback is not possible")

      {:error, :get_transaction_step, _, _} ->
        ErrorHandler.not_found(conn, "transaction not found")

      {:error, %Ecto.Changeset{}} ->
        ErrorHandler.bad_request(conn)

      error ->
        Logger.error("#{__MODULE__}.chargeback error=#{error}")
        ErrorHandler.internal_server_error(conn)
    end
  end

  def chargeback(conn, _) do
    ErrorHandler.bad_request(conn)
  end
end
