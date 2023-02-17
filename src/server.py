import re

from fabric import Connection
from invoke import UnexpectedExit

from src.logger import Logger


class Server:

    def __init__(self, connection_string):
        data = connection_string.split(' ')
        if len(data) != 4:
            raise ValueError("The format of data in .env.servers file is incorrect. "
                             "Should be - 'host_name username host:port password'.")
        self.server_name = data[0]
        self.connection = Connection(host=f'{data[1]}@{data[2]}', connect_kwargs={'password': data[3]})
        self.logger = Logger(self.server_name)

    def run_command(self, command, hide=True, pty=False, expected_exit=False):
        try:
            return self.connection.run(f"source $HOME/.profile && {command}", hide=hide, pty=pty).stdout.strip()
        except UnexpectedExit as ex:
            output = ex.result
            aggregated_err_ouput = output.stderr.strip() if output.stderr else ''
            stdout = re.sub(r'\x1b\[\d+m›*', '', " ".join(output.stdout.split()))
            aggregated_stdout = stdout.replace("\n", "") if stdout else ''
            agg_command = f"Command: {output.command}.".strip()
            agg_err = f"Error output: {aggregated_err_ouput}".strip('.')
            agg_output = f"Console output: {aggregated_stdout}." if aggregated_stdout else ''
            output_log = f"{agg_command}\n{agg_err}.\n{agg_output}"

            if expected_exit:
                self.logger.info(output_log)
                return aggregated_err_ouput
            else:
                self.logger.error(output_log)
                raise SystemExit

    def download_file(self, file_name, path_to_remote, path_to_local=".tmp/"):
        home_path = self.run_command("echo $HOME")
        path_to_remote = path_to_remote.replace("$HOME", home_path)
        remote_file = f"{path_to_remote}{file_name}"
        local_file = f"{path_to_local}{self.server_name}_{file_name}"
        self.connection.get(remote_file, local_file)
