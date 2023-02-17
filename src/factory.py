from src.abstract_script import AbstractScript
from src.helper import help_message
from alchemy.check_alchemy_cu import CheckAlchemyCU
from ironfish.check_ironfish_rewards import CheckIronfishRewards
from ironfish.ironfish_quests import IronfishQuests
from massa.update_massa import UpdateMassa
from penumbra.update_penumbra import UpdatePenumbra


class Factory:

    def __init__(self, arg: str):
        self.instance: AbstractScript = None
        match arg:
            case "ironfish_quests":
                self.instance = IronfishQuests()
            case "check_ironfish_rewards":
                self.instance = CheckIronfishRewards()
            case "check_alchemy_cu":
                self.instance = CheckAlchemyCU()
            case "update_penumbra":
                self.instance = UpdatePenumbra()
            case "update_massa":
                self.instance = UpdateMassa()
            case _:
                help_message()
