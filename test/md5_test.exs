defmodule Md5Test do
  use ExUnit.Case
  doctest Md5

  test "hash small message" do
    assert Md5.digest("Hello world") == "3e25960a79dbc69b674cd4ec67a72c62"
  end

  test "hash empty string" do
    assert Md5.digest("") == "d41d8cd98f00b204e9800998ecf8427e"
  end

  test "hash character a" do
    assert Md5.digest("a") == "0cc175b9c0f1b6a831c399e269772661"
  end

  test "hash string abc" do
    assert Md5.digest("abc") == "900150983cd24fb0d6963f7d28e17f72"
  end

  test "hash string generic" do
    assert Md5.digest("message digest") == "f96b697d7cb7938d525a2f31aaf161d0"
  end

  test "hash lowercase alphabet" do
    assert Md5.digest("abcdefghijklmnopqrstuvwxyz") == "c3fcd3d76192e4007dfb496cca67e13b"
  end

  test "hash lowercase and uppercase alphabet" do
    assert Md5.digest("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") == "d174ab98d277d9f5a5611c2c9f419d9f"
  end

  test "hash numerical string" do
    assert Md5.digest("12345678901234567890123456789012345678901234567890123456789012345678901234567890") == "57edf4a22be3c955ac49da2e2107b67a"
  end

  test "hash string exactly 512 bits" do
    assert Md5.digest(String.duplicate("a", 64)) == "014842d480b571495a4a0363793f7367"
  end

  test "hash string requiring extra padding for 1 and length" do
    assert Md5.digest(String.duplicate("a", 62)) == "24612f0ce2c9d2cf2b022ef1e027a54f"
  end
end
