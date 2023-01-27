import json
import requests

L2_EXPLORER_TAIKO = "https://l2explorer.a1.taiko.xyz"


def collect_data(wallet_address):
    node_activity = get_node_activity(wallet_address)
    balance = get_balance(wallet_address)
    return {"Wallet address": wallet_address, "ETH": balance[-1].get("value"),
            "Gas usage count": node_activity.get("gas_usage_count"),
            "Token transfer count": node_activity.get("token_transfer_count"),
            "Transaction count": node_activity.get("transaction_count"),
            "Validation count": node_activity.get("validation_count")}

def get_node_activity(wallet_address):
    url = f"{L2_EXPLORER_TAIKO}/address-counters?id={wallet_address}"
    return json.loads(requests.request("GET", url, headers={}, data={}).text)


def get_balance(wallet_address):
    url = f"{L2_EXPLORER_TAIKO}/address/{wallet_address}/coin-balances/by-day?type=JSON"
    return json.loads(requests.request("GET", url, headers={}, data={}).text)


if __name__ == "__main__":

    with open('.env', 'r') as file:
        wallets = [line.strip() for line in file]
    results = []

    for wallet_address in wallets:
        result = collect_data(wallet_address)
        print(str(result))
        results.append(result)
