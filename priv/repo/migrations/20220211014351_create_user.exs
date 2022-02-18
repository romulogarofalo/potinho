defmodule Potinho.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      add :full_name_user, :string
      add :cpf, :string
      add :password_hash, :string
      add :balance, :integer, default: 0

      timestamps()
    end

    create unique_index(:users, [:cpf])
  end
end
