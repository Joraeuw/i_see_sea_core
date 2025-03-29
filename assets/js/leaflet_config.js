export const standardPopupOptions = {
  maxWidth: 280,
  minWidth: 120,
  maxHeight: 400,
  className: 'custom-popup responsive-popup',
  closeButton: false,
  autoPan: true,
  autoPanPadding: [20, 65],
  offset: [0, 5],
  keepInView: true,
  autoPanSpeed: 10,
};

export const mapOptions = {
  zoomControl: false,
  attributionControl: true,
};

export const clusterOptions = {
  spiderfyOnMaxZoom: true,
  zoomToBoundsOnClick: true,
  singleMarkerMode: false,
};

export const tileLayerOptions = {
  attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap contributors</a>',
}; 