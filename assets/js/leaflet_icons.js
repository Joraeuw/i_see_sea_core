import L from "leaflet";

const markerIconByReportType = (report_type) =>
  L.icon({
    iconUrl: `/images/marker-icons/${report_type}.png`,

    iconSize: [31.5, 49], // size of the icon
    iconAnchor: [31.5 / 2, 49], // point of the icon which will correspond to marker's location
    popupAnchor: [0, -46], // point from which the popup should open relative to the iconAnchor
  });

export { markerIconByReportType };
