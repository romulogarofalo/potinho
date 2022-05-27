defmodule PotinhoWeb.TransactionControllerTest do
  use ExUnit.Case
  use PotinhoWeb.ConnCase

  # import Ecto.Query

  alias Potinho.User.Create
  alias Potinho.Guardian

  describe "POST /api/transaction" do
    setup %{conn: conn} do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      full_name2 = "Polvo bbb bbb"
      password2 = "321321"
      cpf2 = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      params2 = %{
        "full_name_user" => full_name2,
        "password" => password2,
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

    test "with ok params and balance", %{conn: conn, user2: user2} do
      params = %{
        "cpf_reciever" => user2["cpf"],
        "amount" => "300"
      }

      response = post(conn, Routes.transaction_path(conn, :create), params)

      assert response.status == 201
      # assert response.resp_body == "{\"transaction_id\":\"13863468-1c32-4d3f-b6dc-d320cf6c8956\"}"

      IO.inspect(response)
    end
  end

  # describe "GET /api/transaction" do
  #   test "" do

  #   end
  # end

  describe "POST /api/chargeback" do
    setup %{conn: conn} do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      full_name2 = "Polvo bbb bbb"
      password2 = "321321"
      cpf2 = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password2,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      params2 = %{
        "full_name_user" => full_name2,
        "password" => password,
        "cpf" => cpf2,
        "balance" => "200.50"
      }

      {:ok, %{cpf: cpf, id: id} = user1} = Create.run(params)
      Create.run(params2)

      {:ok, token, _decoded} = Guardian.encode_and_sign(Jason.encode!(%{cpf: cpf, id: id}))

      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      {:ok, %{create_transaction_register: transaction}} =
        Potinho.Transaction.Create.run(%{
          cpf_reciever: cpf2,
          amount: %{amount: 20000},
          id_sender: id
        })

      %{
        conn: conn,
        user1: user1,
        user1_token: token,
        user2: params2,
        transaction_id: transaction.id
      }
    end

    test "with ok params and balance", %{
      conn: conn,
      transaction_id: transaction_id
    } do
      params = %{
        "transaction_id" => transaction_id
      }

      response = post(conn, Routes.transaction_path(conn, :chargeback), params)
    end
  end
end
