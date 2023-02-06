class Executor:

    def __init__(self):
        self.servers = self._get_servers_data()

    def _get_servers_data(self):
        with open('./.env.servers', 'r') as file:
            users_list = [line.strip() for line in file]
        if users_list:
            return users_list
        else:
            raise FileNotFoundError(".env.servers file was not found or it's empty.")
