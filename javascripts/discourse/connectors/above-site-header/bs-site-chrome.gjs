import Component from "@glimmer/component";
import BsSocialIcon from "../../components/bs-social-icon";
import { parseSocialLinks } from "../../lib/bs-links";

// The two bands of site chrome that sit ABOVE Discourse's own header:
// the thin date/social top bar, and the centered wordmark masthead.
//
// This renders into the `above-site-header` plugin outlet, which is a sibling
// placed before <GlimmerSiteHeader> in Discourse's application template. That
// matters: Discourse's header is `position: sticky; top: 0`, so anything above
// it scrolls away on its own and the header docks to the top of the viewport
// with no help from us.
//
// The previous theme instead injected its own sticky header and then pushed
// Discourse's header down with a hardcoded `top: 55px`. Those two numbers had
// no way to stay in agreement, which is why the header contents ended up
// floating in the middle of the page. Nothing here sets a fixed offset.
export default class BsSiteChrome extends Component {
  get showTopbar() {
    return settings.show_topbar;
  }

  get showMasthead() {
    return settings.show_masthead;
  }

  get showDate() {
    return settings.show_topbar_date;
  }

  // Rendered on the client, so it reflects the reader's own clock the same way
  // the main site's TopBar does.
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
    return settings.main_site_url;
  }

  get logoUrl() {
    return settings.masthead_logo_url;
  }

  <template>
    {{#if this.showTopbar}}
      <div class="bs-topbar">
        <div class="bs-band">
          {{#if this.showDate}}
            <span class="bs-topbar__date">{{this.today}}</span>
          {{else}}
            <span></span>
          {{/if}}

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
        </div>
      </div>
    {{/if}}

    {{#if this.showMasthead}}
      <div class="bs-masthead">
        <a href={{this.mainSiteUrl}} class="bs-masthead__link">
          <img src={{this.logoUrl}} alt="BuffStampede" />
        </a>
      </div>
    {{/if}}
  </template>
}
