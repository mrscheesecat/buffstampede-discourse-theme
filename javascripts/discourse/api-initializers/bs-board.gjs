import { apiInitializer } from "discourse/lib/api";

// Marks the document element with `bs-docked` once the site chrome above
// Discourse's header has scrolled out of view.
//
// Identity lives in band 1, the way it does on the site. Band 1 scrolls away
// and Discourse's header docks, so once that happens the member would have no
// avatar and no notification badge anywhere. This flag is what hands the
// account control back to Discourse's own header at exactly that moment.
//
// An IntersectionObserver, deliberately, and not a scroll handler comparing
// offsets. Nothing here knows or asserts the height of any band, so nothing
// can fall out of agreement with anything else. That disagreement is what
// broke the previous theme.
function trackDockedState() {
  const root = document.documentElement;
  const target =
    document.querySelector(".bs-masthead") ||
    document.querySelector(".bs-topbar");

  // Both bands can be switched off in theme settings. With no site chrome
  // above the header there is nothing to hand off from, so Discourse's own
  // account control stays visible at all times.
  if (!target) {
    root.classList.add("bs-docked");
    return true;
  }

  new IntersectionObserver(
    ([entry]) => {
      root.classList.toggle("bs-docked", !entry.isIntersecting);
    },
    { threshold: 0 }
  ).observe(target);

  return true;
}

export default apiInitializer((api) => {
  // Send the header logo to buffstampede.com rather than the forum's own home
  // page, so it behaves the way the logo behaves on every other page of the
  // site. The forum home stays reachable through the "The Board" nav link.
  //
  // `home-logo-href` is a value transformer declared in Discourse's HomeLogo
  // component, which is the supported way to change this. The previous theme
  // hid the logo entirely and painted a fake one with a CSS ::before
  // background image, which is what produced the 24px unreadable mark.
  if (settings.logo_links_to_main_site && settings.main_site_url) {
    api.registerValueTransformer("home-logo-href", () => settings.main_site_url);
  }

  // The chrome is rendered by a plugin outlet, so it does not exist yet when
  // initializers run. Wait for it over a bounded number of frames rather than
  // polling forever, and try once more on the first page change in case the
  // app rendered unusually slowly.
  let attached = false;
  let framesLeft = 120;

  const attempt = () => {
    if (attached) {
      return;
    }

    if (document.querySelector(".bs-topbar, .bs-masthead")) {
      attached = trackDockedState();
      return;
    }

    if (framesLeft-- > 0) {
      requestAnimationFrame(attempt);
    }
  };

  requestAnimationFrame(attempt);
  api.onPageChange(() => attempt());
});
