import L from "leaflet";
import "leaflet.markercluster";
import { newReportMarkerIcon } from "../leaflet_icons";

const LeafletMapInteraction = {
  mounted() {
    this.handleEvent("enable_pin_mode", () => {
      this.map.on("click", this.onMapClick.bind(this));
      this.map.on("touch", this.onMapClick.bind(this));
    });
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

export default LeafletMapInteraction;
