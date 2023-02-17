from abc import ABC

from src.abstract_script import AbstractScript


class SetupForScripts(AbstractScript, ABC):

    def __init__(self, server):
        super().__init__(server)

    def install_python_3_10(self):
        self.server.logger.info("Check python version")
        result = self.server.run_command("python --version", expected_exit=True)
        if "Python 3.10" in result:
            self.server.logger.success("Python 3.10 is arleady installed.")
            return
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
        # curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

    def install_chrome(self):
        """
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i google-chrome-stable_current_amd64.deb
        rm -rf google-chrome-stable_current_amd64.deb
        apt install -f -y
        """

    def target_func(self, event, shared_list):
        self.setup_ports()
        self.install_python_3_10()
