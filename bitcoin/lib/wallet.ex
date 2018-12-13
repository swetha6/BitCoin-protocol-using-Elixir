defmodule Wallet do
  defstruct [:public_key, :private_key, :balance, :transactions]

  def create_wallet() do
    %Wallet{
      balance: 0,
      transactions: [],
    }
  end
  def put_key(%{} = w) do
    {:ok, {priv, pub}} = RsaEx.generate_keypair
    %{w| public_key: pub, private_key: priv}
  end
  def generate_priv()do
    {:ok, priv} = RsaEx.generate_private_key
    priv
  end
  #flag == 0 sender, flag == 1 reeciver

  def generate_pub(priv)do
    {:ok, pub} = RsaEx.generate_public_key(priv)
    pub
  end

end


