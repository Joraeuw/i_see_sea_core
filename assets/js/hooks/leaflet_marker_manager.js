import L, { marker } from "leaflet";
import "leaflet.markercluster";

import { markerIconByReportType } from "../leaflet_icons";
import { getMarkerContent } from "../leaflet_markers";
import { standardPopupOptions, clusterOptions } from "../leaflet_config";

const LeafletMarkerManager = {
  mounted() {
    this.markerClusterGroup = L.markerClusterGroup(clusterOptions);
    this.map = window.leafletMap || this.el.map;
    this.map.addLayer(this.markerClusterGroup);
    this.markers = {};

    const initialMarkers = JSON.parse(this.el.dataset.reports);
    this.renderMarkers(initialMarkers);

    this.handleEvent("add_marker", (marker) => {
      this.addMarker(marker);
    });

    this.handleEvent("delete_marker", (marker) => {
      this.deleteMarker(marker.report_id);
    });

    this.handleEvent("filters_updated", (params) => {
      const { reports } = params;
      this.renderMarkers(reports);
    });
  },

  addMarker(markerData) {
    const { report_id, report_type, latitude, longitude } = markerData;
    if (!this.markers[report_id]) {
      const marker = L.marker([latitude, longitude], {
        icon: markerIconByReportType(report_type),
      }).bindPopup(getMarkerContent(markerData), standardPopupOptions);
      
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

  renderMarkers(markers) {
    this.clearMarkers();
    markers.forEach((markerData) => {
      this.addMarker(markerData);
    });
  },

  clearMarkers() {
    if (this.markerClusterGroup) {
      this.markerClusterGroup.clearLayers();
    }
    this.markers = {};
  },
};

export default LeafletMarkerManager;
