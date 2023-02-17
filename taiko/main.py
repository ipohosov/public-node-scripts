import contextlib
import json
import requests

from src.helper import read_file, write_file

L1_EXPLORER_TAIKO = "https://l1explorer.a1.taiko.xyz/"
L2_EXPLORER_TAIKO = "https://l2explorer.a1.taiko.xyz/"


def collect_data(wallet_address: str, node_name: str, explorer_url):
    node_activity = get_node_activity(wallet_address, explorer_url)
    balance = get_balance(wallet_address, explorer_url)
    return {"Node name": node_name, "Wallet address": wallet_address, "ETH": balance[-1].get("value"),
            "Gas usage count": node_activity.get("gas_usage_count"),
            "Token transfer count": node_activity.get("token_transfer_count"),
            "Transaction count": node_activity.get("transaction_count"),
            "Validation count": node_activity.get("validation_count")}


def get_node_activity(wallet_address: str, explorer_url):
    url = f"{explorer_url}/address-counters?id={wallet_address}"
    return json.loads(requests.request("GET", url, headers={}, data={}).text)


def get_balance(wallet_address: str, explorer_url):
    url = f"{explorer_url}/address/{wallet_address}/coin-balances/by-day?type=JSON"
    return json.loads(requests.request("GET", url, headers={}, data={}).text)

def compare_changes(new_data: list[dict], layer_version):
    previous_data = read_file(f'taiko_results_{layer_version}.json', is_json=True)
    if previous_data:
        sorted_data_previous_data = sorted(previous_data, key=lambda d: d['Wallet address'])
        spd = sorted_data_previous_data
        sorted_data_new_data = sorted(new_data, key=lambda d: d['Wallet address'])
        snd = sorted_data_new_data
        for node_item in range(0, len(new_data)):
            eth_diff = snd[node_item].get('ETH') - spd[node_item].get('ETH')
            gas_diff = snd[node_item].get('Gas usage count') - spd[node_item].get('Gas usage count')
            token_diff = snd[node_item].get('Token transfer count') - spd[node_item].get('Token transfer count')
            transaction_diff = snd[node_item].get('Transaction count') - spd[node_item].get('Transaction count')
            validation_diff = snd[node_item].get('Validation count') - spd[node_item].get('Validation count')
            all_diff = [eth_diff, gas_diff, token_diff, transaction_diff, validation_diff]
            all_titles = ["ETH", "Gas usage count", "Token transfer count", "Transaction count", "Validation count"]
            if sum(map(abs, all_diff)) > 0:  # checks if any of the differences is not 0
                aggregated_text = ""  # empty string to store the differences
                entry = 0
                for diff, title in zip(all_diff, all_titles):  # looping through all
                    if abs(diff) > 0:
                        # adding difference to the string
                        aggregated_text = aggregated_text + f"{'' if entry ==0 else ', '}{title}: {diff}"
                        entry += 1
                aggregated_output = \
                    f"Wallet: {snd[node_item].get('Wallet address')} has the following changes: {aggregated_text}"
            else:  # if there are no changes
                aggregated_output = f"Wallet: {snd[node_item].get('Wallet address')} has no changes"
            # printing out the changes
            eth_left = f"ETH left: {round(snd[node_item].get('ETH'), 2)}"
            print(f"Node name: {snd[node_item].get('Node name')}. {aggregated_output}. {eth_left}.")
    else:
        print("The previous results were not found. The script will write current results in file "
              "and will use them next time for comparing.")


if __name__ == "__main__":

    with open('.env', 'r') as file:
        wallets = [line.strip() for line in file]
    results = []
    for url, layer_version in zip([L1_EXPLORER_TAIKO, L2_EXPLORER_TAIKO], ["l1", "l2"]):
        i = 0
        results = []
        print(f"\nThe statistics for - {url}\n")
        for wallet_address in wallets:
            node_name = f"Mult {i}"
            result = collect_data(wallet_address, node_name, url)
            results.append(result)
            i += 1

        compare_changes(results, layer_version)
        write_file(results, f'taiko_results_{layer_version}.json', is_json=True)
