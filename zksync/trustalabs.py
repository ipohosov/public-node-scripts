import requests
import json
from termcolor import cprint


def read_txt(filepath: str):
    with open(filepath, "r") as file:
        return [row.strip() for row in file]


def call_json(result: list | dict, filepath: str):
    with open(f"{filepath}.json", "w") as file:
        json.dump(result, file, indent=4, ensure_ascii=False)


cprint("\nCreated by https://t.me/never_broke_again_v1\n", "blue")
results = {}
for i, wallet in enumerate(read_txt("wallets.txt"), start=1):
    try:
        response = requests.get('https://mp.trustalabs.ai/trustgo/zksync_simu_point', params={'account': wallet},
                                timeout=5)
        r = response.json()
        if "success" in r and r["success"]:
            points_earned = r["data"]["points_earned"]
            rank = r["data"]["rank"]
            results[wallet] = {
                "points_earned": points_earned,
                "rank": rank,
            }
            cprint(f"{i} | {wallet} | {points_earned} | {rank}", "white")
        else:
            cprint(f"{i} | {wallet} | r: {r}", "yellow")
    except Exception as error:
        cprint(f"{i} | {wallet} | error: {error}", "red")

call_json(results, "results")
cprint("\nРезультаты записаны в results.json\n", "green")