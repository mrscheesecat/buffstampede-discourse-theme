import Component from "@glimmer/component";
import { service } from "@ember/service";
import BsSocialIcon from "../../components/bs-social-icon";
import { parseSocialLinks } from "../../lib/bs-links";

// The two bands of site chrome that sit ABOVE Discourse's own header: the thin
// date / social / auth top bar, and the centered wordmark masthead.
//
// Measurements here are taken from components/TopBar.jsx and
// components/Masthead.jsx in the site repo, not eyeballed from a screenshot.
//
// This renders into the `above-site-header` plugin outlet, a sibling placed
// before <GlimmerSiteHeader> in Discourse's application template. Discourse's
// header is `position: sticky; top: 0`, so these bands scroll away on their own
// and the header docks with no help from us. Nothing here sets a fixed offset.
export default class BsSiteChrome extends Component {
  @service currentUser;

  get showTopbar() {
    return settings.show_topbar;
  }

  get showMasthead() {
    return settings.show_masthead;
  }

  get showDate() {
    return settings.show_topbar_date;
  }

  get showAuthLinks() {
    return settings.show_topbar_auth_links;
  }

  get signedIn() {
    return !!this.currentUser;
  }

  // Rendered on the client, matching formatDate() in TopBar.jsx exactly.
  get today() {
    return new Date().toLocaleDateString("en-US", {
      weekday: "long",
      month: "long",
      day: "numeric",
      year: "numeric",
    });
  }

  get socials() {
    return parseSocialLinks(settings.topbar_socials);
  }

  get mainSiteUrl() {
    return (settings.main_site_url || "").replace(/\/$/, "");
  }

  get accountUrl() {
    return `${this.mainSiteUrl}/account`;
  }

  get signUpUrl() {
    return `${this.mainSiteUrl}/sign-up`;
  }

  get logoUrl() {
    return settings.masthead_logo_url;
  }

  <template>
    {{#if this.showTopbar}}
      <div class="bs-topbar">
        <div class="bs-band">
          {{#if this.showDate}}
            <p class="bs-topbar__date">{{this.today}}</p>
          {{else}}
            <span></span>
          {{/if}}

          <div class="bs-topbar__right">
            {{#if this.socials}}
              <div class="bs-topbar__socials">
                {{#each this.socials as |social|}}
                  <a
                    href={{social.url}}
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={{social.label}}
                  >
                    <BsSocialIcon @icon={{social.icon}} />
                  </a>
                {{/each}}
              </div>
            {{/if}}

            {{#if this.showAuthLinks}}
              <div class="bs-topbar__auth">
                {{#if this.signedIn}}
                  {{! The site shows the Clerk UserButton here. Clerk cannot run
                      inside Discourse, and Discourse's own avatar menu in the
                      nav row already covers it, so this is the account link
                      only — the one deliberate difference from the site. }}
                  <a
                    class="bs-topbar__auth-link bs-topbar__auth-link--primary"
                    href={{this.accountUrl}}
                  >My Account</a>
                {{else}}
                  <a class="bs-topbar__auth-link" href="/login">Login</a>
                  <a
                    class="bs-topbar__auth-link bs-topbar__auth-link--primary"
                    href={{this.signUpUrl}}
                  >Join Free</a>
                {{/if}}
              </div>
            {{/if}}
          </div>
        </div>
      </div>
    {{/if}}

    {{#if this.showMasthead}}
      <header class="bs-masthead">
        <div class="bs-band bs-band--center">
          <a href={{this.mainSiteUrl}} class="bs-masthead__link">
            <img src={{this.logoUrl}} alt="BuffStampede" />
          </a>
        </div>
      </header>
    {{/if}}
  </template>
}
