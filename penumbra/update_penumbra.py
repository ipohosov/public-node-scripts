import os
from abc import ABC

from src.scripts_with_git import ScriptsWithGit


class UpdatePenumbra(ScriptsWithGit, ABC):

    def __init__(self):
        super().__init__()
        self.git_repo = "https://github.com/penumbra-zone/penumbra"
        self.version = os.getenv('PENUMBRA_VERSION')
        self.project_folder = "$HOME/penumbra/"

    def build_penumbra(self):
        self.server.logger.info("Build penumbra")
        command = f"cd {self.project_folder} && cargo update && cargo build --release --bin pcli"
        self.server.run_command(command)
        self.server.run_command("sudo rm -f /usr/bin/pcli")
        self.server.run_command("sudo cp /root/penumbra/target/release/pcli /usr/bin/pcli")

    def reset_wallet(self):
        self.server.logger.info("Reset wallet")
        command = f"cd {self.project_folder} && pcli view reset"
        self.server.run_command(command)

    def get_balance(self):
        self.server.logger.info("Get Penumbra wallet balance")
        res = self.server.run_command("pcli view balance").split("Amount")[1]
        if res:
            return res
        else:
            return "There are no assets on your wallet. Please make a faucet in discord." \
                   f"Your wallet address:\n{self.get_address()}"

    def get_address(self):
        result = self.server.run_command("pcli view address 0")
        return f'penumbra{result.split("penumbra")[1]}'

    def target_func(self, event, shared_list):
        self.server.logger.info(f"Start updating penumbra to {self.version} version")
        self.setup_rust()
        self.source_git()
        self.build_penumbra()
        self.reset_wallet()
        balance = self.get_balance()
        if "There are" in balance:
            self.server.logger.warning(f"{balance}")
        else:
            self.server.logger.success(f"Penumbra balance: {balance}")
