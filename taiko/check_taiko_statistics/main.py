import json
import requests

request_url = "https://l2explorer.a1.taiko.xyz/address-counters?id={}"


def collect_data(wallet_address):
    response = json.loads(requests.request("GET", request_url.format(wallet_address), headers={}, data={}).text)
    return {"Gas usage count": response.get("gas_usage_count"),
            "Token transfer count": response.get("token_transfer_count"),
            "Transaction count": response.get("transaction_count"),
            "Validation count": response.get("validation_count")}


if __name__ == "__main__":

    with open('.env', 'r') as file:
        wallets = [line.strip() for line in file]
    results = []

    for wallet_address in wallets:
        results.append(collect_data(wallet_address))

    for result in results:
        print(str(result))
