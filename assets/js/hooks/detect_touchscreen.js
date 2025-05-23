let DetectTouchSupport = {
  mounted() {
    const supportsTouch =
      "ontouchstart" in window || navigator.maxTouchPoints > 0;

    // Listen for when the LiveView WebSocket is connected
    window.liveSocket.onSocket(() => {
      this.pushEventTo(this.el, "set_touch_support", {
        supports_touch: supportsTouch,
      });
    });
  },
};

export default DetectTouchSupport;
