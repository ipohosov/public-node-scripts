from base_page import BasePage


class DiscordDirectMessageListPage(BasePage):

    def open_dm_with_user_by_id(self, user_id):
        self.click("//button[contains(@class, 'searchBarComponent')]")
        self.type_text("//div[contains(@class, 'quickswitcher')]/input", f"{user_id}")
        self.click(f"//div[contains(@class, 'quickswitcher')]//span[text()='{user_id.replace('@','')}']")
