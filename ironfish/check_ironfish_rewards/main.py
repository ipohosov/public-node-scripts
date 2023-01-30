import json
import requests

IRONFISH_API_URL = "https://api.ironfish.network"


def get_short_data(user_id):
    return json.loads(requests.request("GET", f"{IRONFISH_API_URL}/users/{user_id}", headers={}, data={}).text)


def get_detailed_data(user_id):
    url = f"{IRONFISH_API_URL}/users/{user_id}/metrics?granularity=lifetime"
    return json.loads(requests.request("GET", url, headers={}, data={}).text)


def get_top_1_score():
    url = f"{IRONFISH_API_URL}/users?order_by=rank&event_type=POOL4&limit=1"
    return json.loads(requests.request("GET", url, headers={}, data={}).text).get("data")[0].get("total_points")


def aggregate_data(user_id):
    short_data = get_short_data(user_id)
    detailed_data = get_detailed_data(user_id)
    return {"User_id": short_data.get("id"), "Graffiti": short_data.get("graffiti"),
            "Rank": detailed_data.get("pools").get("main").get("rank"),
            "Total_points": short_data.get("total_points"),
            "Node_uptime_points": detailed_data.get("metrics").get("node_uptime").get("points"),
            "Mint_points": detailed_data.get("metrics").get("multi_asset_mint").get("points"),
            "Burn_points": detailed_data.get("metrics").get("multi_asset_burn").get("points"),
            "Sent_points": detailed_data.get("metrics").get("multi_asset_transfer").get("points")}


if __name__ == "__main__":

    with open('.env', 'r') as file:
        users_list = [line.strip() for line in file]

    results = []
    print(f"Top 1 user's count - {get_top_1_score()}")

    for user_id in users_list:
        result = aggregate_data(user_id)
        print(str(result))
        results.append(result)
