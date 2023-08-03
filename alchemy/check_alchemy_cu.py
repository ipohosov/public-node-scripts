import json
from abc import ABC

from src.abstract_script import AbstractScript
from src.helper import read_file


class CheckAlchemyCU(AbstractScript, ABC):

    def get_token(self, current_token):
        pass
        "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
            "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"

    def target_func(self, event, shared_list):
        for alchemy_account in read_file("./.env.alchemy_accounts"):
            data = alchemy_account.split(' ')
            if len(data) != 3:
                raise ValueError("The format of data in .env.alchemy_accounts file is incorrect. "
                                 "Should be - 'host_name email password'.")

            if data[0] == self.server.server_name:
                hostname = data[0]
                email = data[1]
                password = data[2]

                # self.server.logger.info(f"Get token for account with email - {email}.")
                request = "--request POST 'https://auth.alchemy.com/api/login'"
                headers = "--header 'Content-Type: application/json;charset=UTF-8'"
                data_raw_json = {"email": email, "password": password, "redirectUrl": "https://dashboard.alchemy.com"}
                data_raw = f"--data-raw '{json.dumps(data_raw_json)}'"
                auth_curl = f"curl {request} {headers} {data_raw}"

                token = json.loads(self.server.run_command(auth_curl,
                                                           hide=True, pty=True)).get("redirectTo").split("=")[1]

                # self.server.logger.info(f"Get CU usage for account with email - {email}.")
                cu_usage_curl = "curl --location --request GET 'https://dashboard.alchemy.com/api/team-fcu-usage' " \
                                f"--header 'authorization: Bearer {token}'"
                cu_usage_data = json.loads(self.server.run_command(cu_usage_curl,
                                                                   hide=True, pty=True)).get("data")
                used_cu = cu_usage_data.get("used")
                self.server.logger.success(f"Node_name: {hostname}. Account: {email}. "
                                           f"Used: {used_cu} ({round(used_cu/3000000, 2)}%)")
