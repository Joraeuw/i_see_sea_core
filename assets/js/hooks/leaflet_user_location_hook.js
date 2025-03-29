import L from "leaflet";
import "leaflet.markercluster";

import { userLocationMarkerIcon, newReportMarkerIcon } from "../leaflet_icons";

const LeafletUserLocation = {
  mounted() {
    this.map = window.leafletMap;
    
    if (!this.map) {
      console.error("Map not found! User location will not be displayed.");
      return;
    }
    
    this.hasDetectedUserLocation();
    this.addMarkerOnClick();
  },

  addMarkerOnClick() {
    this.handleEvent("enable_pin_mode", () => {
      this.map.on("click", this.onMapClick.bind(this));
      this.map.on("touch", this.onMapClick.bind(this));
    });
  },

  hasDetectedUserLocation() {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          const pulsingMarker = L.marker([latitude, longitude], {
            icon: userLocationMarkerIcon,
            zIndexOffset: 1000
          }).addTo(this.map);
          
          const accuracyCircle = L.circle([latitude, longitude], {
            radius: 100,
            color: '#4A90E2',
            fillColor: '#4A90E2',
            fillOpacity: 0.2,
            weight: 1
          }).addTo(this.map);
          
          this.userLocationMarker = pulsingMarker;
          this.accuracyCircle = accuracyCircle;
          
          this.pushEvent("user_selected_location", { latitude, longitude });
          
          return true;
        },
        (error) => {
          console.error("Error getting user location:", error.message);
          return false;
        }
      );
    } else {
      console.warn("Geolocation not supported in this browser");
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
