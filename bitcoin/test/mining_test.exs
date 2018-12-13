defmodule MiningTest do
  use ExUnit.Case
  doctest Bitcoin

  test "mine wth difficulty 1" do
    chain = Worker.main(10,5,1)
    Enum.each(chain, fn x->
      target = String.duplicate("0", 1)
      temp = x.hash
      str = String.slice(temp,0, 1)
      assert target == str
    end)
  end
  test "mine wth difficulty 2" do
    chain = Worker.main(10,5,2)
    Enum.each(chain, fn x->
      target = String.duplicate("0", 2)
      temp = x.hash
      str = String.slice(temp,0, 2)
      assert target == str
    end)
  end
  test "mine wth difficulty 3" do
    chain = Worker.main(10,5,3)
    Enum.each(chain, fn x->
      target = String.duplicate("0", 3)
      temp = x.hash
      str = String.slice(temp,0, 3)
      assert target == str
    end)
  end
  test "mine wth difficulty 4" do
    chain = Worker.main(10,5,4)
    Enum.each(chain, fn x->
      target = String.duplicate("0", 3)
      temp = x.hash
      str = String.slice(temp,0, 3)
      assert target == str
    end)
  end

end
