import json
from functools import cache
import requests


class IronfishRewardsAPI:

    def __init__(self):
        self.base_url = "https://api.ironfish.network"

    def get_short_data(self, user_id):
        return json.loads(requests.request("GET", f"{self.base_url}/users/{user_id}", headers={}, data={}).text)

    def get_detailed_data(self, user_id):
        url = f"{self.base_url}/users/{user_id}/metrics?granularity=lifetime"
        return json.loads(requests.request("GET", url, headers={}, data={}).text)

    @cache
    def get_top_1_score(self):
        url = f"{self.base_url}/users?order_by=rank&event_type=POOL4&limit=1"
        return json.loads(requests.request("GET", url, headers={}, data={}).text).get("data")[0].get("total_points")

    def get_user_id_by_graffiti(self, graffiti):
        url = f"{self.base_url}/users?order_by=rank&search={graffiti}&event_type=POOL4&limit=1"
        return json.loads(requests.request("GET", url, headers={}, data={}).text).get("data")[0].get("id")
