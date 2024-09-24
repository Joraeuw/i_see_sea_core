window.openFullscreenModal = (imageSrc) => {
  console.log("hello");
  const fullscreen_modal = document.getElementById(
    "modal_fullscreen_image_slider"
  );
  const container = document.getElementById(
    "modal_fullscreen_image_slider_container"
  );
  fullscreen_modal.setAttribute("open", ""); // Open the modal

  // Optional: You could add functionality to display the selected image in the modal if you want
  const selectedImageDiv = `
    <div class="swiper-slide mt-3 z-40">
      <img src="${imageSrc}" alt="Large Picture" class="w-[500px] h-[500px] z-30"/>
       
    </div>
  `;

  container.innerHTML = selectedImageDiv;
};

const createImageSlider = (pictures) => {
  if (!pictures || pictures.length === 0)
    return `<img class="h-40" src="/images/no_image_provided.svg"/>`;

  const slides = pictures
    .filter((picture) => picture)
    .map(
      (picture, index) => `
      <div class="swiper-slide mt-3">
        <label for="modal_fullscreen_image_slider">
          
        </label>
        <!-- Modal Trigger -->
        
        <button onclick="window.openFullscreenModal('${picture}')">
        <img class="h-40 cursor-pointer" src="${picture}" alt="Picture"/>
        </button>
      
      </div>
      `
    )
    .join("");

  return `
    <div class="swiper-container">
      <div class="swiper-wrapper">
        ${slides}
      </div>
      <div class="swiper-pagination"></div>
      <div class="swiper-button-next"></div>
      <div class="swiper-button-prev"></div>
    </div>
  `;
};

function format_date(report_date) {
  const timestamp = report_date;
  const date = new Date(timestamp);

  const options = {
    year: "numeric",
    month: "long",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  };

  return (formattedDate = new Intl.DateTimeFormat("en-US", options).format(
    date
  ));
}
const jellyfishContent = ({
  name,
  comment,
  pictures,
  quantity,
  species,
  latitude,
  longitude,
  report_date,
}) => {
  const slider = createImageSlider(pictures);
  const formattedDate = format_date(report_date);
  return `
   <div class="flex flex-col items-center w-full h-full ">
    <p class="p_card_name p_map_cards s line-clamp-1"><b>${name}</b></p>
    ${slider}
    <div class="flex flex-col items-center justify-between w-full h-[210px]">
    <br><p class="p_card_map p_map_cards"><b>Quantity: </b> &nbsp;${quantity}</p>
    <p class="p_card_map p_map_cards"><b>Species: </b> &nbsp;${species}</p>
    <p class="p_card_map p_map_cards"><b>Latitude: </b> &nbsp;${latitude}</p>
    <p class="p_card_map p_map_cards"><b>Longitude: </b> &nbsp;${longitude}</p>
    <p class="p_card_map_comment line-clamp-2"><b>Comment: </b> &nbsp; ${comment}</p>
    <p class="w-full text-end mt-6">${formattedDate}</p>
    </div>
    </div>
  `;
};

const pollutionContent = ({
  name,
  comment,
  pictures,
  pollution_types,
  latitude,
  longitude,
  report_date,
}) => {
  const slider = createImageSlider(pictures);
  const plastic = pollution_types.includes("plastic");
  const oil = pollution_types.includes("oil");
  const biological = pollution_types.includes("biological");
  const formattedDate = format_date(report_date);

  return `
<div class="flex flex-col justify-around items-center w-full h-full ">

  <p class="p_card_name p_map_cards s"><b>${name}</b></p>
  ${slider}
  <div class="flex flex-col items-center justify-between w-full h-[210px] mt-3">
  <p class="p_card_map p_map_cards"><b>Oil: </b> &nbsp; ${oil ? "Yes" : "No"}</p>
  <p class="p_card_map p_map_cards"><b>Plastic: </b> &nbsp; ${plastic ? "Yes" : "No"}</p>
  <p class="p_card_map p_map_cards"><b>Biological: </b> &nbsp; ${biological ? "Yes" : "No"}</p>
  <p class="p_card_map p_map_cards"><b>Latitude: </b> &nbsp;${latitude}</p>
  <p class="p_card_map p_map_cards"><b>Longitude: </b> &nbsp;${longitude}</p>
  <p class="p_card_map_comment line-clamp-2"><b>Comment: </b> &nbsp; ${comment}</p>
  <p class="w-full text-end mt-6">${formattedDate}</p>
  </div>
</div>`;
};

