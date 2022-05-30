defmodule PotinhoWeb.TransactionView do
  use PotinhoWeb, :view
  # def render("created.json", %{create_transaction_register: transaction}) do
  def render("created.json", %{create_transaction_register: transaction}) do
    %{
      transaction_id: transaction.id
    }
  end

  def render("index.json", %{transactions: transactions}) do
    render_many(transactions, __MODULE__, "transaction.json")
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      transaction_id: transaction.id,
      amount: transaction.amount.amount,
      user_reciever_name: transaction.user_reciever.full_name_user,
      is_chargeback: transaction.is_chargeback
    }
  end
end
