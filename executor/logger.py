from datetime import datetime


class Logger:
    def __init__(self, log_prefix):
        self.log_prefix = log_prefix

    def error(self, text):
        print(f"{Styles.RED}[ {self.log_prefix} ][{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {text}")

    def success(self, text):
        print(f"{Styles.GREEN}[ {self.log_prefix} ][{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {text}")

    def info(self, text):
        print(f"{Styles.YELLOW}[ {self.log_prefix} ][{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {text}")

    def main_thread(self, text):
        print(f"{Styles.CYAN}[ {self.log_prefix} ][{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {text}")

    def extra1(self, text):
        print(f"{Styles.BLUE}[ {self.log_prefix} ][{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {text}")

    def extra2(self, text):
        print(f"{Styles.MAGENTA}[ {self.log_prefix} ][{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {text}")


class Styles:
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
