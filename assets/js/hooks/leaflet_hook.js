import L from "leaflet";
import "leaflet.markercluster";

import {
  markerIconByReportType,
  userLocationMarkerIcon,
} from "../leaflet_icons";
import { getMarkerContent } from "../leaflet_markers";

const LeafletMap = {
  mounted() {
    const northEast = L.latLng(43.29818825605375, 27.59902954101563);
    const southWest = L.latLng(43.128774079271025, 28.251514434814457);
    const bounds = L.latLngBounds(southWest, northEast);

    this.map = L.map("map", {
      zoomControl: false,
      zoom: 13,
      // minZoom: 10,
      maxZoom: 18,
      // maxBounds: bounds,
    }).setView([43.2041, 27.8788]);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(this.map);

    this.markerClusterGroup = L.markerClusterGroup();
    this.map.addLayer(this.markerClusterGroup);

    this.markers = {};

    const initialMarkers = JSON.parse(this.el.dataset.reports);

    this.initialRender(initialMarkers);

    this.handleEvent("add_marker", (marker) => {
      this.addMarker(marker);
    });

    this.handleEvent("delete_marker", (marker) => {
      this.deleteMarker(marker.report_id);
    });

    this.detectUserLocation();

    setTimeout(() => {
      this.map.invalidateSize();
    }, 100);
  },

  addMarker(markerData) {
    const { report_id, report_type, latitude, longitude, name, comment } =
      markerData;
    if (!this.markers[report_id]) {
      const marker = L.marker([latitude, longitude], {
        icon: markerIconByReportType(report_type),
      }).bindPopup(getMarkerContent(markerData));
      this.markerClusterGroup.addLayer(marker);
      this.markers[report_id] = marker;
    }
  },

  deleteMarker(report_id) {
    if (this.markers[report_id]) {
      this.markerClusterGroup.removeLayer(this.markers[report_id]);
      delete this.markers[report_id];
    }
  },

  async initialRender(initialMarkers) {
    console.log("initialMarkers", initialMarkers);
    initialMarkers.forEach((markerData) => {
      const { report_id, report_type, latitude, longitude } = markerData;
      const marker = L.marker([latitude, longitude], {
        icon: markerIconByReportType(report_type),
      }).bindPopup(getMarkerContent(markerData));
      this.markerClusterGroup.addLayer(marker);
      this.markers[report_id] = marker;
    });
  },

  detectUserLocation() {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          L.marker([latitude, longitude], {
            icon: userLocationMarkerIcon,
          }).addTo(this.map);

          this.pushEvent("user_selected_location", { latitude, longitude });
        },
        (error) => {
          console.error("Geolocation error: ", error);
          this.enableManualLocationSelection();
        }
      );
    } else {
      this.enableManualLocationSelection();
    }
  },

  enableManualLocationSelection() {
    this.map.on("click", (e) => {
      const { lat, lng } = e.latlng;
      L.marker([lat, lng], { icon: userLocationMarkerIcon })
        .addTo(this.map)
        .bindPopup("You selected this location.")
        .openPopup();

      // Optionally send the selected location to Phoenix LiveView
      this.pushEvent("user_selected_location", {
        latitude: lat,
        longitude: lng,
      });
    });
  },
};

export default LeafletMap;
