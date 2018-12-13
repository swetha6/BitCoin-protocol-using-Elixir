defmodule Transactions do
  defstruct [:id_hash, :public_key_sender, :public_key_receiver, :amount, :flag, :signature]
  def coinbase_transaction(x) do
    %Transactions{
      id_hash: Crypto.sha256_string("CoinBaseTransaction"),
      public_key_sender: x,
      public_key_receiver: x,
      flag: 0,
      amount: 100,
    }
  end
  def first_transaction(sender, receiver, amount) do
    %Transactions{
      id_hash: Crypto.sha256_string("#{sender}#{receiver}#{amount}"),
      public_key_sender: sender,
      public_key_receiver: receiver,
      flag: 0,
      amount: amount,
    }
  end

  @ecdsa_curve :secp256k1
  @type_signature :ecdsa
  @type_hash :sha256

  def put_signature(%{} = tx,sign) do
    %{tx | signature: sign}
  end

  # def generate(private_key, message) do
  #   :crypto.sign(@type_signature, @type_hash, message, [private_key, @ecdsa_curve])
  # end
  def generate_sign(message, priv) do
    {:ok, sign} = RsaEx.sign(message, priv)
    sign
  end
  def verify(public_key, signature, message) do
    # :crypto.verify(@type_signature, @type_hash, message, signature, [public_key, @ecdsa_curve])
    {:ok, valid} = RsaEx.verify(message, signature, public_key)
    valid
  end

end

