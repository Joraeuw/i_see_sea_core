import L, { marker } from "leaflet";
import "leaflet.markercluster";

import {
  markerIconByReportType,
  userLocationMarkerIcon,
  newReportMarkerIcon,
} from "../leaflet_icons";
import { getMarkerContent } from "../leaflet_markers";

const LeafletMap = {
  mounted() {
    const northEast = L.latLng(43.29818825605375, 27.59902954101563);
    const southWest = L.latLng(43.128774079271025, 28.251514434814457);
    const bounds = L.latLngBounds(southWest, northEast);

    window.map = L.map("map", {
      zoomControl: false,
      zoom: 13,
      // minZoom: 10,
      maxZoom: 18,
      // maxBounds: bounds,
    }).setView([43.2041, 27.8788]);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution:
        '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(window.map);

    this.markerClusterGroup = L.markerClusterGroup();
    window.map.addLayer(this.markerClusterGroup);

    this.markers = {};

    const initialMarkers = JSON.parse(this.el.dataset.reports);

    this.renderMarkers(initialMarkers);

    this.handleEvent("add_marker", (marker) => {
      this.addMarker(marker);
    });
    this.trackingNewMarkers = true;

    this.handleEvent("delete_marker", (marker) => {
      this.deleteMarker(marker.report_id);
    });

    this.handleEvent("filters_updated", (params) => {
      console.log(params);

      let { reports, stop_live_tracker } = params;
      stop_live_tracker = false;
      if (stop_live_tracker) {
        this.removeEventListener("add_marker", this.addMarker);
        this.trackingNewMarkers = false;
      } else {
        if (!this.trackingNewMarkers) {
          this.handleEvent("add_marker", this.addMarker);
          this.trackingNewMarkers = true;
        }
      }

      this.renderMarkers(reports);
    });

    this.handleEvent(
      "report_created",
      () => true
      // window.map.removeLayer(this.lastSelectedLocation)
    );

    setTimeout(() => {
      window.map.invalidateSize();
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

  async renderMarkers(markers) {
    this.clearMarkers();
    console.log(markers);
    markers.forEach((markerData) => {
      const { report_id, report_type, latitude, longitude } = markerData;
      const marker = L.marker([latitude, longitude], {
        icon: markerIconByReportType(report_type),
      }).bindPopup(getMarkerContent(markerData));
      this.markerClusterGroup.addLayer(marker);
      this.markers[report_id] = marker;
    });
  },

  clearMarkers() {
    if (this.markerClusterGroup) {
      this.markerClusterGroup.clearLayers();
    }
    this.markers = {};
  },
};

export default LeafletMap;
