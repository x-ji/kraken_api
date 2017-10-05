defmodule KrakenApi do
  @moduledoc """
  Documentation for KrakenApi.
  """

  import HTTPoison
  import Poison


  @doc """
  Get the server time.

  Returns a tuple {status, %{"rfc1123" => time, "unixtime" => unix_time}

  ## Example

      iex(1)> KrakenApi.get_server_time()
      {:ok, %{"rfc1123" => "Thu,  5 Oct 17 14:03:21 +0000", "unixtime" => 1507212201}}
  """
  def get_server_time() do
    invoke_public_api("Time")
  end

  @doc """
  Get asset info.

  Params:
  - info = info to retrieve (optional):
     info = all info (default)
  - aclass = asset class (optional):
     currency (default)
  - asset = comma delimited list of assets to get info on (optional.  default = all for given asset class)

  ## Example

      iex(1)> KrakenApi.get_asset_info()
      {:ok,
      %{"BCH" => %{"aclass" => "currency", "altname" => "BCH", "decimals" => 10,
         "display_decimals" => 5},
          ...
         }

      iex(1)> KrakenApi.get_asset_info(%{asset: "BCH,XBT"})
      {:ok,
      %{"BCH" => %{"aclass" => "currency", "altname" => "BCH", "decimals" => 10,
         "display_decimals" => 5},
       "XXBT" => %{"aclass" => "currency", "altname" => "XBT", "decimals" => 10,
         "display_decimals" => 5}}}
  """
  def get_asset_info(params \\ %{}) do
    invoke_public_api("Assets?" <> URI.encode_query(params))
  end

  @doc """
  Get tradable asset pairs

  Params:
  - info = info to retrieve (optional):
    - info = all info (default)
    - leverage = leverage info
    - fees = fees schedule
    - margin = margin info
  - pair = comma delimited list of asset pairs to get info on (optional.  default = all)
  """
  def get_tradable_asset_pairs(params \\ %{}) do
    invoke_public_api("AssetPairs?" <> URI.encode_query(params))
  end

  @doc """
  Get ticker information

  Param:
  - pair = comma delimited list of asset pairs to get info on
  """
  def get_ticker_information(params \\ %{}) do
    invoke_public_api("Ticker" <> URI.encode_query(params))
  end

  @doc """
  Get OHLC data

  Params:
  - pair = asset pair to get OHLC data for
  - interval = time frame interval in minutes (optional):
    1 (default), 5, 15, 30, 60, 240, 1440, 10080, 21600
  - since = return committed OHLC data since given id (optional.  exclusive)
  """
  def get_ohlc_data(params \\ %{}) do
    invoke_public_api("OHLC" <> URI.encode_query(params))
  end

  @doc """
  Get order book

  Params:
  - pair = asset pair to get market depth for
  - count = maximum number of asks/bids (optional)
  """
  def get_order_book(params \\ %{}) do
    invoke_public_api("Depth" <> URI.encode_query(params))
  end

  @doc """
  Get recent trades

  Params:
  - pair = asset pair to get spread data for
  - since = return spread data since given id (optional.  inclusive)
  """
  def get_recent_trades(params \\ %{}) do
    invoke_public_api("Trades" <> URI.encode_query(params))
  end

  @doc """
  Get recent spread data

  Params:
  - pair = asset pair to get spread data for
  - since = return spread data since given id (optional.  inclusive)
  """
  def get_recent_spread_data() do
    invoke_public_api("Spread" <> URI.encode_query(params))
  end

  @doc """
  Function to sign the private request.
  """
  defp sign(path, request, secret, nonce \\ DateTime.utc_now() |> DateTime.to_unix(:millisecond)) do
    postdata = Plug.Conn.Query.encode(request)
    decoded_secret = Base.decode64!(secret)
    hash_result = :crypto.hash(:sha256, nonce <> postdata)
    hmac_result = :crypto.hmac(:sha512, decoded_secret, path <> hash_result)
  end

  # Helper method to invoke the public APIs
  # Returns a tuple {status, result}
  defp invoke_public_api(method) do
    query_url = Application.get_env(:kraken_api, :api_endpoint) <> "/" <> Application.get_env(:kraken_api, :api_version)
    <> "/public/" <> method

    case HTTPoison.get(query_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body = Poison.decode!(body)
        {:ok, Map.get(body, "result")}
      _ ->
        {:error, %{}}
    end
  end

end
