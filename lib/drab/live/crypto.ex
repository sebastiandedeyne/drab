defmodule Drab.Live.Crypto do
  @moduledoc false

  alias Plug.Crypto.KeyGenerator
  alias Plug.Crypto.MessageEncryptor

  def uuid(), do: "u" <> ({now_ms(), make_ref()} |> hash())

  # The most effective way for store assigns in the browser is basic encode
  @doc false
  def encode32(term) do
    term |> :erlang.term_to_binary() |> Base.encode32(padding: false, case: :lower)
  end

  @doc false
  def decode32(string) do
    string |> Base.decode32!(padding: false, case: :lower) |> :erlang.binary_to_term()
  end

  @doc false
  def encode64(term) do
    term |> :erlang.term_to_binary() |> Base.url_encode64()
  end

  @doc false
  def decode64(string) do
    string |> Base.url_decode64!() |> :erlang.binary_to_term()
  end

  @doc false
  def encrypt(term) do
    {secret, sign_secret} = keys()
    MessageEncryptor.encrypt(term, secret, sign_secret)
  end

  @doc false
  def decrypt(crypted) do
    {secret, sign_secret} = keys()
    {:ok, decrypted} = MessageEncryptor.decrypt(crypted, secret, sign_secret)
    decrypted
  end

  @doc false
  defp keys() do
    secret_key_base = Drab.Config.app_config(:secret_key_base)
    secret = KeyGenerator.generate(secret_key_base, "Drab.Live.Crypto salt")
    sign_secret = KeyGenerator.generate(secret_key_base, "Drab.Live.Crypto sign salt")
    {secret, sign_secret}
  end

  defp now_ms(), do: System.system_time(:milli_seconds)

  @doc false
  def hash(term) do
    :erlang.phash2(term) |> to_string() |> Base.encode32(padding: false, case: :lower)
  end

end
