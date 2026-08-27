import Component from "@glimmer/component";
import { eq } from "discourse/truth-helpers";
import { navItems } from "../../lib/bs-nav-config";

// The site's section nav, rendered inside Discourse's own header between the
// logo and the search / notifications / avatar icons.
//
// `before-header-panel` is the outlet declared in Discourse's header contents
// component immediately before `.panel`, which holds the icons. Because
// `.panel` is `margin-left: auto`, anything in this outlet naturally occupies
// the space between the logo and the icons.
//
// This was first written against `home-logo__after`. That outlet also sits in
// the right place visually, but it renders inside `.home-logo-wrapper-outlet`,
// which Discourse gives `overflow: hidden` so oversized logos can be clipped.
// A nav inside a clipping box would clip the dropdowns, so the nav lives
// outside it.
//
// Dropdowns open on hover and on keyboard focus, in CSS, exactly as
// components/Nav.jsx does it on the site. Below 680px this whole nav is hidden
// and the sections move into Discourse's hamburger panel — again matching the
// site, which swaps to a hamburger at the same breakpoint.
export default class BsHeaderNav extends Component {
  get items() {
    return navItems();
  }

  // Inside a topic, Discourse docks the topic title into the header. The title
  // and a full row of section links cannot both fit, so the links step aside —
  // the same trade-off Discourse's own Custom Header Links component makes.
  get hidden() {
    return (
      settings.hide_nav_on_topic_pages && this.args.outletArgs?.topicInfoVisible
    );
  }

  <template>
    {{#unless this.hidden}}
      <nav class="bs-nav" aria-label="BuffStampede sections">
        {{#each this.items as |item|}}
          <div
            class="bs-nav__group
              {{if item.current 'bs-nav__group--current'}}
              {{if (eq item.variant 'button-gold') 'bs-nav__group--button'}}"
          >
            <a
              class="bs-nav__link
                {{if item.current 'bs-nav__link--current'}}
                {{if (eq item.variant 'button-gold') 'bs-nav__link--button'}}"
              href={{item.url}}
            >
              <span class="bs-nav__label">{{item.label}}</span>
              {{#if item.children}}
                <svg
                  class="bs-nav__caret"
                  width="8"
                  height="5"
                  viewBox="0 0 8 5"
                  fill="none"
                  aria-hidden="true"
                ><path
                    d="M1 1l3 3 3-3"
                    stroke="currentColor"
                    stroke-width="1.5"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  /></svg>
              {{/if}}
            </a>

            {{#if item.children}}
              <div class="bs-nav__dropdown">
                {{#each item.children as |child|}}
                  <a class="bs-nav__dropdown-link" href={{child.url}}>
                    {{child.label}}
                  </a>
                {{/each}}
              </div>
            {{/if}}
          </div>
        {{/each}}
      </nav>
    {{/unless}}
  </template>
}
