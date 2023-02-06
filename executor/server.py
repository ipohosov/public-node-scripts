import re

from fabric import Connection
from invoke import UnexpectedExit

from executor.logger import Logger


class Server:

    def __init__(self, connection_string):
        data = connection_string.split(' ')
        if len(data) != 4:
            raise ValueError("The format of data in .env.servers file is incorrect. "
                             "Should be - 'host_name username host:port password'.")
        self.server_name = data[0]
        self.connection = Connection(host=f'{data[1]}@{data[2]}', connect_kwargs={'password': data[3]})
        self.logger = Logger(self.server_name)

    def run_command(self, command, hide, pty):
        try:
            return self.connection.run(command, hide=hide, pty=pty)
        except UnexpectedExit as ex:
            output = ex.result
            command = f"Failed command: {output.command}.\n"
            stderr = f"Error output: {output.stderr}.\n" if output.stderr else ''
            stdout = " ".join(output.stdout.split())
            stdout = re.sub(r'\x1b\[\d+m[›]*', '', stdout)

            self.logger.error(f"{command}{stderr}Console output: {stdout}.")
            raise SystemExit
