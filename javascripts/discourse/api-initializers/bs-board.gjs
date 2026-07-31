import { apiInitializer } from "discourse/lib/api";

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
});
