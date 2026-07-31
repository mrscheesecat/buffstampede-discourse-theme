import Component from "@glimmer/component";
import { parseNavLinks } from "../../lib/bs-links";

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
// A nav inside a clipping box sized for a logo is a bug waiting to happen, so
// the nav lives outside it.
export default class BsHeaderNav extends Component {
  get links() {
    return parseNavLinks(settings.site_nav_links);
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
        {{#each this.links as |link|}}
          <a
            class="bs-nav__link
              {{if link.internal 'bs-nav__link--current'}}"
            href={{link.url}}
          >
            <span class="bs-nav__label">{{link.label}}</span>
          </a>
        {{/each}}
      </nav>
    {{/unless}}
  </template>
}
