const LocaleHook = {
  mounted() {
    const locale = localStorage.getItem("preferred_locale");

    this.handleEvent("get_locale", ({ locale }) => {
      this.pushEvent("set_locale", { locale: locale });
    });

    this.handleEvent("update_locale", ({ locale }) => {
      localStorage.setItem("preferred_locale", locale);
    });
  },
};

export default LocaleHook;
