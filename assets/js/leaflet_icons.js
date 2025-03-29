import L from "leaflet";

const iconBuilder = (original_width, original_height, w, fun) => {
  const aspect_ratio = original_width / original_height;
  const h = w / aspect_ratio;
  const iconSize_w = Math.round(w, 2);
  const iconSize_h = Math.round(h, 2);
  const iconAnchor_w = Math.round(iconSize_w / 2, 2);
  const iconAnchor_h = iconSize_h;

  return fun({ iconSize_w, iconSize_h, iconAnchor_w, iconAnchor_h });
};

const markerIconByReportTypeHighOrder =
  ({ iconSize_w, iconSize_h, iconAnchor_w, iconAnchor_h }) =>
  (report_type) =>
    L.icon({
      iconUrl: `/images/marker-icons/${report_type}_report.png`,
      iconSize: [iconSize_w, iconSize_h],
      iconAnchor: [iconAnchor_w, iconAnchor_h],
      popupAnchor: [0, -iconSize_h],
    });

const userLocationMarkerIconHighOrder = ({
  iconSize_w,
  iconSize_h,
  iconAnchor_w,
  iconAnchor_h,
}) =>
  L.icon({
    iconUrl: `/images/marker-icons/user_location_icon.png`,

    iconSize: [iconSize_w, iconSize_h],
    iconAnchor: [iconAnchor_w, iconAnchor_h],
    popupAnchor: [0, -iconSize_h],
  });

const newReportMarkerIconHighOrder = ({
  iconSize_w,
  iconSize_h,
  iconAnchor_w,
  iconAnchor_h,
}) =>
  L.icon({
    iconUrl: `/images/marker-icons/new_report_location_icon.png`,

    iconSize: [iconSize_w, iconSize_h],
    iconAnchor: [iconAnchor_w, iconAnchor_h],
    popupAnchor: [0, -iconSize_h],
  });

const markerIconByReportType = iconBuilder(
  1322,
  1945,
  29,
  markerIconByReportTypeHighOrder
);

const userLocationMarkerIcon = L.divIcon({
  className: 'user-location-marker',
  html: `
    <div class="user-location-marker-inner">
      <div class="user-location-dot"></div>
      <div class="user-location-pulse"></div>
    </div>
  `,
  iconSize: [24, 24],
  iconAnchor: [12, 12]
});

const newReportMarkerIcon = iconBuilder(
  3118,
  4504,
  24,
  newReportMarkerIconHighOrder
);

export { markerIconByReportType, userLocationMarkerIcon, newReportMarkerIcon };
