import DetectTouchSupport from "./hooks/detect_touchscreen";
import LeafletMap from "./hooks/leaflet_hook";
import DaterangeHover from "./daterange_hover";
import LocaleHook from "./hooks/locale_hook";
import LeafletUserLocation from "./hooks/leaflet_user_location_hook";
import DragAndDropHook from "./hooks/drag_drop";

export default Hooks = {
  LeafletMap,
  DetectTouchSupport,
  DaterangeHover,
  LocaleHook,
  DragAndDropHook,
  LeafletUserLocationHook: LeafletUserLocation,
};
