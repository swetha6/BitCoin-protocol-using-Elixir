defmodule Blockchain do
  @doc "Create a new blockchain with a genesis block"
  def new do
    [Crypto.put_hash(Block.genesis)]
  end


  @doc "Insert given data as a new block in the blockchain"
  def insert(blockchain, data) when is_list(blockchain) do
    %Block{hash: prev} = hd(blockchain)

    block =
      data
      |> Block.new(prev)
      |> Crypto.put_hash

    [ block | blockchain ]
  end

  @doc "Validate the complete blockchain"
  def valid?(blockchain) when is_list(blockchain) do
    genesis = Enum.reduce_while(blockchain, nil, fn prev, current ->
      cond do
        current == nil ->
          {:cont, prev}

        Block.valid?(current, prev) ->
          {:cont, prev}

        true ->
          {:halt, false}
      end
    end)

    if genesis, do: Block.valid?(genesis), else: false
  end
end
