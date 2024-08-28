const createImageSlider = (pictures) => {
  if (!pictures || pictures.length === 0) return "";

  const slides = pictures
    .filter((picture) => picture)
    .map(
      (picture) =>
        `<div class="swiper-slide"><img src="${picture}" style="width:100%;height:auto;" alt="Picture"/></div>`
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

const jellyfishContent = ({ name, comment, pictures, quantity, species }) => {
  const slider = createImageSlider(pictures);
  return `
    <b>${name}</b><br>
    ${comment ? `<p>${comment}</p>` : ""}
    ${slider}
    <p>Quantity: ${quantity}</p>
    <p>Species: ${species}</p>
  `;
};
const pollutionContent = ({ name, comment }) => `<b>${name}</b><br>${comment}`;
const atypicalActivityContent = ({ name, comment }) =>
  `<b>${name}</b><br>${comment}`;
const meteorologicalContent = ({ name, comment }) =>
  `<b>${name}</b><br>${comment}`;
const otherContent = ({ name, comment }) => `<b>${name}</b><br>${comment}`;

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
