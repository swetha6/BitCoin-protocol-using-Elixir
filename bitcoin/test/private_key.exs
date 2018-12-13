defmodule PrivateKetTest do
  use ExUnit.Case
  doctest(Bitcoin)

  setup  do
    private_key = Wallet.generate_priv
    public_key = Wallet.generate_pub(private_key)
    signature = Transactions.generate_sign("message", private_key)
    %{signature: signature, public_key: public_key}

  end
  test "Verify the signature", %{signature: signature, public_key: public_key} do
    verification = Transactions.verify(public_key, signature, "message")
    assert verification
  end
  test "Verify the signature with different message", %{signature: signature, public_key: public_key} do
    verification = Transactions.verify(public_key, signature, "message1")
    assert verification == false
  end
end
