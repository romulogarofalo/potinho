defmodule Potinho.Repo.Migrations.CreateTransactionTable do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :username_sender_id, references(:users, type: :uuid)
      add :username_reciever_id, references(:users, type: :uuid)
      add :amount, :integer
      add :is_chargeback, :bool, default: false
      timestamps()
    end
  end
end