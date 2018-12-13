defmodule WalletTest do
  use ExUnit.Case

  doctest Bitcoin
  # pid = self()
  setup do
    nodes = Worker.createnodes(2)
    Worker.create_wallets(nodes)
    Worker.update_coinbase(nodes)
    x = Enum.random(nodes)
    wallet = Worker.get_wallet(x)
    %{wallet: wallet}
  end
  test "update the coinbase Transaction", %{wallet: wallet} do
    # assert wallet.balance == 100
    assert length(wallet.transactions) == 1
  end
  test "check balance after coinbase transaction", %{wallet: wallet} do
    assert wallet.balance == 100
  end


end
