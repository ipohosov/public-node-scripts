from selenium import webdriver
from selenium.webdriver.chrome.options import Options

from decorators import singleton


@singleton
class BaseSelenium:

    def __init__(self):
        options = Options()
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.headless = True
        self.driver = webdriver.Chrome(options=options)

    def close(self):
        self.driver.close()
