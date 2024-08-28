// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Import LiveToast (https://toast.src.rip/) into app
import { createLiveToastHook } from 'live_toast'

// the duration for each toast to stay on screen in ms
const liveToastDuration = 4000

// how many toasts to show on screen at once
const liveToastMaxItems = 3

const liveToastHook = createLiveToastHook(liveToastDuration, liveToastMaxItems)

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    params: {
        _csrf_token: csrfToken
    },
    metadata: {
        keydown: (event, element) => {
            return {
                ctrlKey: event.ctrlKey
            }
        }
    },
    hooks: {
        LiveToast: liveToastHook
    }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Default delete confirmation dialog override
// Attribute which we use to re-trigger the click event
const CONFIRM_ATTRIBUTE = "data-confirm-fired"

// our dialog from the `root.html.heex`
const DANGER_DIALOG = document.getElementById("danger_dialog");

// Here we override the behaviour
document.body.addEventListener('phoenix.link.click', function (event) {
  // we prevent the default handling of this by phoenix html
  event.stopPropagation();

  // grab the target
  const { target: targetButton } = event;
  const title = targetButton.getAttribute("data-confirm");

  // if the target does not have `data-confirm` we simply ignore and continue
  if (!title) { return true; }

  // For re-triggering the click event
  if (targetButton.hasAttribute(CONFIRM_ATTRIBUTE)) {
    targetButton.removeAttribute(CONFIRM_ATTRIBUTE)
    return true;
  }

  // We do this since `window.confirm` prevents all execution by default. To
  // recreate this behaviour we `preventDefault` Then add an attribute which
  // will allow us to re-trigger the click event while skipping the dialog
  event.preventDefault();
  targetButton.setAttribute(CONFIRM_ATTRIBUTE, "")

  // Reset the `returnValue` as otherwise on keyboard `Esc` it will simply take
  // the most recent `returnValue`, causing all sorts of issues :D
  DANGER_DIALOG.returnValue = "cancel";

  // We use the title, which is nice we can have translated titles
  DANGER_DIALOG.querySelector("[data-ref='title']").innerText = title;


  // <dialog> is a very cool element and provides a lot of cool things out of
  // the box, like showing the modal in the #top-layer
  DANGER_DIALOG.showModal();

  // Re-triggering logic
  DANGER_DIALOG.addEventListener('close', ({ target }) => {
    if (target.returnValue === "confirm") {
      // we re-trigger the click event
      // since we have the attribute set. This will just execute the click event
      targetButton.click();
    } else {
      // Remove the attribute on cancel as otherwise the next click would
      // execute the click event without the dialog
      targetButton.removeAttribute(CONFIRM_ATTRIBUTE);
    }
  // once: true, automatically remove the listener after first execution
  }, { once: true })

}, false)

