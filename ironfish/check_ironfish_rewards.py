from abc import ABC
from src.abstract_script import AbstractScript
from ironfish.ironfish_rewards_api import IronfishRewardsAPI


class CheckIronfishRewards(AbstractScript, ABC):

    def __init__(self):
        super().__init__()
        self.bin = "docker exec -t ironfish ironfish"
        self.ironfish_api = IronfishRewardsAPI()

    def aggregate_data(self, user_id):
        short_data = self.ironfish_api.get_short_data(user_id)
        detailed_data = self.ironfish_api.get_detailed_data(user_id)
        total_hours = detailed_data.get("node_uptime").get("total_hours") + \
                      detailed_data.get("metrics").get("node_uptime").get("count") * 12
        return {"Rank": detailed_data.get("pools").get("main").get("rank"),
                "Total_points": short_data.get("total_points"), "Total_hours": total_hours,
                "Node_uptime_points": detailed_data.get("metrics").get("node_uptime").get("points"),
                "Mint_points": detailed_data.get("metrics").get("multi_asset_mint").get("points"),
                "Burn_points": detailed_data.get("metrics").get("multi_asset_burn").get("points"),
                "Sent_points": detailed_data.get("metrics").get("multi_asset_transfer").get("points")}

    def target_func(self, event, shared_list):
        if not event.is_set():
            event.set()
            shared_list.append("Initialize preconditions")
            self.server.logger.main_thread(f"Get 1 place points {self.server.server_name}.")
            self.server.logger.main_thread(f"First place has {self.ironfish_api.get_top_1_score()} points.")

        self.server.logger.info(f"Get graffiti for node {self.server.server_name}.")
        graffiti = self.server.run_command(f"{self.bin} config:get blockGraffiti")
        user_id = self.ironfish_api.get_user_id_by_graffiti(graffiti)
        result = self.aggregate_data(user_id)
        self.server.logger.success(f"Results for graffiti: {graffiti}. {result}")
