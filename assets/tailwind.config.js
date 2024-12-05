// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    '../deps/live_toast/lib/**/*.*ex'
  ],
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00",
        'peach-fuzz': {
          '00': 'hsl(22deg 100% 100%)',
          '50': 'hsl(22deg 100% 96%)',
          '100': 'hsl(22deg 100% 92%)',
          '200': 'hsl(22deg 100% 80%)',
          '300': 'hsl(22deg 100% 73%)',
          '400': '#fd713a',
          '500': '#fc4c13',
          '600': '#ed3109',
          '700': '#c4210a',
          '800': '#9c1c10',
          '900': '#7d1a11',
          '950': '#440a06',
        },
        'peach-fuzz-lightness': {
          '00': 'hsl(22deg 100% 100%)',
          '12': 'hsl(22deg 100% 99%)',
          '25': 'hsl(22deg 100% 98%)',
          '38': 'hsl(22deg 100% 97%)',
          '50': 'hsl(22deg 100% 96%)',
          '62': 'hsl(22deg 100% 95%)',
          '75': 'hsl(22deg 100% 94%)',
          '88': 'hsl(22deg 100% 93%)',
          '100': 'hsl(22deg 100% 92%)',
          '105': 'hsl(22deg 100% 91%)',
          '110': 'hsl(22deg 100% 90%)',
          '120': 'hsl(22deg 100% 89%)',
          '130': 'hsl(22deg 100% 88%)',
          '140': 'hsl(22deg 100% 87%)',
          '150': 'hsl(22deg 100% 86%)',
          '160': 'hsl(22deg 100% 85%)',
          '170': 'hsl(22deg 100% 84%)',
          '180': 'hsl(22deg 100% 83%)',
          '190': 'hsl(22deg 100% 82%)',
          '195': 'hsl(22deg 100% 81%)',
          '200': 'hsl(22deg 100% 80%)',
          '250': 'hsl(22deg 100% 75%)',
          '300': 'hsl(22deg 100% 70%)',
          '350': 'hsl(22deg 100% 65%)',
          '400': 'hsl(22deg 100% 60%)',
          '450': 'hsl(22deg 100% 55%)',
          '500': 'hsl(22deg 100% 50%)',
          '550': 'hsl(22deg 100% 45%)',
          '600': 'hsl(22deg 100% 40%)',
          '650': 'hsl(22deg 100% 35%)',
          '700': 'hsl(22deg 100% 30%)',
          '750': 'hsl(22deg 100% 25%)',
          '800': 'hsl(22deg 100% 20%)',
          '850': 'hsl(22deg 100% 15%)',
          '900': 'hsl(22deg 100% 10%)',
          '950': 'hsl(22deg 100% 5%)',
        }
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Hero Icons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, { values })
    })
  ]
}
