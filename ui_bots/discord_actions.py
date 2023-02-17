import sys

from discord.login_page import DiscordLoginPage
from base_selenium import BaseSelenium
from discord.dm_list_page import DiscordDirectMessageListPage
from discord.dm_page import DiscordDirectMessagePage

if __name__ == "__main__":
    email = sys.argv[1]
    password = sys.argv[2]
    text = sys.argv[3]
    selen = BaseSelenium()
    driver = selen.driver
    login_page = DiscordLoginPage(driver)
    login_page.login(email, password)
    dm_list_page = DiscordDirectMessageListPage(driver)
    dm_list_page.open_dm_with_user_by_id("@MassaBot#4922")
    dm_page = DiscordDirectMessagePage(driver)
    dm_page.send_message(text)
    selen.close()
