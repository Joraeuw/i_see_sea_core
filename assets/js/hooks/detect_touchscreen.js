let DetectTouchSupport = {
  mounted() {
    console.log("DetectTouchSupport hook mounted");

    // Check if the device supports touch events
    const supportsTouch =
      "ontouchstart" in window || navigator.maxTouchPoints > 0;

    // Listen for when the LiveView WebSocket is connected
    window.liveSocket.onSocket(() => {
      console.log("LiveView WebSocket connected");
      this.pushEventTo(this.el, "set_touch_support", {
        supports_touch: supportsTouch,
      });
      console.log("Event sent with supports_touch:", supportsTouch);
    });
  },
};

export default DetectTouchSupport;
