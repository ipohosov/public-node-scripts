import os
from abc import ABC
from time import sleep

from src.abstract_script import AbstractScript
from src.enums.node_statuses import NodeStatus


class UpdateMassa(AbstractScript, ABC):

    def __init__(self):
        super().__init__()
        self.version = os.getenv('MASSA_VERSION')
        self.massa_client_cmd = "cd $HOME/massa/massa-client && ./massa-client --pwd {}"

    def backup_massa(self):
        self.server.logger.info("Create backup for Massa")
        self.server.run_command("mkdir -p $HOME/massa_backup")
        self.server.run_command("cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa_backup/")
        self.server.run_command("cp $HOME/massa/massa-client/wallet.dat $HOME/massa_backup/")

    def delete_massa(self):
        self.server.logger.info("Delete Massa")
        self.server.run_command("sudo systemctl stop massa")
        self.server.run_command("rm -rf $HOME/massa/")

    def set_env_variables(self):
        self.server.logger.info("Get environment variables")
        self.server.run_command("source $HOME/.cargo/env")

    def download_binary(self):
        self.server.logger.info("Download binary file")
        try:
            command = f"wget https://github.com/massalabs/massa/releases/download/" \
                      f"{self.version}/massa_{self.version}_release_linux.tar.gz"
            self.server.run_command(command)
            self.server.run_command(f"tar zxvf massa_{self.version}_release_linux.tar.gz -C $HOME/")
        finally:
            self.server.run_command(f"rm -rf $HOME/massa_TEST.*")

    def update_config_file(self):
        config_path = "$HOME/massa/massa-node/base_config/"
        config_name = "config.toml"

        self.server.logger.info("Download config.toml file to local PC for updates")
        self.server.download_file(config_name, config_path)

        self.server.logger.info("Update routable_ip, retry_delay and botstrap list")

        self.server.logger.info("Remove bootstrap_whitelist.config")
        self.server.run_command("rm -rf $HOME/massa/massa-node/base_config/bootstrap_whitelist.json")

    def restore_massa(self):
        self.server.logger.info("Restore Massa")
        self.server.run_command("cp $HOME/massa_backup/wallet.dat $HOME/massa/massa-client/wallet.dat")
        self.server.run_command("cp $HOME/massa_backup/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key")

    def start_massa(self):
        self.server.logger.info("Start Massa")
        self.server.run_command("sudo systemctl start massa")

    def get_massa_pass(self):
        self.server.logger.info("Get massa password")
        return self.server.run_command("echo $massa_pass")

    def get_address(self, massa_pwd):
        self.server.logger.info("Get wallet address")
        command = f"{self.massa_client_cmd.format(massa_pwd)} wallet_info | grep Address | awk '{{ print $2 }}'"
        return self.server.run_command(command)

    def get_wallet_info(self, massa_pwd):
        self.server.logger.info("Get wallet info")
        return self.server.run_command(f"{self.massa_client_cmd.format(massa_pwd)} wallet_info")

    def get_massa_last_n_logs(self, n=25):
        self.server.logger.info(f"Get massa latest {n} logs")
        return self.server.run_command(f"journalctl -u massa -n {n} --no-pager").replace("n", "")

    def get_massa_status(self):
        status: NodeStatus = None
        self.server.logger.info("Get massa status by systemctl")
        output = self.server.run_command(f"systemctl status massa --no-pager", expected_exit=True)
        updated_output = output.replace("\n", " ")
        match updated_output:
            case x if "Unit massa.service could not be found" in x:
                status = NodeStatus.ABSENT
            case x if "Active: inactive (dead)" in x:
                status = NodeStatus.INACTIVE
            case x if "Active: active (running)" in x:
                status = NodeStatus.ACTIVE
        if status == NodeStatus.ACTIVE:
            if not any(map(output.replace("\n", " ").__contains__, ["final_state hash at slot",
                                                                    "Start bootstrapping from"])):
                status = NodeStatus.FREEZED

        return status

    def get_massa_version(self, massa_pwd):
        self.server.logger.info("Get massa version")
        command = f"{self.massa_client_cmd.format(massa_pwd)} get_status | grep Version | awk '{{ print $2 }}'"
        return self.server.run_command(command)

    def wait_till_bootstraped(self):
        logs = self.get_massa_last_n_logs()
        while "final_state hash at slot" in logs:
            sleep(15)
            logs = self.get_massa_last_n_logs()
        self.server.logger.info(f"The node is bootstrapped successfully")

    def wait_tokens(self, massa_pwd):
        tokens = int(self.get_wallet_info(massa_pwd).split("\n\t")[1].split("candidate=")[1])
        while tokens < 100:
            sleep(5)
            tokens = int(self.get_wallet_info(massa_pwd).split("\n\t")[1].split("candidate=")[1])
        self.server.logger.info(f"The tokens appear in your wallet. Balance: {tokens}.")

    def buy_rolls(self, massa_pwd, massa_address):
        self.server.logger.info(f"Buy 1 roll for address {massa_address}")
        self.server.run_command(f"{self.massa_client_cmd.format(massa_pwd)} buy_rolls {massa_address} 1 0")

    def start_staking(self, massa_pwd, massa_address):
        self.server.logger.info(f"Start staking for address {massa_address}")
        self.server.run_command(f"{self.massa_client_cmd.format(massa_pwd)} node_staking {massa_address}")

    def faucet_tokens(self, massa_address):
        pass

    def register_node(self):
        pass

    def target_func(self, event, shared_list):
        self.server.logger.info("Check python version")
        result = self.server.run_command("python --version",expected_exit=True)
        if "Python 3.10" in result:
            self.server.logger.success("Python 3.10 is arleady installed.")
        else:
            self.server.logger.info("Install python 3.10")
            self.server.run_command("sudo apt update")
            self.server.run_command("sudo apt install software-properties-common -y")
            self.server.run_command("sudo add-apt-repository ppa:deadsnakes/ppa -y")
            self.server.run_command("sudo apt update")
            self.server.run_command("sudo apt install python3.10 -y")
            command = "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1"
            self.server.run_command(command)
            result = self.server.run_command("python --version")
            self.server.logger.success(f"{result}")
        self.server.logger.info(f"Start updating massa to {self.version} version")
        massa_status = self.get_massa_status()
        if massa_status == NodeStatus.ABSENT:
            self.server.logger.error(f"Massa is not installed. You need to install it at first.")
            raise SystemExit
        massa_pwd = self.get_massa_pass()
        massa_address = self.get_address(massa_pwd)
        massa_version = self.get_massa_verion(massa_pwd)
        if massa_version in self.version:
            self.server.logger.success("Your node has actual version. Don't need to update it. "
                                       f"The status of node is{str(massa_status).replace('NodeStatus.', ' ')}. "
                                       "If it's Freezed you need to restart it. Command 'systemctl restart massa'.")
            raise SystemExit

        self.set_env_variables()
        self.backup_massa()
        self.download_binary()
        self.update_config_file()
        self.restore_massa()
        self.start_massa()
        self.wait_till_bootstraped()
        self.faucet_tokens(massa_address)
        self.wait_tokens(massa_pwd)
        self.start_staking(massa_pwd, massa_address)
        self.buy_rolls(massa_pwd, massa_address)
        self.register_node()
        self.server.logger.success(f"Massa version {massa_version}")
