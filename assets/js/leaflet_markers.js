import Swiper from "swiper/bundle";
import "swiper/css/bundle";

window.openFullscreenModal = (pictures, startingIndex = 0) => {
  const fullscreen_modal = document.getElementById(
    "modal_fullscreen_image_slider"
  );
  const container = document.getElementById(
    "modal_fullscreen_image_slider_container"
  );

  // Clear previous slides
  container.innerHTML = "";

  // Create slides for each picture
  const slides = pictures
    .map(
      (picture) => `
    <div class="swiper-slide">
      <img src="${picture}" alt="Large Picture" class="w-full h-auto"/>
    </div>
  `
    )
    .join("");

  container.innerHTML = slides;

  // Destroy existing Swiper instance if it exists
  if (window.fullscreenSwiper) {
    window.fullscreenSwiper.destroy();
    window.fullscreenSwiper = null;
  }

  // Initialize Swiper with navigation and pagination
  window.fullscreenSwiper = new Swiper(".modal .swiper-container", {
    initialSlide: startingIndex,
    navigation: {
      nextEl: ".modal .swiper-button-next",
      prevEl: ".modal .swiper-button-prev",
    },
    pagination: {
      el: ".modal .swiper-pagination",
      clickable: true,
    },
  });

  fullscreen_modal.classList.add("modal-open");

  // Close modal when clicking outside
  const closeModalOnClickOutside = function (event) {
    const modalBox = fullscreen_modal.querySelector(".modal-box");
    if (!modalBox.contains(event.target)) {
      closeFullscreenModal();
      fullscreen_modal.removeEventListener("click", closeModalOnClickOutside);
    }
  };

  fullscreen_modal.addEventListener("click", closeModalOnClickOutside);
};

window.closeFullscreenModal = () => {
  const fullscreen_modal = document.getElementById(
    "modal_fullscreen_image_slider"
  );
  fullscreen_modal.classList.remove("modal-open");

  // Destroy Swiper instance to clean up
  if (window.fullscreenSwiper) {
    window.fullscreenSwiper.destroy(true, true);
    window.fullscreenSwiper = null;
  }
};

const createImageSlider = (pictures) => {
  if (!pictures || pictures.length === 0)
    return `<img class="h-40" src="/images/no_image_provided.svg"/>`;

  // Display only the first image
  const firstPicture = pictures[0];

  // Use data attributes to pass the pictures array
  return `
    <div class="image-thumbnail">
      <button class="open-modal-button" data-pictures='${encodeURIComponent(JSON.stringify(pictures))}' data-index='0'>
        <img class="h-40 cursor-pointer" src="${firstPicture}" alt="Picture"/>
      </button>
    </div>
  `;
};

document.addEventListener("click", function (event) {
  const button = event.target.closest(".open-modal-button");
  if (button) {
    const picturesData = decodeURIComponent(
      button.getAttribute("data-pictures")
    );
    const pictures = JSON.parse(picturesData);
    const index = parseInt(button.getAttribute("data-index"), 10);

    window.openFullscreenModal(pictures, index);
  }
});

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
  id,
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
  const locale = localStorage.getItem("locale") || "en";

  return `
  <div class="flex flex-col items-center w-full h-full" id="report-id-${id}">
    <p class="p_card_name p_map_cards s line-clamp-1"><b>${name}</b></p>
    ${slider}
    <div class="flex flex-col items-center justify-between w-full h-[210px]">
    <br><p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Количество: " : "Quantity: "}</b> &nbsp;${quantity}</p>
    <p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Вид: " : "Species: "}</b> &nbsp;${species}</p>
    <p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Гео. ш.: " : "Latitude: "}</b> &nbsp;${latitude}</p>
    <p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Гео. д.: " : "Longitude: "}</b> &nbsp;${longitude}</p>
<div class="tooltip p_card_map_comment text-left tooltip-secondary" data-tip="${comment}">
<p class="p_card_map_comment line-clamp-2"><b>${locale == "bg" ? "Коментар: " : "Comment: "}</b> &nbsp; ${comment}</p>
</div>
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
  const locale = localStorage.getItem("locale") || "en";

  return `
