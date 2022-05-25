defmodule Potinho.Repo.Migrations.CreateTransactionTable do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :user_sender_id, references(:users, type: :uuid)
      add :user_reciever_id, references(:users, type: :uuid)
      add :amount, :integer
      add :is_chargeback, :bool, default: false
      timestamps()
    end

    create index(:transactions, [:user_sender_id, :inserteda_at])
  end
end
