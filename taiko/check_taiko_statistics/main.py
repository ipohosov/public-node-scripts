import contextlib
import json
import requests

L2_EXPLORER_TAIKO = "https://l2explorer.a1.taiko.xyz"


def collect_data(wallet_address: str, node_name: str):
    node_activity = get_node_activity(wallet_address)
    balance = get_balance(wallet_address)
    return {"Node name": node_name, "Wallet address": wallet_address, "ETH": balance[-1].get("value"),
            "Gas usage count": node_activity.get("gas_usage_count"),
            "Token transfer count": node_activity.get("token_transfer_count"),
            "Transaction count": node_activity.get("transaction_count"),
            "Validation count": node_activity.get("validation_count")}


def get_node_activity(wallet_address: str):
    url = f"{L2_EXPLORER_TAIKO}/address-counters?id={wallet_address}"
    return json.loads(requests.request("GET", url, headers={}, data={}).text)


def get_balance(wallet_address: str):
    url = f"{L2_EXPLORER_TAIKO}/address/{wallet_address}/coin-balances/by-day?type=JSON"
    return json.loads(requests.request("GET", url, headers={}, data={}).text)


def get_previous_results():
    with contextlib.suppress(FileNotFoundError):
        with open('taiko_results.json', 'r') as infile:
            data = json.load(infile)
        return data
    return []


def write_results_in_file(taiko_results: list[dict]):
    with open('taiko_results.json', 'w') as outfile:
        json.dump(taiko_results, outfile)


def compare_changes(new_data: list[dict]):
    previous_data = get_previous_results()
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
                for diff, title in zip(all_diff, all_titles): # looping through all 
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
    i = 0
    for wallet_address in wallets:
        if i == 0:
            node_name = "Main node"
        else:
            node_name = f"Mult {i}"
        result = collect_data(wallet_address, node_name)
        results.append(result)
        i += 1

    compare_changes(results)
    write_results_in_file(results)
