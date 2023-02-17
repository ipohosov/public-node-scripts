from abc import ABC

from src.abstract_script import AbstractScript


class ScriptsWithGit(AbstractScript, ABC):

    def __init__(self):
        super().__init__()
        self.git_repo = None
        self.project_folder = None
        self.version = None

    def source_git(self):
        if self.git_repo:

            res = self.server.run_command(f'DIR={self.project_folder}; [ -d "$DIR" ] && echo "True"',
                                          hide=True, pty=True)
            if "True" not in res:
                self.server.logger.info(f"Clone repo {self.git_repo}")
                self.server.run_command(f"git clone {self.git_repo}")
            if self.version:
                self.server.logger.info(f"Pull changes by tag {self.version} from {self.git_repo}")
                cmd = f"cd {self.project_folder} && git reset --hard && git fetch && git checkout {self.version}"
                self.server.run_command(cmd)
        else:
            raise ValueError("Git repository is not set in script.")
