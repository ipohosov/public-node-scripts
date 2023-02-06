from abc import ABC, abstractmethod


class AbstractScript(ABC):

    def __init__(self, server):
        self.server = server

    @abstractmethod
    def target_func(self, event, shared_list):
        pass
