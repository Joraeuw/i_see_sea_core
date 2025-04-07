import Swiper from "swiper/bundle";
import "swiper/css/bundle";

window.openFullscreenModal = (pictures, startingIndex = 0) => {
  try {
    // Validate inputs
    if (!pictures || !Array.isArray(pictures) || !pictures.length) {
      console.error("No valid pictures provided to openFullscreenModal", pictures);
      return;
    }

    console.log("pictures", pictures);

    // Normalize starting index
    startingIndex = Math.max(0, Math.min(pictures.length - 1, parseInt(startingIndex) || 0));
    
    const fullscreen_modal = document.getElementById("modal_fullscreen_image_slider");
    const container = document.getElementById("modal_fullscreen_image_slider_container");
    const imageCounter = document.getElementById("modal-counter");

    if (!fullscreen_modal || !container) {
      console.error("Modal elements not found");
      return;
    }

    // First, destroy any existing swiper instance to prevent issues
    if (window.fullscreenSwiper) {
      window.fullscreenSwiper.destroy(true, true);
      window.fullscreenSwiper = null;
    }

    // Clear previous slides
    container.innerHTML = "";

    // Create slides for each picture with enhanced structure for optimal loading
    const slides = pictures
      .map(
        (picture, idx) => `
      <div class="swiper-slide" data-index="${idx}">
        <div class="swiper-zoom-container">
          <div class="slide-content">
            <img src="${picture}" 
                alt="Full size image ${idx + 1} of ${pictures.length}" 
                class="w-auto h-auto max-w-[800px] max-h-[800px] z-40 select-none image-zoom" 
                draggable="false"
                loading="${idx < 2 ? 'eager' : 'lazy'}"
                onerror="this.src='/images/no_image_provided.svg'; this.classList.add('error-image')"/>
          </div>
        </div>
      </div>
    `
      )
      .join("");

    container.innerHTML = slides;
    
    // Make sure modal is visible before initializing Swiper
    fullscreen_modal.classList.add("modal-open");
    document.body.classList.add('overflow-hidden'); // Prevent background scrolling
    
    // Small delay to ensure DOM is ready
    setTimeout(() => {
      // Determine if we should use loop mode based on number of slides
      const shouldLoop = pictures.length > 2;
      
      // Initialize Swiper with reliable configuration
      window.fullscreenSwiper = new Swiper(".modal .swiper-container", {
        initialSlide: startingIndex,
        grabCursor: true,
        spaceBetween: 30,
        speed: 300,
        effect: "slide",
        keyboard: {
          enabled: true,
          onlyInViewport: false,
        },
        navigation: {
          nextEl: pictures.length > 1 ? ".modal .swiper-button-next" : null,
          prevEl: pictures.length > 1 ? ".modal .swiper-button-prev" : null,
          disabledClass: "swiper-button-disabled",
          hiddenClass: "swiper-button-hidden",
        },
        pagination: {
          el: pictures.length > 1 ? ".modal .swiper-pagination" : null,
          type: "bullets",
          clickable: true,
        },
        zoom: {
          maxRatio: 5,
          minRatio: 1,
          toggle: true,
        },
        loop: shouldLoop,
        loopAdditionalSlides: shouldLoop ? 3 : 0,
        shortSwipes: true,
        longSwipesRatio: 0.2,
        preloadImages: true,
        updateOnImagesReady: true,
        watchSlidesProgress: true,
        preventInteractionOnTransition: false,
        observer: true,
        observeParents: true,
        on: {
          slideChange: function() {
            // Update image counter
            const currentIndex = this.realIndex || 0;
            if (imageCounter) {
              imageCounter.textContent = `${currentIndex + 1}/${pictures.length}`;
            }
          },
          init: function() {
            // Set initial counter
            if (imageCounter) {
              const currentIndex = this.realIndex || startingIndex || 0;
              imageCounter.textContent = `${currentIndex + 1}/${pictures.length}`;
            }
            
            // Update UI visibility based on slide count
            const nextButton = document.querySelector('.modal .swiper-button-next');
            const prevButton = document.querySelector('.modal .swiper-button-prev');
            const pagination = document.querySelector('.modal .swiper-pagination');
            
            // Hide navigation for single images
            if (pictures.length <= 1) {
              if (nextButton) nextButton.style.display = 'none';
              if (prevButton) prevButton.style.display = 'none';
              if (pagination) pagination.style.display = 'none';
            } else {
              if (nextButton) nextButton.style.display = '';
              if (prevButton) prevButton.style.display = '';
              if (pagination) pagination.style.display = '';
            }
            
            // Add double-tap to zoom
            const slides = document.querySelectorAll('.modal .swiper-slide');
            slides.forEach(slide => {
              let lastTap = 0;
              slide.addEventListener('touchend', function(e) {
                const currentTime = new Date().getTime();
                const tapLength = currentTime - lastTap;
                if (tapLength < 300 && tapLength > 0) {
                  // Double tap detected
                  const swiper = window.fullscreenSwiper;
                  if (swiper && !swiper.zoom.scale || swiper.zoom.scale === 1) {
                    swiper.zoom.in();
                  } else {
                    swiper.zoom.out();
                  }
                  e.preventDefault();
                }
                lastTap = currentTime;
              });
            });
          }
        }
      });
      
      // Add direct event listeners to the navigation buttons to ensure they work
      const nextButton = document.querySelector('.modal .swiper-button-next');
      const prevButton = document.querySelector('.modal .swiper-button-prev');
      
      if (nextButton && pictures.length > 1) {
        nextButton.addEventListener('click', function(e) {
          if (window.fullscreenSwiper) {
            // If it's the last slide and loop mode is disabled, don't try to go further
            if (!shouldLoop && window.fullscreenSwiper.isEnd) {
              // Optional: consider animating the slide to give feedback
              window.fullscreenSwiper.slideTo(window.fullscreenSwiper.slides.length - 1);
              return;
            }
            window.fullscreenSwiper.slideNext();
          }
          e.stopPropagation();
        });
      }
      
      if (prevButton && pictures.length > 1) {
        prevButton.addEventListener('click', function(e) {
          if (window.fullscreenSwiper) {
            // If it's the first slide and loop mode is disabled, don't try to go back
            if (!shouldLoop && window.fullscreenSwiper.isBeginning) {
              // Optional: consider animating the slide to give feedback
              window.fullscreenSwiper.slideTo(0);
              return;
            }
            window.fullscreenSwiper.slidePrev();
          }
          e.stopPropagation();
        });
      }
    }, 50);

    // Add keyboard event listeners
    const handleKeyDown = (e) => {
      if (e.key === "Escape") {
        closeFullscreenModal();
      } else if (e.key === "ArrowRight" && pictures.length > 1) {
        if (window.fullscreenSwiper) {
          // Check if we're at the end and loop is disabled
          if (!shouldLoop && window.fullscreenSwiper.isEnd) {
            // Provide visual feedback but don't try to go past the end
            window.fullscreenSwiper.slideTo(window.fullscreenSwiper.slides.length - 1);
            return;
          }
          window.fullscreenSwiper.slideNext();
        }
      } else if (e.key === "ArrowLeft" && pictures.length > 1) {
        if (window.fullscreenSwiper) {
          // Check if we're at the beginning and loop is disabled
          if (!shouldLoop && window.fullscreenSwiper.isBeginning) {
            // Provide visual feedback but don't try to go before the start
            window.fullscreenSwiper.slideTo(0);
            return;
          }
          window.fullscreenSwiper.slidePrev();
        }
      } else if (e.key === "+") {
        if (window.fullscreenSwiper) {
          window.fullscreenSwiper.zoom.in();
        }
      } else if (e.key === "-") {
        if (window.fullscreenSwiper) {
          window.fullscreenSwiper.zoom.out();
        }
      }
    };
    
    document.addEventListener("keydown", handleKeyDown);

    // Close modal when clicking outside
    const closeModalOnClickOutside = function (event) {
      const modalBox = fullscreen_modal.querySelector(".modal-box");
      if (!modalBox.contains(event.target) || event.target.closest(".modal-close-btn")) {
        closeFullscreenModal();
      }
    };

    fullscreen_modal.addEventListener("click", closeModalOnClickOutside);
    
    // Store event handlers for cleanup
    window.modalEventHandlers = {
      keyDown: handleKeyDown,
      clickOutside: closeModalOnClickOutside
    };
  } catch (error) {
    console.error("Error in openFullscreenModal:", error);
  }
};

