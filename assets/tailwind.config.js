// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/i_see_sea_web.ex",
    "../lib/i_see_sea_web/**/*.*ex",
    "./css/**/*.css",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Roboto', 'sans-serif'], // Add your Google Font here
      },
      perspective: {
        8: "800px",
        10: "1000px",
      },
      colors: {
        primary: {
          DEFAULT: "#5fa8d3", // Primary Color (Picton Blue)
          100: "#0d2330",
          200: "#1a4760",
          300: "#276a90",
          400: "#358dc0",
          500: "#5fa8d3",
          600: "#7fbadc",
          700: "#9fcbe5",
          800: "#bfdced",
          900: "#dfeef6",
        },
        secondary: {
          DEFAULT: "#62b6cb", // Secondary Color (Moonstone)
          100: "#0f272d",
          200: "#1e4e5a",
          300: "#2d7587",
          400: "#3c9cb5",
          500: "#62b6cb",
          600: "#82c4d5",
          700: "#a1d3e0",
          800: "#c0e2ea",
          900: "#e0f0f5",
        },
        accent: {
          DEFAULT: "#bee9e8", // Accent Color (Mint Green)
          100: "#163f3e",
          200: "#2b7e7d",
          300: "#41bdbb",
          400: "#7fd3d2",
          500: "#bee9e8",
          600: "#cbeded",
          700: "#d8f2f1",
          800: "#e5f6f6",
          900: "#f2fbfa",
        },
        background: {
          DEFAULT: "#cae9ff", // Background Color (Columbia Blue)
          100: "#00365c",
          200: "#006bb8",
          300: "#149dff",
          400: "#70c3ff",
          500: "#cae9ff",
          600: "#d6eeff",
          700: "#e0f2ff",
          800: "#ebf7ff",
          900: "#f5fbff",
        },
        text: {
          DEFAULT: "#1b4965", // Text Color (Indigo Dye)
          100: "#050e14",
          200: "#0b1d28",
          300: "#102b3c",
          400: "#153a51",
          500: "#1b4965",
          600: "#2b74a1",
          700: "#4a9ccf",
          800: "#86bddf",
          900: "#c3deef",
        },
      },
    },
  },
  daisyui: {
    themes: [
      {
        base: {
          primary: "rgb(24, 154, 180)",
          secondary: "rgb(212, 241, 244)",
          accent: "rgb(117, 230, 218)",
          neutral: "#189ab4",
          "base-100": "#d4f1f4",
          info: "#00ffff",
          success: "#00ff00",
          warning: "#ffd700",
          error: "#ff0000",
        },
      },
      "aqua",
    ],
  },
  plugins: [
    require("daisyui"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(function ({ addUtilities }) {
      addUtilities({
        ".backface-visible": {
          "backface-visibility": "visible",
          "-moz-backface-visibility": "visible",
          "-webkit-backface-visibility": "visible",
          "-ms-backface-visibility": "visible",
        },
        ".backface-hidden": {
          "backface-visibility": "hidden",
          "-moz-backface-visibility": "hidden",
          "-webkit-backface-visibility": "hidden",
          "-ms-backface-visibility": "hidden",
        },
      });
    }),
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized");
      let values = {};
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"],
      ];
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
          let name = path.basename(file, ".svg") + suffix;
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
        });
      });
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");
            let size = theme("spacing.6");
            if (name.endsWith("-mini")) {
              size = theme("spacing.5");
            } else if (name.endsWith("-micro")) {
              size = theme("spacing.4");
            }
            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "mask-repeat": "no-repeat",
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: size,
              height: size,
            };
          },
        },
        { values }
      );
    }),
  ],
};