<div class="flex flex-col justify-around items-center w-full h-full ">

  <p class="p_card_name p_map_cards s"><b>${name}</b></p>
  ${slider}
 <p class="p_card_map p_map_cards">
    <b>${locale == "bg" ? "Петролно замърсяване: " : "Oil: "}</b>
    &nbsp; ${oil ? (locale == "bg" ? "Да" : "Yes") : locale == "bg" ? "Не" : "No"}
  </p>
  <p class="p_card_map p_map_cards">
    <b>${locale == "bg" ? "Замърсяване с пластмаса: " : "Plastic: "}</b>
    &nbsp; ${plastic ? (locale == "bg" ? "Да" : "Yes") : locale == "bg" ? "Не" : "No"}
  </p>
  <p class="p_card_map p_map_cards">
    <b>${locale == "bg" ? "Биологично замърсяване: " : "Biological: "}</b>
    &nbsp; ${biological ? (locale == "bg" ? "Да" : "Yes") : locale == "bg" ? "Не" : "No"}
  </p>
  <p class="p_card_map p_map_cards">
    <b>${locale == "bg" ? "Гео. ш.: " : "Latitude: "}</b> &nbsp;${latitude}
  </p>
  <p class="p_card_map p_map_cards">
    <b>${locale == "bg" ? "Гео. д.: " : "Longitude: "}</b> &nbsp;${longitude}
  </p>
  <div class="tooltip p_card_map_comment text-left tooltip-secondary" data-tip="${comment}">
    <p class="p_card_map_comment line-clamp-2">
      <b>${locale == "bg" ? "Коментар: " : "Comment: "}</b> &nbsp; ${comment}
    </p>
</div>
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
  const locale = localStorage.getItem("locale") || "en";

  return `
  <div class="flex flex-col justify-around items-center w-full h-full ">
   <p class="p_card_name p_map_cards s"><b>${name}</b></p>
  ${slider}
  <div class="flex flex-col items-center justify-between w-full h-[150px] mt-3">
  <p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Тип буря: " : "Storm type: "}</b> &nbsp; ${storm_type_id}</p>
  <p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Гео. ш.: " : "Latitude: "} </b> &nbsp;${latitude}</p>
  <p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Гео. д.: " : "Longitude: "}</b> &nbsp;${longitude}</p>
<div class="tooltip p_card_map_comment text-left tooltip-secondary" data-tip="${comment}">
<p class="p_card_map_comment line-clamp-2"><b>${locale == "bg" ? "Коментар: " : "Comment: "}</b> &nbsp; ${comment}</p>
</div>
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
  const locale = localStorage.getItem("locale") || "en";

  return `
  <div class="flex flex-col justify-around items-center w-full h-full ">
 <p class="p_card_name p_map_cards s line-clamp-1"><b>${name}</b></p>
  ${slider}
 <div class="flex flex-col items-center justify-between w-full h-[210px] mt-3">
<p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Вид мъгла: " : "Fog type: "}</b> &nbsp;${fog_type}</p>
<p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Вид вятър " : "Wind type: "}</b> &nbsp;${wind_type}</p>
<p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Вид морско вълнение: " : "Sea swell type: "}</b> &nbsp;${sea_swell_type}</p>
<p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Гео. ш.: " : "Latitude: "}</b> &nbsp;${latitude}</p>
<p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Гео. д.: " : "Longitude: "}</b> &nbsp;${longitude}</p>
<div class="tooltip p_card_map_comment text-left tooltip-secondary" data-tip="${comment}">
<p class="p_card_map_comment line-clamp-2"><b>${locale == "bg" ? "Коментар: " : "Comment: "}</b> &nbsp; ${comment}</p>
</div>
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
  const locale = localStorage.getItem("locale") || "en";

  return `
  <div class="flex flex-col justify-around items-center w-full h-full ">
  <p class="p_card_name p_map_cards s line-clamp-1"><b>${name}</b></p>
  ${slider}
  <div class="flex flex-col items-center justify-between w-full h-[150px] mt-3">
  <p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Гео. ш.: " : "Latitude: "} </b> &nbsp;${latitude}</p>
<p class="p_card_map p_map_cards"><b>${locale == "bg" ? "Гео. д.: " : "Longitude: "} </b> &nbsp;${longitude}</p>
<div class="tooltip p_card_map_comment text-left tooltip-secondary" data-tip="${comment}">
<p class="p_card_map_comment line-clamp-2"><b>${locale == "bg" ? "Коментар: " : "Comment: "}</b> &nbsp; ${comment}</p>
</div>
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
