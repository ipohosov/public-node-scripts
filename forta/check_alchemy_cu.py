import json
from abc import ABC

from executor.abstract_script import AbstractScript


class CheckAlchemyCU(AbstractScript, ABC):
    def __init__(self, server):
        super().__init__(server)

    def target_func(self, event, shared_list):
        with open('./.env.alchemy_accounts', 'r') as file:
            alchemy_accounts = [line.strip() for line in file]
        for alchemy_account in alchemy_accounts:
            data = alchemy_account.split(' ')
            if len(data) != 3:
                raise ValueError("The format of data in .env.alchemy_accounts file is incorrect. "
                                 "Should be - 'host_name email password'.")
            if data[0] in self.server.server_name:
                hostname = data[0]
                email = data[1]
                password = data[2]
                self.server.logger.info(f"Get token for account with email - {email}.")
                request = "--request POST 'https://auth.alchemy.com/api/login'"
                headers = "--header 'Content-Type: application/json;charset=UTF-8'"
                data_raw_json = {"email": email, "password": password, "redirectUrl": "https://dashboard.alchemy.com"}
                data_raw = f"--data-raw '{json.dumps(data_raw_json, indent=4)}'"
                auth_curl = f"curl {request} {headers} {data_raw}"

                token = json.loads(self.server.run_command(auth_curl,
                                                           hide=True, pty=True).stdout).get("redirectTo").split("=")[1]

                self.server.logger.info(f"Get CU usage for account with email - {email}.")
                cu_usage_curl = "curl --location --request GET 'https://dashboard.alchemy.com/api/team-fcu-usage' " \
                                "--header 'accept: application/json' " \
                                f"--header 'authorization: Bearer {token}'"
                cu_usage_data = json.loads(self.server.run_command(cu_usage_curl,
                                                                   hide=True, pty=True).stdout).get("data")
                used_cu = cu_usage_data.get("used")
                self.server.logger.success(f"Node_name: {hostname}. Account: {email}. "
                                           f"Used: {used_cu} ({round(used_cu/3000000, 2)}%)")