const atypicalActivityContent = ({
  name,
  comment,
  storm_type_id,
  pictures,
  latitude,
  longitude,
  report_date,
}) => {
  const slider = createImageSlider(pictures);
  const formattedDate = format_date(report_date);
  return `
  <div class="flex flex-col justify-around items-center w-full h-full ">
   <p class="p_card_name p_map_cards s"><b>${name}</b></p>
  ${slider}
  <div class="flex flex-col items-center justify-between w-full h-[150px] mt-3">
  <p class="p_card_map p_map_cards"><b>Storm type: </b> &nbsp; ${storm_type_id}</p>
  <p class="p_card_map p_map_cards"><b>Latitude: </b> &nbsp;${latitude}</p>
  <p class="p_card_map p_map_cards"><b>Longitude: </b> &nbsp;${longitude}</p>
  <p class="p_card_map_comment line-clamp-2"><b>Comment: </b> &nbsp; ${comment}</p>
  <p class="w-full text-end mt-6">${formattedDate}</p>
  </div>
  </div>`;
};
const meteorologicalContent = ({
  name,
  comment,
  fog_type,
  wind_type,
  sea_swell_type,
  pictures,
  latitude,
  longitude,
  report_date,
}) => {
  const slider = createImageSlider(pictures);
  const formattedDate = format_date(report_date);
  return `
  <div class="flex flex-col justify-around items-center w-full h-full ">
 <p class="p_card_name p_map_cards s line-clamp-1"><b>${name}</b></p>
  ${slider}
 <div class="flex flex-col items-center justify-between w-full h-[210px] mt-3">
<p class="p_card_map p_map_cards"><b>Fog type: </b> &nbsp;${fog_type}</p>
<p class="p_card_map p_map_cards"><b>Wind type: </b> &nbsp;${wind_type}</p>
<p class="p_card_map p_map_cards"><b>Sea swell type: </b> &nbsp;${sea_swell_type}</p>
<p class="p_card_map p_map_cards"><b>Latitude: </b> &nbsp;${latitude}</p>
<p class="p_card_map p_map_cards"><b>Longitude: </b> &nbsp;${longitude}</p>
<p class="p_card_map_comment line-clamp-2"><b>Comment: </b> &nbsp; ${comment}</p>
<p class="w-full text-end mt-6">${formattedDate}</p>
</div>
    </div>
 `;
};
const otherContent = ({
  name,
  comment,
  pictres,
  latitude,
  longitude,
  report_date,
}) => {
  const slider = createImageSlider(pictres);
  const formattedDate = format_date(report_date);
  return `
  <div class="flex flex-col justify-around items-center w-full h-full ">
  <p class="p_card_name p_map_cards s line-clamp-1"><b>${name}</b></p>
  ${slider}
  <div class="flex flex-col items-center justify-between w-full h-[150px] mt-3">
  <p class="p_card_map p_map_cards"><b>Latitude: </b> &nbsp;${latitude}</p>
<p class="p_card_map p_map_cards"><b>Longitude: </b> &nbsp;${longitude}</p>
 <p class="p_card_map_comment line-clamp-2"><b>Comment: </b> &nbsp; ${comment}</p>
 <p class="w-full text-end mt-6">${formattedDate}</p>
 </div>
    </div>
  `;
};

const getMarkerContent = (report) => {
  switch (report.report_type) {
    case "jellyfish":
      return jellyfishContent(report);
    case "pollution":
      return pollutionContent(report);
    case "atypical_activity":
      return atypicalActivityContent(report);
    case "meteorological":
      return meteorologicalContent(report);
    case "other":
      return otherContent(report);
    default:
      return "";
  }
};

export { getMarkerContent };