window.closeFullscreenModal = () => {
  const fullscreen_modal = document.getElementById(
    "modal_fullscreen_image_slider"
  );
  
  // Add animation class for fade out
  fullscreen_modal.style.opacity = "0";
  
  // Remove classes after animation completes
  setTimeout(() => {
    fullscreen_modal.classList.remove("modal-open");
    fullscreen_modal.style.opacity = "";
    document.body.classList.remove('overflow-hidden'); // Restore background scrolling
  }, 300);

  // Destroy Swiper instance to clean up
  if (window.fullscreenSwiper) {
    window.fullscreenSwiper.destroy(true, true);
    window.fullscreenSwiper = null;
  }
  
  // Remove event listeners
  if (window.modalEventHandlers) {
    document.removeEventListener("keydown", window.modalEventHandlers.keyDown);
    fullscreen_modal.removeEventListener("click", window.modalEventHandlers.clickOutside);
    window.modalEventHandlers = null;
  }
};

const createImageSlider = (pictures) => {
  if (!pictures || pictures.length === 0)
    return `<div class="image-placeholder flex justify-center items-center rounded-lg bg-gray-100 p-2">
              <img class="h-16 mx-auto opacity-70" src="/images/no_image_provided.svg"/>
            </div>`;

  // Ensure pictures is an array and all items are strings
  const cleanPictures = Array.isArray(pictures) ? pictures : [pictures];
  
  // Use only the first image as thumbnail with gallery indicator if multiple images
  const firstPicture = cleanPictures[0];
  const hasMultiple = cleanPictures.length > 1;

  // Explicitly stringify and encode the pictures array to avoid issues
  const encodedPictures = encodeURIComponent(JSON.stringify(cleanPictures));
  
  // Make the image smaller with fixed height to leave room for data
  return `
    <div class="image-thumbnail text-center relative group" role="button" aria-label="View image${hasMultiple ? 's' : ''}">
      <button class="open-modal-button rounded-lg overflow-hidden w-full outline-none focus:ring-2 focus:ring-[rgb(117,230,218)]" 
              data-pictures='${encodedPictures}' 
              data-index='0'
              title="${hasMultiple ? `View all ${cleanPictures.length} images` : 'View full size image'}">
        <div class="h-16 max-h-16 overflow-hidden flex items-center justify-center bg-gray-50">
          <img class="h-full object-contain w-auto mx-auto rounded-lg transition duration-200 group-hover:brightness-110" 
               src="${firstPicture}" 
               alt="Picture"/>
        </div>
        ${hasMultiple ? `
          <div class="gallery-count">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clip-rule="evenodd" />
            </svg>
            +${cleanPictures.length - 1}
          </div>` : ''}
      </button>
    </div>
  `;
};

