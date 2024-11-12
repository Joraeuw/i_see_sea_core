const LocaleHook = {
  mounted() {
    const locale = localStorage.getItem("locale") || "en";

    this.pushEvent("set_locale", { locale: locale });

    this.handleEvent("update_locale", ({ locale }) => {
      localStorage.setItem("locale", locale);
      document.cookie = `locale=${locale}; path=/; max-age=31536000`;
      location.reload();
    });
  },
};

export default LocaleHook;
