
from executor.abstract_script import AbstractScript
from executor.helper import Helper
from forta.check_alchemy_cu import CheckAlchemyCU
from ironfish.check_ironfish_rewards import CheckIronfishRewards
from ironfish.ironfish_quests import IronfishQuests
from executor.server import Server


class Factory:

    def __init__(self, arg: str, server: Server):
        self.instance: AbstractScript = None
        match arg:
            case "ironfish_quests":
                self.instance = IronfishQuests(server)
            case "check_ironfish_rewards":
                self.instance = CheckIronfishRewards(server)
            case "check_alchemy_cu":
                self.instance = CheckAlchemyCU(server)
            case _:
                self.instance = Helper()