// Add event delegation for popup close buttons and image modal opening
document.addEventListener("click", function (event) {
  // Handle image modal buttons with improved event delegation
  const openModalButton = event.target.closest(".open-modal-button");
  const galleryCount = event.target.closest(".gallery-count");
  const imageInThumbnail = event.target.closest(".image-thumbnail");
  
  // Handle click on button, gallery count indicator, or image thumbnail
  if (openModalButton || galleryCount || imageInThumbnail) {
    // Find the button that contains our data
    const buttonElement = openModalButton || 
                         (galleryCount && galleryCount.closest(".open-modal-button")) || 
                         (imageInThumbnail && imageInThumbnail.querySelector(".open-modal-button"));
    
    if (buttonElement) {
      try {
        const picturesData = decodeURIComponent(
          buttonElement.getAttribute("data-pictures")
        );
        const pictures = JSON.parse(picturesData);
        const index = parseInt(buttonElement.getAttribute("data-index") || "0", 10);

        // Make sure we have valid pictures before opening the modal
        if (Array.isArray(pictures) && pictures.length > 0) {
          // Prevent default if it's a button to avoid form submission
          event.preventDefault();
          // Stop propagation to avoid conflict with other click handlers
          event.stopPropagation();
          // Open the fullscreen modal
          window.openFullscreenModal(pictures, index);
        }
      } catch (error) {
        console.error("Error opening fullscreen modal:", error, buttonElement);
      }
    }
  }
  
  // Handle popup close buttons
  const closePopupButton = event.target.closest(".popup-close-button");
  if (closePopupButton) {
    // Find the nearest Leaflet popup and close it
    const popup = closePopupButton.closest(".leaflet-popup");
    if (popup) {
      // Get the Leaflet popup instance and close it
      const map = window.leafletMap;
      if (map) {
        map.closePopup();
      }
    }
  }
});

