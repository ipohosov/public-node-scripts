import sys
from multiprocessing import Process, Manager, Event
from executor.executor import Executor
from executor.factory import Factory
from executor.helper import Helper
from executor.server import Server

if __name__ == "__main__":

    executor = Executor()
    manager = Manager()
    event = Event()
    shared_list = manager.list()
    threads = []
    servers = [Server(server_string) for server_string in executor.servers]

    for server in servers:
        if len(sys.argv) > 1:
            factory = Factory(sys.argv[1], server)
        else:
            factory = Factory("help")
        if isinstance(factory, Helper):
            Helper().some_message()
        thread = Process(target=factory.instance.target_func, name=server.server_name, args=(event, shared_list))
        thread.start()
        threads.append(thread)

    for thread in threads:
        thread.join()
