import L from "leaflet";
import "leaflet.markercluster";

import { markerIconByReportType } from "../leaflet_icons";
import { getMarkerContent } from "../leaflet_markers";

const LeafletMap = {
  mounted() {
    this.map = L.map("map").setView([42, 42], 13);

    L.tileLayer(
      "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
      {
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      }
    ).addTo(this.map);

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
};

export default LeafletMap;