const formatReportDate = (() => {
  function formatDateTime(report_date) {
    const timestamp = report_date;
    const date = new Date(timestamp);
    const locale = localStorage.getItem("locale") || "en";
    
    // Map the app locale to the appropriate date locale format
    const localeMap = {
      "en": "en-US",
      "bg": "bg-BG"
    };
    
    const dateLocale = localeMap[locale] || "en-US";

    const options = {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    };

    return new Intl.DateTimeFormat(dateLocale, options).format(date);
  }
  
  return function(report_date) {
    return formatDateTime(report_date);
  };
})();

// Modify the shared popup structure across all content functions
const createPopupBaseStructure = (params) => {
  const {
    displayName,
    headerColor = 'bg-[rgb(24,158,180)]',
    slider,
    content,
    formattedDate,
    locale
  } = params;
  
  return `
  <div class="flex flex-col w-full h-full bg-gradient-to-b from-[rgba(212,241,244,0.6)] to-[rgba(212,241,244,0.8)] rounded-lg overflow-hidden max-h-[350px]">
    <!-- Header section -->
    <div class="w-full ${headerColor} px-2 py-1.5 flex justify-between items-center sticky top-0 z-10">
      <h3 class="text-[rgb(212,241,244)] font-bold text-sm max-w-[85%] overflow-hidden text-ellipsis whitespace-nowrap">${displayName}</h3>
      <button class="text-[rgb(212,241,244)] hover:text-[rgb(117,230,218)] transition-colors popup-close-button">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    
    <!-- Image section -->
    <div class="p-1 bg-[rgba(212,241,244,0.2)]">
      ${slider}
    </div>
    
    <!-- Scrollable content area -->
    <div class="overflow-y-auto overflow-x-hidden flex-grow bg-[rgba(212,241,244,0.2)]" style="max-height: 250px;">
      <div class="px-2 pb-2 space-y-2 pt-1.5">
        ${content}
      </div>
    </div>
    
    <!-- Footer -->
    <div class="bg-white bg-opacity-90 text-right text-xs text-gray-600 px-2 py-1 sticky bottom-0 border-t border-gray-200 font-medium">
      ${formattedDate}
    </div>
  </div>
  `;
};

