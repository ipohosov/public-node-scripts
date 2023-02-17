import sys

from dotenv import load_dotenv

from src.factory import Factory
from src.helper import help_message


if __name__ == "__main__":

    if len(sys.argv) > 1:
        load_dotenv()
        factory = Factory(sys.argv[1])
    else:
        help_message()

    factory.instance.start_action()
