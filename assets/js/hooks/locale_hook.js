const LocaleHook = {
  mounted() {
    const locale = localStorage.getItem("preferred_locale");

    if (locale) {
      this.pushEvent("set_locale", { locale: locale });
    }

    this.handleEvent("update_locale", ({ locale }) => {
      localStorage.setItem("preferred_locale", locale);
    });
  },
};

export default LocaleHook;
