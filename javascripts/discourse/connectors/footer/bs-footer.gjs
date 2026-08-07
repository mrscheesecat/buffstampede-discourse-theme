import Component from "@glimmer/component";
import { livePayload, socialItems } from "../../lib/bs-chrome-source";

// The site's footer, at the bottom of the forum.
//
// A reader who scrolls to the end of a topic should land on the same footer they
// would land on at the end of an article: black band, gold rule above it, the
// wordmark, the socials, the flat link row, and the copyright line.
//
// The links and the two notes under the copyright come from
// buffstampede.com/api/chrome, so there is no second copy of them here to drift.
// The bundled list below is only what renders if that fetch has never landed.
//
// Deliberately not included: the newsletter form. It posts to the site's own
// /api/subscribe, and a second signup path on another origin is a thing to keep
// working rather than a thing that works. Readers reach it through any of the
// links below.
//
// Discourse renders this outlet only when the reader has actually reached the
// end of the page, which is the behaviour we want. Imports nothing from
// Discourse; see rule 4 in common/common.scss.

const FALLBACK_LINKS = [
  { label: "Football", href: "/football/news" },
  { label: "Men's Basketball", href: "/mens-basketball/news" },
  { label: "Radio", href: "/buffstampede-radio" },
  { label: "Support", href: "/support" },
  { label: "About", href: "/about" },
  { label: "What's Coming", href: "/whats-coming" },
  { label: "Our Team", href: "/our-team" },
  { label: "Contact", href: "/contact" },
  { label: "Advertising", href: "/advertising" },
];

const FALLBACK_NOTES = [
  "Independent of the University of Colorado",
  "Covering CU since 2003",
];

export default class BsFooter extends Component {
  get mainSiteUrl() {
    return (settings.main_site_url || "").replace(/\/$/, "");
  }

  get logoUrl() {
    return settings.masthead_logo_url;
  }

  get links() {
    const live = livePayload()?.footer?.links;

    if (Array.isArray(live) && live.length) {
      return live;
    }

    return FALLBACK_LINKS.map((link) => ({
      label: link.label,
      href: `${this.mainSiteUrl}${link.href}`,
    }));
  }

  get notes() {
    const live = livePayload()?.footer?.notes;

    return Array.isArray(live) && live.length ? live : FALLBACK_NOTES;
  }

  get socials() {
    return socialItems();
  }

  get year() {
    return new Date().getFullYear();
  }

  <template>
    <div class="bs-footer">
      <div class="bs-footer__top">
        {{#if this.logoUrl}}
          <a class="bs-footer__logo" href={{this.mainSiteUrl}}>
            <img src={{this.logoUrl}} alt="BuffStampede" />
          </a>
        {{/if}}

        {{#if this.socials.length}}
          <div class="bs-footer__socials">
            <p class="bs-footer__label">Follow Us</p>
            <div class="bs-footer__social-row">
              {{#each this.socials as |social|}}
                <a
                  href={{social.url}}
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label={{social.label}}
                >
                  <svg
                    width="20"
                    height="20"
                    viewBox={{if social.viewBox social.viewBox "0 0 24 24"}}
                    fill="currentColor"
                    aria-hidden="true"
                  ><path d={{social.path}} /></svg>
                </a>
              {{/each}}
            </div>
          </div>
        {{/if}}
      </div>

      <div class="bs-footer__rule"></div>

      <div class="bs-footer__bottom">
        <nav class="bs-footer__links">
          {{#each this.links as |link|}}
            <a href={{link.href}}>{{link.label}}</a>
          {{/each}}
        </nav>

        <p class="bs-footer__legal">
          &copy; {{this.year}} BuffStampede
          {{#each this.notes as |note|}}
            <span class="bs-footer__sep" aria-hidden="true">·</span>
            {{note}}
          {{/each}}
        </p>
      </div>
    </div>
  </template>
}
