from base_page import BasePage


class DiscordLoginPage(BasePage):

    def login(self, email, password):
        self.driver.get("https://discord.com/login")
        self.type_text("//input[@name='email']", email)
        self.type_text("//input[@name='password']", password)
        self.click("//button[@type='submit']")
