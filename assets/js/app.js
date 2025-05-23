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

Hooks.DetectClick = {
  mounted() {
    document.addEventListener("click", this.handleOutsideClick.bind(this));
  },

  destroyed() {
    document.removeEventListener("click", this.handleOutsideClick.bind(this));
  },

  handleOutsideClick(event) {
    const clickedElement = event.target;
    if (this.open && !this.el.contains(clickedElement)) {
      const elementId = clickedElement.id || "unknown";
      this.pushEvent("exit_dialog", { element_id: elementId });
    }
  },

  updated() {
    this.open = this.el.hasAttribute("data-is-open");
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

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js').then(() => {
    console.log('Service Worker Registered');
  });
}

let deferredPrompt;

window.addEventListener('beforeinstallprompt', (event) => {
  deferredPrompt = event;

  const installButton = document.getElementById('install-button');
  if (installButton) {
    installButton.addEventListener('click', () => {
      deferredPrompt.prompt();
      
      deferredPrompt.userChoice.then((choiceResult) => {
        if (choiceResult.outcome === 'accepted') {
          console.log('User accepted the install prompt');
        } else {
          console.log('User dismissed the install prompt');
        }
        deferredPrompt = null;
      });
    });
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const isIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent);
  const installButton = document.getElementById("install-button");
  const iosInstallModal = document.getElementById("ios-install-modal");

  if (isIOS) {
    installButton.addEventListener("click", () => {
      iosInstallModal.showModal()
    });
  }
  
  initFilterModal();
});

function initFilterModal() {
  const filterButtons = document.querySelectorAll("[onclick*='filter_modal.showModal()']");
  
  filterButtons.forEach(button => {
    const originalOnclick = button.getAttribute('onclick');
    button.removeAttribute('onclick');
    
    button.addEventListener('click', function(e) {
      const filterModal = document.getElementById("filter_modal");
      if (filterModal) {
        try {
          filterModal.showModal();
        } catch (error) {
          console.error("Error showing filter modal, trying alternative approach:", error);
          
          filterModal.setAttribute('open', '');
          filterModal.style.display = 'flex';
        }
      }
    });
  });
}

window.addEventListener('error', function(event) {
  console.error('Global error caught:', event.error || event.message);
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