// Helper function for location section - more compact for mobile
const createLocationSection = (latitude, longitude, locale) => {
  return `
  <div class="bg-white shadow rounded-lg p-2">
    <div class="flex items-center">
      <svg class="w-4 h-4 text-[rgb(24,158,180)] flex-shrink-0 mr-2" fill="none" viewBox="0 0 24 24" stroke="black">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
          d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
          d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>
      <div>
        <div class="text-sm text-[rgb(24,158,180)] font-medium leading-tight">${locale == "bg" ? "Координати" : "Location"}</div>
        <div class="text-sm text-gray-800 break-all leading-tight font-medium">
          <span class="font-bold">${locale == "bg" ? "Гео. ш.:" : "Lat:"}</span> ${latitude ? latitude.toFixed(6) : "N/A"}, 
          <span class="font-bold">${locale == "bg" ? "Гео. д.:" : "Long:"}</span> ${longitude ? longitude.toFixed(6) : "N/A"}
        </div>
      </div>
    </div>
  </div>
  `;
};

// Helper function for comment section
const createCommentSection = (comment, locale) => {
  if (!comment) return '';
  
  return `
  <div class="bg-white shadow rounded-lg p-2">
    <div class="flex items-start">
      <svg class="w-4 h-4 text-[rgb(24,158,180)] mt-0.5 flex-shrink-0 mr-2" fill="none" viewBox="0 0 24 24" stroke="black">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
          d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
      </svg>
      <div>
        <div class="text-sm text-[rgb(24,158,180)] font-medium leading-tight">${locale == "bg" ? "Коментар" : "Comment"}</div>
        <div class="text-sm text-gray-800 mt-0.5 break-words leading-tight font-medium">${comment}</div>
      </div>
    </div>
  </div>
  `;
};

// Refactored jellyfish content function
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
  const slider = createImageSlider(pictures || []);
  const formattedDate = formatReportDate(report_date || new Date().toISOString());
  const locale = localStorage.getItem("locale") || "en";
  const displayName = name || (locale == "bg" ? "Доклад за медузи" : "Jellyfish Report");

  const content = `
    <div class="space-y-1.5">
      <div class="bg-white shadow rounded-lg p-1.5 flex items-center">
        <div class="bg-[rgba(24,158,180,0.2)] p-1 rounded-full mr-1.5">
          <img class="w-3.5 h-3.5 text-[rgb(24,158,180)]" src="/images/report_icons/jelly_icon.svg" />
        </div>
        <div class="overflow-hidden">
          <div class="text-xs text-gray-500 font-medium leading-tight">${locale == "bg" ? "Вид" : "Species"}</div>
          <div class="font-semibold text-xs text-gray-700 truncate leading-tight">${species || (locale == "bg" ? "Не е посочено" : "Not specified")}</div>
        </div>
      </div>
      
      <div class="bg-white shadow rounded-lg p-1.5 flex items-center">
        <div class="bg-[rgba(24,158,180,0.2)] p-1 rounded-full mr-1.5">
         <img class="w-3.5 h-3.5 text-[rgb(24,158,180)]" src="/images/report_icons/quintity_icon.svg" />
        </div>
        <div class="overflow-hidden">
          <div class="text-xs text-gray-500 font-medium leading-tight">${locale == "bg" ? "Количество" : "Quantity"}</div>
          <div class="font-semibold text-xs text-gray-700 truncate leading-tight">${quantity || (locale == "bg" ? "Не е посочено" : "Not specified")}</div>
        </div>
      </div>
    </div>
    
    ${createLocationSection(latitude, longitude, locale)}
    ${createCommentSection(comment, locale)}
  `;

  return createPopupBaseStructure({
    displayName,
    slider,
    content,
    formattedDate,
    locale
  });
};

