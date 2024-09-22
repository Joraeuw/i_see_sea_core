import L from "leaflet";

const original_width = 1322;
const original_height = 1945;
const w = 26;

const aspect_ratio = original_width / original_height;
const h = w / aspect_ratio;
const iconSize_w = Math.round(w, 2);
const iconSize_h = Math.round(h, 2);
const iconAnchor_w = Math.round(iconSize_w / 2, 2);
const iconAnchor_h = iconSize_h;

const markerIconByReportType = (report_type) =>
  L.icon({
    iconUrl: `/images/marker-icons/${report_type}_report.png`,
    iconSize: [iconSize_w, iconSize_h],
    iconAnchor: [iconAnchor_w, iconAnchor_h],
    popupAnchor: [0, -iconSize_h],
  });

const userLocationMarkerIcon = L.icon({
  iconUrl: `/images/marker-icons/user_location_icon.png`,

  iconSize: [40, 40],
  iconAnchor: [40 / 2, 40],
  popupAnchor: [0, -37],
});

export { markerIconByReportType, userLocationMarkerIcon };
