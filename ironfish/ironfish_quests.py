from abc import ABC
from executor.abstract_script import AbstractScript


class IronfishQuests(AbstractScript, ABC):

    def __init__(self, server):
        super().__init__(server)

    def target_func(self, *args):
        pass
