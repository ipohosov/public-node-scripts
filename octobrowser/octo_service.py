import os
from time import sleep

from dotenv import load_dotenv
from requests import request


class OctoService:
    def __init__(self):

        if os.path.exists(os.path.join(os.getcwd(), ".env")):
            load_dotenv(dotenv_path=os.path.join(os.getcwd(), ".env"), verbose=True)
        else:
            print("The .env file not found!")
            exit(1)

        token = os.getenv("TOKEN")
        self.payload = {}
        self.headers = {'X-Octo-Api-Token': token}
        self.base_url = 'https://app.octobrowser.net/api/v2/automation'

    def get_profiles_uuid(self) -> list:
        url = self.base_url + "/profiles?page_len=100&page=0&fields=title&ordering=active"
        response = request("GET", url, headers=self.headers, data=self.payload)
        return [item.get("uuid") for item in response.json().get("data")]

    def get_profile_data(self, uuid) -> dict:
        url = self.base_url + f"/profiles/{uuid}"
        response = request("GET", url, headers=self.headers, data=self.payload)
        if "Minute requests limit reached" in response.text:
            print("Minute requests limit reached. Wait a minute.")
            sleep(60)
            response = request("GET", url, headers=self.headers, data=self.payload)
        return response.json().get("data")

    def get_proxies(self) -> list:
        url = self.base_url + "/proxies"
        response = request("GET", url, headers=self.headers, data=self.payload)

        return response.json().get("data")

    def get_tags(self) -> list:
        url = self.base_url + "/tags"
        response = request("GET", url, headers=self.headers, data=self.payload)

        return response.json().get("data")
