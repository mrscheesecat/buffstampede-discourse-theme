import Component from "@glimmer/component";
import { parseNavLinks } from "../../lib/bs-links";

// The site's section nav, rendered inside Discourse's own header immediately
// after the logo.
//
// `home-logo__after` is the supported connector for this position: the
// `home-logo` plugin outlet is declared in Discourse's header component, and
// Discourse resolves the `__after` suffix to "render after the outlet's default
// content". Using it means the nav is a real child of `.d-header .contents`, so
// it inherits the header's flex layout, sticky behaviour, and height instead of
// being absolutely positioned on top of it.
export default class BsHeaderNav extends Component {
  get links() {
    return parseNavLinks(settings.site_nav_links);
  }

  // Inside a topic, Discourse docks the topic title into the header and passes
  // `minimized: true` down through the home-logo outlet. The title and a full
  // row of section links cannot both fit, so the links step aside — the same
  // trade-off Discourse's own Custom Header Links component makes.
  get hidden() {
    return settings.hide_nav_on_topic_pages && this.args.outletArgs?.minimized;
  }

  <template>
    {{#unless this.hidden}}
      <nav class="bs-nav" aria-label="BuffStampede sections">
        {{#each this.links as |link|}}
          <a
            class="bs-nav__link {{if link.internal 'bs-nav__link--current'}}"
            href={{link.url}}
          >{{link.label}}</a>
        {{/each}}
      </nav>
    {{/unless}}
  </template>
}
