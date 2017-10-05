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
  def get_recent_spread_data(params \\ %{}) do
    invoke_public_api("Spread" <> URI.encode_query(params))
  end

  @doc """
  Get account balance

  ## Example
      iex(1)> KrakenApi.get_account_balance()
      {:ok,
      %{"BCH" => "...", "XETH" => "...", "XLTC" => "...",
       "XXBT" => "...", "XZEC" => "...", "ZEUR" => "..."}}
  """
  def get_account_balance(params \\ %{}) do
    invoke_private_api("Balance", params)
  end

  @doc """
  Get trade balance

  """
  def get_trade_balance(params \\ %{}) do
    invoke_private_api("TradeBalance", params)
  end

  @doc """
  Get open orders
  """
  def get_open_orders(params \\ %{}) do
    invoke_private_api("OpenOrders", params)
  end

  @doc """
  Get closed orders

  ## Example
      iex(8)> KrakenApi.get_closed_orders(%{start: 1507204548})
      {:ok,
      %{"closed" => ...
        ...},
  """
  def get_closed_orders(params \\ %{}) do
    invoke_private_api("ClosedOrders", params)
  end

  @doc """
  Query orders info
  """
  def query_orders_info(params \\ %{}) do
    invoke_private_api("QueryOrders", params)
  end

  @doc """
  Get trades history
  """
  def get_trades_history(params \\ %{}) do
    invoke_private_api("TradesHistory", params)
  end

  @doc """
  Query trades info
  """
  def query_trades_info(params \\ %{}) do
    invoke_private_api("QueryTrades", params)
  end

  @doc """
  Get open positions
  """
  def get_open_positions(params \\ %{}) do
    invoke_private_api("OpenPositions", params)
  end

  @doc """
  Get ledgers info

  ## Example
      ex(1)> KrakenApi.get_ledgers_info(%{type: "deposit"})
      {:ok,
      %{"count" => 125,
       "ledger" => %{"L3OVFZ-ISK6C-L3KZ6I" => %{"aclass" => "currency",
           "amount" => "...", "asset" => "XETH",
           "balance" => "...", "fee" => "...",
           "refid" => "...", "time" => ...,
           "type" => "deposit"},
            ...
           }}}

  """
  def get_ledgers_info(params \\ %{}) do
    invoke_private_api("Ledgers", params)
  end

  @doc """
  Query ledgers
  """
  def query_ledgers(params \\ %{}) do
    invoke_private_api("QueryLedgers", params)
  end

  @doc """
  Get trade volume
  """
  def get_trade_volume(params \\ %{}) do
    invoke_private_api("TradeVolume", params)
  end

  ## Private user trading
  @doc """
  Add standard order
  """
  def add_standard_order(params \\ %{}) do
    invoke_private_api("AddOrder", params)
  end

  @doc """
  Cancel open order
  """
  def cancel_open_order(params \\ %{}) do
    invoke_private_api("CancelOrder", params)
  end

  # Function to sign the private request.
  defp sign(path, post_data, private_key, nonce) do
    post_data = URI.encode_query(post_data)
    decoded_key = Base.decode64!(private_key)
    hash_result = :crypto.hash(:sha256, nonce <> post_data)
    :crypto.hmac(:sha512, decoded_key, path <> hash_result) |> Base.encode64
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

  defp invoke_private_api(method, post_data \\ %{}, nonce \\ DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> to_string) do
    post_data = Map.merge(post_data, %{"nonce": nonce})
    path = "/" <> Application.get_env(:kraken_api, :api_version) <> "/private/" <> method
    query_url = Application.get_env(:kraken_api, :api_endpoint) <> path

    signed_message = sign(path, post_data, Application.get_env(:kraken_api, :private_key), nonce)

    # Transform the data into list-of-tuple format required by HTTPoison.
    post_data = Enum.map(post_data, fn({k, v}) -> {k, v} end)
    case HTTPoison.post(query_url,
           {:form, post_data},
           [{"API-Key", Application.get_env(:kraken_api, :api_key)}, {"API-Sign", signed_message}, {"Content-Type", "application/x-www-form-urlencoded"}]
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body = Poison.decode!(body)
        {:ok, Map.get(body, "result")}
      _ ->
        {:error, %{}}
    end
  end

end
