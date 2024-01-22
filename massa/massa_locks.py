from datetime import datetime, timedelta

import requests
from prettytable import PrettyTable


def read_file():
    with open("./.env", 'r') as file:
        data = [line.strip() for line in file if not line.startswith("#")]
    return data


def get_deferred_credits(wallet_address) -> list:
    url = f"https://api.massexplo.io/address/{wallet_address}?network=MainNet"
    deferred_credits = requests.request("GET", url).json().get("deferred_credits")
    agg_credits = []
    for credit in deferred_credits:
        agg_credits.append({"Date": credit.get("slot").get("period"),
                            "Wallet": wallet_address,
                            "Amount": credit.get("amount")})
    return agg_credits


def convert_periods(period):
    initial_date = datetime(2024, 1, 15, 10)
    period_time = 16
    return initial_date + timedelta(seconds=period_time * period)


credits = []
massa_addresses = read_file()
for address in massa_addresses:
    credits.extend(get_deferred_credits(address))
sorted_credits = sorted(credits, key=lambda d: d['Date'])

table = PrettyTable(['Date, UTC', 'Wallet', 'Amount'])
table.align = "l"

for credit in sorted_credits:
    table.add_row([f"{convert_periods(credit.get('Date'))}", credit.get("Wallet"), credit.get("Amount")])
print(table)
