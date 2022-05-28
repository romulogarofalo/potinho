defmodule PotinhoWeb.TransactionControllerTest do
  use ExUnit.Case
  use PotinhoWeb.ConnCase

  import Ecto.Query

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

      full_name3 = "edu ccc ccc"
      password3 = "111111"
      cpf3 = Brcpfcnpj.cpf_generate()

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

      params3 = %{
        "full_name_user" => full_name3,
        "password" => password3,
        "cpf" => cpf3,
        "balance" => "400.50"
      }

      {:ok, %{cpf: cpf, id: id} = user1} = Create.run(params)
      {:ok, user2} = Create.run(params2)
      {:ok, user3} = Create.run(params3)

      {:ok, token, _decoded} = Guardian.encode_and_sign(Jason.encode!(%{cpf: cpf, id: id}))

      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      %{
        conn: conn,
        user1: user1,
        user1_token: token,
        user2: user2,
        user3: user3
      }
    end

    test "with ok params and balance", %{conn: conn, user2: user2} do
      params = %{
        "cpf_reciever" => user2.cpf,
        "amount" => "300"
      }

      response = post(conn, Routes.transaction_path(conn, :create), params)

      [transaction] = Repo.all(Potinho.Transaction)
      [user3, user2, user1] = Enum.sort(Repo.all(Potinho.User))

      assert response.status == 201
      assert response.resp_body == "{\"transaction_id\":\"#{transaction.id}\"}"
      assert user1.balance.amount == (100050 - 30000)
      assert user2.balance.amount == (20050 + 30000)
      assert user3.balance.amount == 40050
    end

    test "when transfer for itself", %{conn: conn, user1: user1, user2: user2, user3: user3} do
      params = %{
        "cpf_reciever" => user1.cpf,
        "amount" => "201"
      }

    response = post(conn, Routes.transaction_path(conn, :create), params)

    [transaction] = Repo.all(Potinho.Transaction)
    [user3db, user2db, user1db] = Enum.sort(Repo.all(Potinho.User))

    assert response.status == 201
    assert response.resp_body == "{\"transaction_id\":\"#{transaction.id}\"}"

    #  the sort is using the balance so need to check the id
    assert user1db.balance.amount == 100050
    assert user1.id == user1db.id
    assert user2db.balance.amount == 40050
    assert user2.id == user3db.id
    assert user3db.balance.amount == 20050
    assert user3.id == user2db.id
    end

    test "when has no founds", %{conn: conn, user2: user2} do
      params = %{
        "cpf_reciever" => user2.cpf,
        "amount" => "1100"
      }

      response = post(conn, Routes.transaction_path(conn, :create), params)

      assert response.resp_body == "{\"message\":\"balance too low\"}"
      assert response.status == 400
    end

    test "when reciever do not exists", %{conn: conn, user1: user1}  do
      params = %{
        "cpf_reciever" => Brcpfcnpj.cpf_generate(),
        "amount" => "200"
      }

      response = post(conn, Routes.transaction_path(conn, :create), params)

      assert response.resp_body == "{\"message\":\"cpf not found\"}"

      user_to_test = Repo.get_by(Potinho.User, %{id: user1.id})
      assert user_to_test.balance.amount == 100050
    end

    test "when is unauthorized", %{conn: conn, user1: user1} do
      conn_with_wrong_token = put_req_header(conn, "authorization", "Bearer not a token")
      params = %{
        "cpf_reciever" => Brcpfcnpj.cpf_generate(),
        "amount" => "200"
      }

      response = post(conn_with_wrong_token, Routes.transaction_path(conn, :create), params)
      assert response.status == 401
      assert response.resp_body == "{\"message\":\"invalid token\"}"
    end
  end

  describe "GET /api/transaction" do
    setup %{conn: conn} do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      full_name2 = "Polvo bbb bbb"
      password2 = "321321"
      cpf2 = Brcpfcnpj.cpf_generate()

      full_name3 = "edu ccc ccc"
      password3 = "111111"
      cpf3 = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password2,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      params2 = %{
        "full_name_user" => full_name2,
        "password" => password2,
        "cpf" => cpf2,
        "balance" => "200.50"
      }
      params3 = %{
        "full_name_user" => full_name3,
        "password" => password3,
        "cpf" => cpf3,
        "balance" => "70000.50"
      }

      {:ok, %{cpf: cpf, id: id} = user1} = Create.run(params)
      {:ok, user2} = Create.run(params2)
      {:ok, user3} = Create.run(params3)

      {:ok, token, _decoded} = Guardian.encode_and_sign(Jason.encode!(%{cpf: user3.cpf, id: user3.id}))

      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      {:ok, %{create_transaction_register: transaction1}} =
        Potinho.Transaction.Create.run(%{
          cpf_reciever: cpf2,
          amount: %{amount: 10000},
          id_sender: user3.id
        })
      {:ok, %{create_transaction_register: transaction2}} =
        Potinho.Transaction.Create.run(%{
          cpf_reciever: cpf2,
          amount: %{amount: 20000},
          id_sender: user3.id
        })
      {:ok, %{create_transaction_register: transaction3}} =
        Potinho.Transaction.Create.run(%{
          cpf_reciever: cpf,
          amount: %{amount: 30000},
          id_sender: user2.id
        })

      %{
        conn: conn,
        user1: user1,
        user1_token: token,
        user2: user2,
        user3: user3,
        transaction_id: transaction.id
      }
    end

    test "with rigth range", %{conn: conn} do
      response = post(conn, Routes.transaction_path(conn, :index), params)
      IO.inspect(response.resp_body)
    end
  end

  describe "POST /api/chargeback" do
    setup %{conn: conn} do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      full_name2 = "Polvo bbb bbb"
      password2 = "321321"
      cpf2 = Brcpfcnpj.cpf_generate()

      full_name3 = "edu ccc ccc"
      password3 = "111111"
      cpf3 = Brcpfcnpj.cpf_generate()


      params = %{
        "full_name_user" => full_name,
        "password" => password2,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      params2 = %{
        "full_name_user" => full_name2,
        "password" => password2,
        "cpf" => cpf2,
        "balance" => "200.50"
      }
      params3 = %{
        "full_name_user" => full_name3,
        "password" => password3,
        "cpf" => cpf3,
        "balance" => "70000.50"
      }

      {:ok, %{cpf: cpf, id: id} = user1} = Create.run(params)
      {:ok, user2} = Create.run(params2)
      {:ok, user3} = Create.run(params3)

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
        user2: user2,
        user3: user3,
        transaction_id: transaction.id
      }
    end

    test "with ok params and balance", %{
      conn: conn,
      transaction_id: transaction_id,
      user1: user1,
      user2: user2,
      user3: user3
    } do
      params = %{
        "transaction_id" => transaction_id
      }

      %{balance: %{amount: user_2_amount}} = Repo.get_by(Potinho.User, id: user2.id)
      %{balance: %{amount: user_1_amount}} = Repo.get_by(Potinho.User, id: user1.id)
      %{balance: %{amount: user_3_amount}} = Repo.get_by(Potinho.User, id: user3.id)

      assert user_2_amount == 40050
      assert user_1_amount == 80050
      assert user_3_amount == 7000050

      response = post(conn, Routes.transaction_path(conn, :chargeback), params)
      assert response.status == 204

      %{balance: %{amount: user_2_chagebacked}} = Repo.get_by(Potinho.User, id: user2.id)
      %{balance: %{amount: user_1_chagebacked}} = Repo.get_by(Potinho.User, id: user1.id)
      %{balance: %{amount: user_3_chagebacked}} = Repo.get_by(Potinho.User, id: user3.id)

      assert user_2_chagebacked == 20050
      assert user_1_chagebacked == 100050
      assert user_3_chagebacked == 7000050

      [%{is_chargeback: is_chargeback}] = Potinho.Repo.all(Potinho.Transaction)
      assert is_chargeback
    end

    test "when is not possible to chagerback", %{
      conn: conn,
      transaction_id: transaction_id,
      user1: user1,
      user2: user2,
      user3: user3
    } do
      params = %{
        "transaction_id" => transaction_id
      }

      {:ok, %{create_transaction_register: transaction}} =
        Potinho.Transaction.Create.run(%{
          cpf_reciever: user3.cpf,
          amount: %{amount: 30000},
          id_sender: user2.id
        })

      %{balance: %{amount: user_2_amount}} = Repo.get_by(Potinho.User, id: user2.id)
      %{balance: %{amount: user_1_amount}} = Repo.get_by(Potinho.User, id: user1.id)

      assert user_2_amount == 10050
      assert user_1_amount == 80050

      response = post(conn, Routes.transaction_path(conn, :chargeback), params)
      assert response.status == 400
      assert response.resp_body == "{\"message\":\"chargeback is not possible\"}"

      %{balance: %{amount: user_2_chagebacked}} = Repo.get_by(Potinho.User, id: user2.id)
      %{balance: %{amount: user_1_chagebacked}} = Repo.get_by(Potinho.User, id: user1.id)

      assert user_2_chagebacked == 10050
      assert user_1_chagebacked == 80050

      [%{is_chargeback: is_chargeback}, %{is_chargeback: is_chargeback2}] = Potinho.Repo.all(Potinho.Transaction)
      assert not is_chargeback
      assert not is_chargeback2
    end

    test "when dont find transaction", %{conn: conn} do
      params = %{
        "transaction_id" => Ecto.UUID.generate()
      }

      response = post(conn, Routes.transaction_path(conn, :chargeback), params)
      assert response.status == 404
      assert response.resp_body == "{\"message\":\"transaction not found\"}"
    end

    test "when is unauthorized", %{conn: conn, user1: user1} do
      conn_with_wrong_token = put_req_header(conn, "authorization", "Bearer not a token")
      params = %{
        "transaction_id" => Ecto.UUID.generate()
      }

      response = post(conn_with_wrong_token, Routes.transaction_path(conn, :chargeback), params)
      assert response.status == 401
      assert response.resp_body == "{\"message\":\"invalid token\"}"
    end
  end
end
