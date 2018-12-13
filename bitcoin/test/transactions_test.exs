defmodule TransactionsTest do
  use ExUnit.Case

  doctest Bitcoin
  setup do
      nodes = Worker.createnodes(2)
      sender = Enum.random(nodes)
      Worker.create_wallets(nodes)
      Worker.update_coinbase(nodes)
      receiver_nodes = List.delete(nodes,sender)
      receiver = Enum.random(receiver_nodes)
      sender_wallet = Worker.get_wallet(sender)
      receiver_wallet = Worker.get_wallet(receiver)
      sender_pk = sender_wallet.public_key
      receiver_pk = receiver_wallet.public_key
      amount = 10
      sender_amt = -amount
      receiver_amt = amount
      t1 = Transactions.first_transaction(sender_pk, receiver_pk, amount)
      message =  t1.id_hash
      sk = Transactions.generate_sign(message, sender_wallet.private_key)
      t1 = Transactions.put_signature(t1,sk)
      Worker.update_trans_wallet(sender,sender_wallet,t1,0,sender_amt)
      Worker.update_trans_wallet(receiver,receiver_wallet,t1,1,receiver_amt)
      sender_new_wallet = Worker.get_wallet(sender)
      receiver_new_wallet = Worker.get_wallet(receiver)
      %{receiver_wallet: receiver_wallet, sender_wallet: sender_wallet, amount: amount, sender_new_wallet: sender_new_wallet, receiver_new_wallet: receiver_new_wallet}
  end
  test "waht if senders balance is less than amount" ,%{receiver_wallet: receiver_wallet,sender_wallet: sender_wallet, amount: amount, sender_new_wallet: sender_new_wallet, receiver_new_wallet: receiver_new_wallet} do
    assert (sender_wallet.balance < amount) == false
  end
  test "Check if sender's balance before sending" ,%{receiver_wallet: receiver_wallet,sender_wallet: sender_wallet, amount: amount, sender_new_wallet: sender_new_wallet, receiver_new_wallet: receiver_new_wallet} do
    assert (sender_wallet.balance > amount)
  end
  test "check updated balance of sender", %{receiver_wallet: receiver_wallet,sender_wallet: sender_wallet, amount: amount, sender_new_wallet: sender_new_wallet, receiver_new_wallet: receiver_new_wallet} do
    assert (sender_wallet.balance - amount == sender_new_wallet.balance)
  end
  test "check the updated balace of the receiver", %{receiver_wallet: receiver_wallet,sender_wallet: sender_wallet, amount: amount, sender_new_wallet: sender_new_wallet, receiver_new_wallet: receiver_new_wallet} do
    assert (receiver_wallet.balance + amount == receiver_new_wallet.balance )
  end
  test "check if the transactions updated in sender's wallet", %{receiver_wallet: receiver_wallet,sender_wallet: sender_wallet, amount: amount, sender_new_wallet: sender_new_wallet, receiver_new_wallet: receiver_new_wallet} do
    assert length(sender_wallet.transactions) + 1 == length(sender_new_wallet.transactions)
  end
  test "check if the transactions updated in receiver's wallet", %{receiver_wallet: receiver_wallet,sender_wallet: sender_wallet, amount: amount, sender_new_wallet: sender_new_wallet, receiver_new_wallet: receiver_new_wallet} do
    assert length(receiver_wallet.transactions) + 1 == length(receiver_new_wallet.transactions)
  end
end