// Refactored pollution content function with more compact layout
const pollutionContent = ({
  name,
  comment,
  pictures,
  pollution_types,
  latitude,
  longitude,
  report_date,
}) => {
  const slider = createImageSlider(pictures || []);
  const plastic = pollution_types && pollution_types.includes("plastic");
  const oil = pollution_types && pollution_types.includes("oil");
  const biological = pollution_types && pollution_types.includes("biological");
  const formattedDate = formatReportDate(report_date || new Date().toISOString());
  const locale = localStorage.getItem("locale") || "en";
  const displayName = name || (locale == "bg" ? "Доклад за замърсяване" : "Pollution Report");

  const content = `
    <div class="bg-white shadow rounded-lg p-2">
      <div class="text-sm text-[rgb(24,158,180)] font-medium mb-1 leading-tight">${locale == "bg" ? "Тип замърсяване" : "Pollution Types"}</div>
      <div class="space-y-1">
        <div class="flex items-center">
          <div class="w-4 h-4 mr-2 ${oil ? 'pollution-status-ok' : 'pollution-status-notok'}">
            ${oil ? 
              `<svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
               </svg>` : 
              `<svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
               </svg>`
            }
          </div>
          <span class="text-sm text-gray-800 leading-tight font-medium">${locale == "bg" ? "Петролно замърсяване" : "Oil Pollution"}</span>
        </div>
        
        <div class="flex items-center">
          <div class="w-4 h-4 mr-2 ${plastic ? 'pollution-status-ok' : 'pollution-status-notok'}">
            ${plastic ? 
              `<svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
               </svg>` : 
              `<svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
               </svg>`
            }
          </div>
          <span class="text-sm text-gray-800 leading-tight font-medium">${locale == "bg" ? "Замърсяване с пластмаса" : "Plastic Pollution"}</span>
        </div>
        
        <div class="flex items-center">
          <div class="w-4 h-4 mr-2 ${biological ? 'pollution-status-ok' : 'pollution-status-notok'}">
            ${biological ? 
              `<svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
               </svg>` : 
              `<svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
               </svg>`
            }
          </div>
          <span class="text-sm text-gray-800 leading-tight font-medium">${locale == "bg" ? "Биологично замърсяване" : "Biological Pollution"}</span>
        </div>
      </div>
    </div>
    
    ${createLocationSection(latitude, longitude, locale)}
    ${createCommentSection(comment, locale)}
  `;

  return createPopupBaseStructure({
    displayName,
    slider,
    content,
    formattedDate,
    locale
  });
};

// Refactored atypical activity content function
const atypicalActivityContent = ({
  name,
  comment,
  storm_type_id,
  pictures,
  latitude,
  longitude,
  report_date,
}) => {
  const slider = createImageSlider(pictures || []);
  const formattedDate = formatReportDate(report_date || new Date().toISOString());
  const locale = localStorage.getItem("locale") || "en";
  const displayName = name || (locale == "bg" ? "Доклад за необичайна активност" : "Atypical Activity Report");

  const content = `
    <div class="bg-white shadow rounded-lg p-1.5 flex items-center">
      <div class="bg-[rgba(24,158,180,0.2)] p-1 rounded-full mr-1.5">
        <svg class="w-3.5 h-3.5 text-[rgb(24,158,180)]" fill="none" viewBox="0 0 24 24" stroke="black">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
            d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
      </div>
      <div class="overflow-hidden">
        <div class="text-xs text-gray-500 font-medium leading-tight">${locale == "bg" ? "Тип буря" : "Storm Type"}</div>
        <div class="font-semibold text-xs text-gray-700 truncate leading-tight">${storm_type_id || (locale == "bg" ? "Не е посочено" : "Not specified")}</div>
      </div>
    </div>
    
    ${createLocationSection(latitude, longitude, locale)}
    ${createCommentSection(comment, locale)}
  `;

  return createPopupBaseStructure({
    displayName,
    slider,
    content,
    formattedDate,
    locale
  });
};

