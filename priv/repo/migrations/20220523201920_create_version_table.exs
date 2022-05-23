defmodule Potinho.Repo.Migrations.CreateVersionTable do
  use Ecto.Migration

  def change do
    create table(:versions, primary_key: false) do

      add :id, :uuid, primary_key: true, null: false, default: fragment("gen_random_uuid()")
      # The patch in Erlang External Term Format
      add :patch, :binary

      # supports UUID and other types as well
      add :entity_id, :uuid

      # name of the table the entity is in
      add :entity_schema, :string

      # type of the action that has happened to the entity (created, updated, deleted)
      add :action, :string

      # when has this happened
      add :recorded_at, :utc_datetime_usec

      # was this change part of a rollback?
      add :rollback, :boolean, default: false

      add :user_id, references(:users, on_update: :update_all, on_delete: :nilify_all, type: :uuid)
    end

    # create this if you are going to have more than a hundred of thousands of versions
    create index(:versions, [:entity_schema, :entity_id])
  end
end
