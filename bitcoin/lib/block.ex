defmodule Block do
  defstruct [:data, :timestamp, :prev_hash, :hash, :transactions, :nonce]

  def new(data, prev_hash) do
    %Block{
      data: data,
      prev_hash: prev_hash,
      timestamp: NaiveDateTime.utc_now,
      transactions: [],
      nonce: 0,
    }
  end

  def genesis do
    %Block{
      data: "genesis",
      prev_hash: "genesisHASH",
      timestamp: NaiveDateTime.utc_now,
      transactions: [],
      nonce: "abcde",
    }
  end
  # .@flag true;
  def mine(%{} = block, difficulty) do
    target = String.duplicate("0", difficulty)
    temp = block.hash
    str = String.slice(temp,0, difficulty)
    y = randomizer(9)
    block_1 = Crypto.update_nonce(block, y)
    b1 = Crypto.update_hash(block_1)
    if(target === str) do
      b1 = Crypto.update_nonce(block, y)
      b1
    else
      mine(b1, difficulty)
    end
  end


  def randomizer(l) do
    :crypto.strong_rand_bytes(l) |> Base.url_encode64 |> binary_part(0, l) |> String.downcase
  end

  def add_transaction(%{} = block, transaction) do
    y = block.transactions
    # IO.inspect y
    d = y ++ [transaction]
    # IO.inspect d
    %{ block | transactions: d}
  end

  @doc "Check if a block is valid"
  def valid?(%Block{} = block) do
    Crypto.hash(block) == block.hash
  end

  def valid?(%Block{} = block, %Block{} = prev_block) do
    (block.prev_hash == prev_block.hash) && valid?(block)
  end

end
