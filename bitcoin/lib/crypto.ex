defmodule Crypto do

  # Specify which fields to hash in a block
  @hash_fields [:data, :timestamp, :prev_hash, :transactions, :nonce]


  @doc "Calculate hash of block"
  def hash(%{} = block) do
    # block
    # |> Map.take(@hash_fields)
    # |> Poison.encode!
    # |> sha256
    data = block.data
    timestamp = block.timestamp
    prev_hash = block.prev_hash
    nonce = block.nonce
    block_combo = "#{data}#{prev_hash}#{timestamp}#{nonce}"
    # IO.inspect block_combo
    :crypto.hash(:sha256, block_combo) |> Base.encode16 |> String.downcase

  end


  def update_hash(%{} = block) do
    %{ block | hash: hash(block)}
  end
  @doc "Calculate and put the hash in the block"
  def put_hash(%{} = block) do
    %{ block | hash: hash(block) }
  end

  # Calculate SHA256 for a binary string
  def sha256(binary) do
    :crypto.hash(:sha256, binary) |> Base.encode16
  end

  def update_nonce(%{} = block, nonce) do
    %{ block | nonce: nonce}
  end

  def sha256_string(string) do
    :crypto.hash(:sha256, string) |> Base.encode16
  end

  def sha256_pid(pid) do
    :crypto.hash(:sha256, inspect(pid)) |> Base.encode16
  end

end

