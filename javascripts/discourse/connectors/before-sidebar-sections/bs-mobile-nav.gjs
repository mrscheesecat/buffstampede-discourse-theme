import Component from "@glimmer/component";
import BsSocialIcon from "../../components/bs-social-icon";
import { socialItems } from "../../lib/bs-chrome-source";
import { navItems } from "../../lib/bs-nav-config";

// The site's sections inside Discourse's hamburger panel.
//
// Below 680px the site replaces its nav row with a hamburger that opens an
// accordion of sections with the social icons at the bottom. Discourse already
// has a hamburger in that exact position, so rather than building a second one
// the sections go into Discourse's own panel through the
// `before-sidebar-sections` outlet, above Discourse's Categories and Tags
// links. One menu, in the place a reader already expects it.
//
// The accordions are <details>/<summary>, so opening and closing needs no
// JavaScript and stays keyboard and screen-reader accessible. Discourse closes
// the panel automatically when any `a[href]` inside it is clicked, which is why
// the parent rows are summaries rather than links.
export default class BsMobileNav extends Component {
  get items() {
    return navItems();
  }

  get socials() {
    return socialItems();
  }

  <template>
    <div class="bs-mobile-nav">
      {{#each this.items as |item|}}
        {{#if item.children}}
          <details class="bs-mobile-nav__group">
            <summary class="bs-mobile-nav__summary">
              <span>{{item.label}}</span>
              <svg
                class="bs-mobile-nav__caret"
                width="10"
                height="6"
                viewBox="0 0 10 6"
                fill="none"
                aria-hidden="true"
              ><path
                  d="M1 1l4 4 4-4"
                  stroke="currentColor"
                  stroke-width="1.5"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                /></svg>
            </summary>
            <div class="bs-mobile-nav__children">
              {{#each item.children as |child|}}
                <a class="bs-mobile-nav__child" href={{child.url}}>
                  {{child.label}}
                </a>
              {{/each}}
            </div>
          </details>
        {{else}}
          <a
            class="bs-mobile-nav__link
              {{if item.current 'bs-mobile-nav__link--current'}}"
            href={{item.url}}
          >{{item.label}}</a>
        {{/if}}
      {{/each}}

      {{#if this.socials}}
        <div class="bs-mobile-nav__socials">
          {{#each this.socials as |social|}}
            <a
              href={{social.url}}
              target="_blank"
              rel="noopener noreferrer"
              aria-label={{social.label}}
            >
              <BsSocialIcon
                      @icon={{social.icon}}
                      @viewBox={{social.viewBox}}
                      @path={{social.path}}
                    />
            </a>
          {{/each}}
        </div>
      {{/if}}
    </div>
  </template>
}
