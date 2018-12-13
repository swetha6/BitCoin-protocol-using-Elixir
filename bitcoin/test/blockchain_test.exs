defmodule Bitcoin.BlockchainTest do
  use ExUnit.Case

  doctest Bitcoin

  setup do
    nodes = Worker.createnodes(20)
    Worker.create_wallets(nodes)
    b = Blockchain.new
    b = Worker.update_allchain(nodes, b)
    Worker.update_coinbase(nodes)
    Enum.each(1..10, fn x ->
      sender = Enum.random(nodes)
      receiver_nodes = List.delete(nodes,sender)
      receiver = Enum.random(receiver_nodes)
      sender_wallet = Worker.get_wallet(sender)
      receiver_wallet = Worker.get_wallet(receiver)
      sender_pk = sender_wallet.public_key
      receiver_pk = receiver_wallet.public_key
      amount = :rand.uniform(99)
      sender_amt = -amount
      receiver_amt = amount
      t1 = Transactions.first_transaction(sender_pk, receiver_pk, amount)
      message =  t1.id_hash
      sk = Transactions.generate_sign(message, sender_wallet.private_key)
      t1 = Transactions.put_signature(t1,sk)
      if(sender_wallet.balance < amount) do
        # IO.puts "Insufficient Funds"
        # IO.puts "Trying to send #{amount} but we you have only #{sender_wallet.balance}"
      else
        Worker.update_trans_wallet(sender,sender_wallet,t1,0,sender_amt)
        Worker.update_trans_wallet(receiver,receiver_wallet,t1,1,receiver_amt)
        Worker.check(sender, t1)
        head = Worker.get_chain(sender)
        # IO.inspect head
        new_head =
        if(rem(x,5) == 0) do
          k = Worker.get_chain(sender)
          head = Blockchain.insert(k,  "message #{x}")
          #  IO.inspect(head)
        else
          head
        end
        Worker.add_trans_to_node(nodes, new_head, t1)
    end
end)
  sample = Enum.random(nodes)
  c = Worker.get_chain(sample)
  %{c: c}
  end

  test "Create chain" do
    chain = Blockchain.new
    assert Blockchain.valid?(chain)
  end
  test "check if the previous hash of current block is equal to current hash of previous block" do
    chain = Blockchain.new
    chain = Blockchain.insert(chain, "message 2")
    block1 = Enum.at(chain, 0)
    block2 = Enum.at(chain,1)
    assert block2.hash == block1.prev_hash
    assert length(chain) == 2
  end
  test "add block to the chain" do
    chain = Blockchain.new
    chain = Blockchain.insert(chain, "message 2")
    assert length(chain) == 2
  end
  test "Create a new block for every 5 transactions", %{c: c} do
    assert length(c) <= 3
  end
end
