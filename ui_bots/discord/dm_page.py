from time import sleep
from selenium.webdriver.common.keys import Keys
from base_page import BasePage


class DiscordDirectMessagePage(BasePage):

    def send_message(self, message):
        self.type_text("//div[@role='textbox']", message)
        sleep(2)
        self.type_text("//div[@role='textbox']", Keys.ENTER)
