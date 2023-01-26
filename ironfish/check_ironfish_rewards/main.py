import json
from decouple import config

import requests

IRONFISH_API_URL = "https://api.ironfish.network"


def get_short_data(user_id):
    return requests.request("GET", f"{IRONFISH_API_URL}/users/{user_id}", headers={}, data={})


def get_detailed_data(user_id):
    url = f"{IRONFISH_API_URL}/users/{user_id}/metrics?granularity=lifetime"
    return requests.request("GET", url, headers={}, data={})


def get_top_1_score():
    url = f"{IRONFISH_API_URL}/users?order_by=rank&event_type=POOL4&limit=1"
    return json.loads(requests.request("GET", url, headers={}, data={}).text).get("data")[0].get("total_points")


def aggregate_data(short_response, detailed_response):
    short_data = json.loads(short_response.text)
    detailed_data = json.loads(detailed_response.text)
    return {"User_id": short_data.get("id"), "Graffiti": short_data.get("graffiti"),
            "Total_points": short_data.get("total_points"),
            "Node_uptime_points": detailed_data.get("metrics").get("node_uptime").get("points"),
            "Mint_points": detailed_data.get("metrics").get("multi_asset_mint").get("points"),
            "Burn_points": detailed_data.get("metrics").get("multi_asset_burn").get("points"),
            "Sent_points": detailed_data.get("metrics").get("multi_asset_transfer").get("points")}


if __name__ == "__main__":

    users = config("USERS")
    users_list = [int(user_id) for user_id in users.split(", ")]
    results = []

    for user_id in users_list:
        _short_data = get_short_data(user_id)
        _detailed_data = get_detailed_data(user_id)
        results.append(aggregate_data(_short_data, _detailed_data))

    print(f"Top 1 user's count - {get_top_1_score()}")

    for result in results:
        print(str(result))
