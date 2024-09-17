// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

import topbar from "../vendor/topbar";
import Hooks from "./hooks";

// // Select all the buttons
// const buttons = document.querySelectorAll(".create_report_button");

// buttons.forEach((button) => {
//   button.addEventListener("click", (e) => {
//     console.log("CLICKED");
//     // Get the index of the clicked button
//     const index = e.currentTarget.getAttribute("data-index");

//     // Toggle the corresponding expand panel
//     const expandPanel = document.getElementById(`expand-panel-${index}`);

//     if (expandPanel.classList.contains("hidden")) {
//       expandPanel.classList.remove("hidden");
//       expandPanel.classList.add("block");
//     } else {
//       expandPanel.classList.add("hidden");
//       expandPanel.classList.remove("block");
//     }
//   });
// });

Hooks.DetectClick = {
  mounted() {
    document.addEventListener("click", this.handleOutsideClick.bind(this));
  },

  destroyed() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
  },

  handleOutsideClick(event) {
    const clickedElement = event.target;
    if (!this.el.contains(clickedElement)) {
      const elementId = clickedElement.id || "unknown";
      this.pushEvent("stop_creating_report", { element_id: elementId });
    }
  },
};

function isTouchDevice() {
  return "ontouchstart" in window || navigator.maxTouchPoints > 0;
}

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken, supports_touch: isTouchDevice() },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
liveSocket.enableDebug();
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
