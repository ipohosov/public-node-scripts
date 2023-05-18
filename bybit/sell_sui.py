from pybit.unified_trading import HTTP

session = HTTP(
    testnet=False,
    api_key="4ORJjIIQT5Emzbvj0p",
    api_secret="XT5VcDsY6hJ7mRmu84NEhmVaFdHLQ34rbWB2",
)

# Get the orderbook of the USDT Perpetual, BTCUSDT
# session.get_orderbook(category="linear", symbol="SUIUSDT")


payload = {"category": "option"}
orders = [{
  "symbol": "SUIUSDT",
  "side": "Sell",
  "orderType": "Limit",
  "qty": "100",
  "price": i,
} for i in [3, 2.9, 2.8, 2.7, 2.6, 2.5, 2.4, 2.3, 2.2, 2.1, 2, 1.9, 1.8, 1.7, 1.6]]

payload["request"] = orders
# Submit the orders in bulk.
session.place_batch_order(payload)
