defmodule Worker do
  use GenServer
  def main(numNodes, numTx, difficulty) do

    # Enum.each(0..numNodes, fn node->
    #   IO.puts("hello world with node: #{node}");
    #   node=%{value: 10, key: 11};
    #   BitcoinPhoenixWeb.Endpoint.broadcast!("room:lobby", "new_message", node)
    # end);

    nodes = createnodes(numNodes)
    create_wallets(nodes)
    b = Blockchain.new
    b = update_allchain(nodes, b)
    update_coinbase(nodes)
    #Full topology
    Enum.each(0..numTx, fn x ->
      sender = Enum.random(nodes)
      # IO.inspect sender
      receiver_nodes = List.delete(nodes,sender)
      receiver = Enum.random(receiver_nodes)
      sender_wallet = Worker.get_wallet(sender)
      receiver_wallet = Worker.get_wallet(receiver)
      sender_pk = sender_wallet.public_key
      receiver_pk = receiver_wallet.public_key
      amount = Enum.random(1..100)
      # IO.inspect amount
      sender_amt = -amount
      receiver_amt = amount
      t1 = Transactions.first_transaction(sender_pk, receiver_pk, amount)
      message =  t1.id_hash
      sk = Transactions.generate_sign(message, sender_wallet.private_key)
      t1 = Transactions.put_signature(t1,sk)

      if(!Transactions.verify(sender_pk, sk, message)) do
        IO.puts "Invalid transaction detected!!!"
      else
        # IO.inspect t1
        # IO.inspect b
        # b = Block.add_transaction(b, t1)
        # IO.inspect b
        if(sender_wallet.balance < amount) do
          IO.puts "Insufficient Funds"
          IO.puts "Trying to send #{amount} but we you have only #{sender_wallet.balance}"
        else
          update_trans_wallet(sender,sender_wallet,t1,0,sender_amt)
          update_trans_wallet(receiver,receiver_wallet,t1,1,receiver_amt)
          check(sender, t1)
          head = get_chain(sender)
          # IO.inspect head
          new_head =
          if(rem(x,5) == 0) do
            # IO.puts "here"
            Enum.each(nodes, fn x->
                start_mining(x, difficulty)
            end)
            k = get_chain(sender)
            head = Blockchain.insert(k,  "message #{x}")
            #  IO.inspect(head)
          else
            head
          end

          # head = Enum.at(new_head,0)
          # b = update_block(head,t1)
          add_trans_to_node(nodes, new_head, t1)

          #  b = update_allchain(nodes, b)
          c1 = get_chain(sender)
          w1 = get_wallet(sender)
          w2 = get_wallet(receiver)
      end
    end
    end)
    Enum.each(nodes, fn x->
      start_mining(x, difficulty)
  end)
    sample = Enum.random(nodes)
    c = get_chain(sample)
    # IO.inspect c
    Enum.each(nodes, fn x->
      w1 = get_wallet(x)
      # w1 = Wallet.update_balance(w1)
      # IO.inspect w1
    end)
    c
  end
  def start_mining(pid, difficulty) do
    IO.inspect "print"
    GenServer.call(pid, {:start_mining, difficulty})
  end
  def update_coinbase(nodes) do
    Enum.each(nodes, fn x->
      t= Transactions.coinbase_transaction(x)
      amount = t.amount
      wallet = get_wallet(x)
      update_trans_wallet(x, wallet, t, 0, amount)
    end)
  end
  def check(sender, t1) do
    message = t1.id_hash
    sender_wallet = Worker.get_wallet(sender)
    sign = t1.signature
    sender_pk = sender_wallet.public_key
    if(!Transactions.verify(sender_pk, sign, message)) do
      IO.puts "Invalid transaction detected!!!"
      remove(t1, sender)
    end
  end

  def remove(t1, sender) do
    sender_wallet = Worker.get_wallet(sender)
    s_trans = sender_wallet.transactions
    [head|tail] = Enum.reverse(s_trans)
    s_trans = tail
    update_trans(sender,s_trans)
  end
  def update_trans(pid, trans) do
    GenServer.cast(pid, {:update_trans, trans})
  end
  def handle_cast({:update_trans, trans}, state) do
    {%{}=a,b} = state
    y = %{a | transactions: trans}
    new_state = {a,y}
    {:noreply, new_state}
  end
  def handle_call({:start_mining, difficulty}, __from, state) do
    {a,b} = state
    [head | tail] = b
    curr_block = head
    b1 = Block.mine(curr_block, difficulty)
    # IO.inspect b1
    y = [b1 | tail]
    # IO.inspect y
    new_state = {a,y}
    {:reply,b1, new_state}
  end
  def add_trans_to_node(nodes, chain, t1)do
    [%{} = head | tail] = chain
    transactions = head.transactions
    y = transactions ++ [t1]
    b = %{head | transactions: y}
    chain = [b | tail]
    update_chain(nodes, chain)
  end
  def update_chain(nodes, chain) do
    Enum.each(nodes, fn(x) ->
      GenServer.call(x, {:update_chain,chain})
    end)
  end
  def handle_call({:update_chain, chain}, __from, state) do
    {a,b} = state
    new_state = {a, chain}
    {:reply, b, new_state}
  end
  def update_trans_wallet(pid,%{} = wallet, %{} = t1, f,amt) do
    d = wallet.transactions
    b = wallet.balance
    t1 = %{t1 | flag: f}
    y = d ++ [t1]
    w1 = %{wallet | transactions: y, balance: b + amt}
    update_wallet(pid, w1)
  end
  def update_allchain(nodes, chain) do
    Enum.each(nodes, fn x ->
      update_chain_block(x, chain)
    end)
  end
  def update_chain_block(pid, chain) do
    GenServer.call(pid, {:update_chain_block,chain})
  end
  def handle_call({:update_chain_block, chain}, __from, state) do
    {a,b} = state
    # IO.inspect b
    y = chain
    new_state = {a, y}
    {:reply, y, new_state}
  end


  def update_block(%{} = block, t) do
    d = block.transactions
      y = d ++ [t]
      %{block | transactions: y}
  end
  def update_balance(pid, amt)do
    GenServer.cast(pid, {:update_balance, amt})
  end
  def handle_cast({:update_balance, amt}, state) do
    {%{}=a,b} = state
    y = a.balance+amt
    w = %{a | balance: y }
    new_state = {w,b}
    {:noreply, new_state}
  end
  def create_wallets(numNodes) do
    Enum.each(numNodes, fn x ->
      wallet = Wallet.create_wallet()
      w1 = Wallet.put_key(wallet)
      update_wallet(x, w1)
    end)
  end
  def get_chain(pid) do
    GenServer.call(pid, {:get_chain})
  end
  def handle_call({:get_chain}, __from, state) do
    {a,b} = state
    {:reply, b, state}
  end
  def get_block(pid) do
    GenServer.call(pid, {:get_block})
  end
  def handle_call({:get_block}, __from, state) do
    {a,b} = state
    block =  Enum.at(b, -1)
    {:reply, block, state}
  end
  def get_wallet(pid) do
    GenServer.call(pid, {:get_wallet})
  end

  def handle_call({:get_wallet}, __from, state) do
    {a,b} = state
    {:reply, a, state}
  end

  def createnodes(numNodes) do
    Enum.map((1..numNodes),fn(x) ->
     pid = start_node()
     pid
   end)
 end

 def update_wallet(pid,wallet) do
    GenServer.cast(pid, {:update_wallet,wallet})
 end

 def handle_cast({:update_wallet,w}, state) do
   {wallet, chain} = state
    new_state = {w,chain}
    {:noreply, new_state}
 end

def start_node() do
  {:ok,pid} = GenServer.start_link(__MODULE__, :ok, [])
  pid
end

def init(:ok) do
  {:ok, {0,[]}}
  #{wallet, chain }
end

end

Worker.main(100,5,4)
