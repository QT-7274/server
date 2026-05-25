defmodule AcaiWeb.Helpers.LocalePlug do
  @moduledoc """
  Sets the Gettext locale for the current request.

  Resolution order:
    1. `?locale=` query param (writes a session cookie for stickiness)
    2. session cookie set previously
    3. default: `zh_CN`

  Whitelisted locales: `en`, `zh_CN`. Anything else falls through to the default.
  """
  import Plug.Conn

  @supported_locales ~w(en zh_CN)
  @default_locale "zh_CN"
  @session_key "locale"

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = resolve_locale(conn)
    Gettext.put_locale(AcaiWeb.Gettext, locale)
    persist_locale(conn, locale)
  end

  defp resolve_locale(conn) do
    cond do
      candidate = whitelist(conn.params["locale"]) -> candidate
      candidate = whitelist(get_session(conn, @session_key)) -> candidate
      true -> @default_locale
    end
  end

  defp whitelist(value) when value in @supported_locales, do: value
  defp whitelist(_), do: nil

  # Only persist when the query param explicitly switched the locale.
  defp persist_locale(conn, locale) do
    case conn.params["locale"] do
      ^locale -> put_session(conn, @session_key, locale)
      _ -> conn
    end
  end
end