// Refactored meteorological content function with vertical layout
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
  const slider = createImageSlider(pictures || []);
  const formattedDate = formatReportDate(report_date || new Date().toISOString());
  const locale = localStorage.getItem("locale") || "en";
  const displayName = name || (locale == "bg" ? "Метеорологичен доклад" : "Meteorological Report");

  const content = `
    <div class="space-y-1.5">
      <div class="bg-white shadow rounded-lg p-1.5 flex items-center">
        <div class="bg-[rgba(24,158,180,0.2)] p-1 rounded-full mr-1.5">
          <img class="w-3.5 h-3.5 text-[rgb(24,158,180)]" src="/images/report_icons/fog_type.svg" />
        </div>
        <div class="overflow-hidden">
          <div class="text-xs text-gray-500 font-medium leading-tight">${locale == "bg" ? "Вид мъгла" : "Fog type"}</div>
          <div class="font-semibold text-xs text-gray-700 truncate leading-tight">${fog_type || (locale == "bg" ? "Не е посочено" : "Not specified")}</div>
        </div>
      </div>
      
      <div class="bg-white shadow rounded-lg p-1.5 flex items-center">
        <div class="bg-[rgba(24,158,180,0.2)] p-1 rounded-full mr-1.5">
          <img class="w-3.5 h-3.5 text-[rgb(24,158,180)]" src="/images/report_icons/wind_type.svg" />
        </div>
        <div class="overflow-hidden">
          <div class="text-xs text-gray-500 font-medium leading-tight">${locale == "bg" ? "Вид вятър" : "Wind type"}</div>
          <div class="font-semibold text-xs text-gray-700 truncate leading-tight">${wind_type || (locale == "bg" ? "Не е посочено" : "Not specified")}</div>
        </div>
      </div>
      
      <div class="bg-white shadow rounded-lg p-1.5 flex items-center">
        <div class="bg-[rgba(24,158,180,0.2)] p-1 rounded-full mr-1.5">
          <img class="w-3.5 h-3.5 text-[rgb(24,158,180)]" src="/images/report_icons/sea_swell.svg" />
        </div>
        <div class="overflow-hidden">
          <div class="text-xs text-gray-500 font-medium leading-tight">${locale == "bg" ? "Вид морско вълнение" : "Sea swell"}</div>
          <div class="font-semibold text-xs text-gray-700 truncate leading-tight">${sea_swell_type || (locale == "bg" ? "Не е посочено" : "Not specified")}</div>
        </div>
      </div>
    </div>
    
    ${createLocationSection(latitude, longitude, locale)}
    ${createCommentSection(comment, locale)}
  `;

  return createPopupBaseStructure({
    displayName,
    slider,
    content,
    formattedDate,
    locale
  });
};

// Refactored other content function
const otherContent = ({
  name,
  comment,
  pictures,
  pictres,
  latitude,
  longitude,
  report_date,
}) => {
  // Fix potential typo in the property name (pictres vs pictures)
  const imageArray = pictures || pictres || [];
  const slider = createImageSlider(imageArray);
  const formattedDate = formatReportDate(report_date || new Date().toISOString());
  const locale = localStorage.getItem("locale") || "en";
  const displayName = name || (locale == "bg" ? "Друг доклад" : "Other Report");

  const content = `
    ${createLocationSection(latitude, longitude, locale)}
    ${createCommentSection(comment, locale)}
  `;

  return createPopupBaseStructure({
    displayName,
    slider,
    content,
    formattedDate,
    locale
  });
};

const getMarkerContent = (report) => {
  // Safety check to ensure report is an object with expected properties
  if (!report || typeof report !== 'object') {
    console.error('Invalid report data:', report);
    return '<div class="bg-red-100 p-4 rounded">Error: Invalid report data</div>';
  }

  // For debugging - log the report data to console
  console.log('Report data:', report);

  try {
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
        return `<div class="bg-yellow-100 p-4 rounded">
          <h3 class="font-bold">Unknown Report Type</h3>
          <p>Type: ${report.report_type || 'not specified'}</p>
          <p>Name: ${report.name || 'not specified'}</p>
        </div>`;
    }
  } catch (error) {
    console.error('Error rendering report content:', error);
    return `<div class="bg-red-100 p-4 rounded">
      <h3 class="font-bold">Error Displaying Report</h3>
      <p>${error.message}</p>
    </div>`;
  }
};

export { getMarkerContent };
