from abc import ABC, abstractmethod
from multiprocessing import Process, Event, Manager

from src.helper import read_file
from src.server import Server


class AbstractScript(ABC):

    def __init__(self):
        self.server = None
        self.version = None

    @abstractmethod
    def target_func(self, event, shared_list):
        pass

    def setup_ports(self):
        self.server.logger.info("Setup ports")
        command = "curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null"
        self.server.run_command(command)

    def setup_rust(self):
        self.server.logger.info("Install rust")
        command = "curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null"
        self.server.run_command(command)
        self.server.run_command("source ~/.cargo/env && rustup update && rustup default nightly && sleep 1")

    def start_action(self):

        event = Event()
        shared_list = Manager().list()
        threads = []
        servers = [Server(server_string) for server_string in read_file('./.env.servers')]

        for server in servers:
            self.server = server
            thread = Process(target=self.target_func, name=self.server.server_name, args=(event, shared_list))
            thread.start()
            threads.append(thread)

        for thread in threads:
            thread.join()
