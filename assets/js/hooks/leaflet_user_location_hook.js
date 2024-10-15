import L from "leaflet";
import "leaflet.markercluster";

import { userLocationMarkerIcon, newReportMarkerIcon } from "../leaflet_icons";

const LeafletUserLocation = {
  mounted() {
    this.map = window.map;
    this.hasDetectedUserLocation();
    this.addMarkerOnClick();
  },

  addMarkerOnClick() {
    this.handleEvent("enable_pin_mode", () => {
      // if (!this.hasDetectedUserLocation()) {
      // }

      this.map.on("click", this.onMapClick.bind(this));
      this.map.on("touch", this.onMapClick.bind(this));
    });
  },

  hasDetectedUserLocation() {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          L.marker([latitude, longitude], {
            icon: userLocationMarkerIcon,
          })
            .addTo(this.map)
            .bindPopup("You are here!");

          this.pushEvent("user_selected_location", { latitude, longitude });
          return true;
        },
        (error) => {
          return false;
        }
      );
    } else {
      return false;
    }
  },

  onMapClick(e) {
    const { lat, lng } = e.latlng;

    if (this.lastSelectedLocation) {
      this.map.removeLayer(this.lastSelectedLocation);
    }

    this.lastSelectedLocation = L.marker([lat, lng], {
      icon: newReportMarkerIcon,
    }).addTo(this.map);

    this.pushEventTo("#select-location-button", "location_selected", {
      lat,
      lng,
    });

    this.map.off("click");
    this.map.off("touch");
  },
};

export default LeafletUserLocation;
