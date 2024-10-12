const LocaleHook = {
  mounted() {
    const locale = localStorage.getItem("locale") || "en";

    this.pushEvent("set_locale", { locale: locale });

    // Update localStorage and cookies when instructed by the server
    this.handleEvent("update_locale", ({ locale }) => {
      localStorage.setItem("locale", locale);
      document.cookie = `locale=${locale}; path=/; max-age=31536000`;
    });
  },
};

export default LocaleHook;
