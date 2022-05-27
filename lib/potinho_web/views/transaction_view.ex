defmodule PotinhoWeb.TransactionView do
  # def render("created.json", %{create_transaction_register: transaction}) do
  def render("created.json", %{create_transaction_register: transaction}) do
    %{
      transaction_id: transaction.id
    }
  end

  def render("index.json", transactions) do
    transactions
  end

  def render("chargeback.json", _) do
    %{}
  end
end
