defmodule PotinhoWeb.TransactionControllerTest do
  use ExUnit.Case
  use PotinhoWeb.ConnCase

  alias Potinho.User.Create
  alias Potinho.Guardian
  alias Potinho.Version
  alias Potinho.Transaction
  alias Potinho.User

  describe "POST /api/transaction" do
    setup %{conn: conn} do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      full_name2 = "Polvo bbb bbb"
      password2 = "123123"
      cpf2 = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      params2 = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf2,
        "balance" => "200.50"
      }

     {:ok, %{cpf: cpf, id: id}} = Create.run(params)
     Create.run(params2)

     {:ok, token, _decoded} = Guardian.encode_and_sign(Jason.encode!(%{cpf: cpf, id: id}))

     conn = put_req_header(conn, "authorization", "Bearer #{token}")

     %{
        conn: conn,
        user1: params,
        user1_token: token,
        user2: params2
      }
    end

    test "with ok params and balance", %{conn: conn, user1_token: token, user2: user2} do

      params = %{
        "cpf_reciever" => user2["cpf"],
        "amount" => "300"
      }
      response = post(conn, Routes.transaction_path(conn, :create), params)

      IO.inspect(response.body_params)
      IO.inspect(Potinho.Repo.all(User))
      IO.inspect(Potinho.Repo.all(Transaction))
      IO.inspect(Potinho.Repo.all(Version))
    end
  end

  describe "GET /api/transaction" do
    test "" do

    end
  end

end