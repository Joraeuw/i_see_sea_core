import L, { marker } from "leaflet";
import "leaflet.markercluster";

import {
  markerIconByReportType,
  userLocationMarkerIcon,
  newReportMarkerIcon,
} from "../leaflet_icons";
import { getMarkerContent } from "../leaflet_markers";
import { 
  standardPopupOptions, 
  clusterOptions, 
  mapOptions, 
  tileLayerOptions
} from "../leaflet_config";

const LeafletMap = {
  mounted() {
    this.map = L.map(this.el, mapOptions).setView([43.2041, 27.8788], 13);
    window.leafletMap = this.map;
    
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", tileLayerOptions)
      .addTo(this.map);

    this.markerClusterGroup = L.markerClusterGroup(clusterOptions);
    this.map.addLayer(this.markerClusterGroup);

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

    this.handleEvent("report_created", () =>
      this.map.removeLayer(this.lastSelectedLocation)
    );

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

  async renderMarkers(markers) {
    this.clearMarkers();
    markers.forEach((markerData) => {
      const { report_id, report_type, latitude, longitude } = markerData;
      const marker = L.marker([latitude, longitude], {
        icon: markerIconByReportType(report_type),
      }).bindPopup(getMarkerContent(markerData), standardPopupOptions);
      
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
