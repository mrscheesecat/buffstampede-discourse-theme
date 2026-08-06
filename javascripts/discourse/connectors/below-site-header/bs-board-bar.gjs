import Component from "@glimmer/component";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { service } from "@ember/service";

// Band 4: the board bar.
//
// PageHeader.jsx on the site renders a light grey band with a gold rule under
// every section: breadcrumb, then optionally a large title. This is that band,
// on the forum, carrying the controls Discourse has and the site does not.
//
// Why it exists. Band 3 is Discourse's header, and it was carrying search,
// chat, a hamburger and an avatar on its right side. The site's nav row has a
// search icon and nothing else, so the right half of the two rows never
// matched. Moving the controls Discourse invented into a band the site has no
// counterpart for leaves nothing to compare, and gives the forum the same
// breadcrumb bar as every other section of the site.
//
// Search stays in band 3. It is a magnifying glass in the same position on both
// surfaces, so it reads as the same control rather than a forum-specific one.
// Only chat and the hamburger, which have no site equivalent, move down here.
//
// The icons are inline SVG, and the hamburger is the exact glyph from
// components/Nav.jsx. The first version of this file imported Discourse's icon
// component from a path that does not exist, and because Discourse compiles a
// theme's JavaScript into one bundle, that single bad import took down every
// band at once on the live forum. Nothing in this file imports a Discourse
// component, so no Discourse rename can do that again. See the import rule in
// common/common.scss.
export default class BsBoardBar extends Component {
  @service router;
  @service site;
  @service siteSettings;

  get mainSiteUrl() {
    return (settings.main_site_url || "").replace(/\/$/, "");
  }

  get routeName() {
    return this.router.currentRouteName || "";
  }

  // A topic page already has an H1: Discourse renders the topic title as one.
  // Two H1s on a page is a rule the site does not break, so this band shows
  // the breadcrumb and the controls there and no title at all.
  get isTopic() {
    return this.routeName.startsWith("topic.");
  }

  // The category, read from whichever place the current route keeps it. Every
  // lookup is optional and the whole thing degrades to no crumb rather than to
  // an error, because a missing third crumb is a cosmetic problem and a broken
  // header is not.
  get category() {
    let route = this.router.currentRoute;

    while (route) {
      if (route.attributes?.category) {
        return route.attributes.category;
      }

      const slugPath =
        route.params?.category_slug_path_with_id || route.params?.slug;

      if (slugPath) {
        const slug = String(slugPath).split("/").filter(Boolean).pop();
        const match = this.site?.categories?.find(
          (c) => c.slug === slug || String(c.id) === slug
        );

        if (match) {
          return match;
        }
      }

      route = route.parent;
    }

    return null;
  }

  get crumbs() {
    const trail = [
      { label: "Home", href: `${this.mainSiteUrl}/` },
      { label: "The Board", href: "/" },
    ];

    const category = this.category;

    if (category) {
      trail.push({ label: category.name });
    }

    return trail.map((crumb, i) => ({
      ...crumb,
      isLast: i === trail.length - 1,
      showSeparator: i > 0,
    }));
  }

  // The welcome banner is off in this theme, so no discovery page renders a
  // heading of its own and this one is safe to make an H1.
  get title() {
    if (this.isTopic) {
      return null;
    }

    return this.category?.name || "The Board";
  }

  get chatEnabled() {
    return this.siteSettings?.chat_enabled;
  }

  // Same approach as the account button in band 1: hand the click to the
  // control Discourse already rendered, hidden but alive, so Ember keeps
  // owning the drawer's state and position. Nothing here reimplements a menu.
  @action
  toggleHamburger(event) {
    const toggle = document.getElementById("toggle-hamburger-menu");

    if (toggle) {
      event.preventDefault();
      toggle.click();
    }
  }

  <template>
    <div class="bs-board-bar">
      <div class="bs-board-bar__inner">
        <div class="bs-board-bar__crumbs">
          {{#each this.crumbs as |crumb|}}
            <span class="bs-board-bar__crumb">
              {{#if crumb.showSeparator}}
                <span class="bs-board-bar__sep" aria-hidden="true">›</span>
              {{/if}}

              {{#if crumb.isLast}}
                <span class="bs-board-bar__current">{{crumb.label}}</span>
              {{else}}
                <a href={{crumb.href}}>{{crumb.label}}</a>
              {{/if}}
            </span>
          {{/each}}
        </div>

        <div class="bs-board-bar__controls">
          {{#if this.chatEnabled}}
            <a
              class="bs-board-bar__control bs-board-bar__control--chat"
              href="/chat"
              title="Chat"
              aria-label="Chat"
            >
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2.2"
                stroke-linecap="round"
                stroke-linejoin="round"
                aria-hidden="true"
              ><path
                  d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"
                /></svg>
            </a>
          {{/if}}

          {{! Hidden at 680px and below, where Discourse's own hamburger comes
              back in band 3 to match the site's mobile nav row. }}
          <button
            type="button"
            class="bs-board-bar__control bs-board-bar__control--menu"
            title="Forum menu"
            aria-label="Forum menu"
            {{on "click" this.toggleHamburger}}
          >
            {{! The site's own hamburger, from components/Nav.jsx }}
            <svg
              width="22"
              height="22"
              viewBox="0 0 22 22"
              fill="none"
              aria-hidden="true"
            ><path
                d="M3 6h16M3 11h16M3 16h16"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
              /></svg>
          </button>
        </div>
      </div>

      {{#if this.title}}
        <div class="bs-board-bar__inner bs-board-bar__inner--title">
          <h1 class="bs-board-bar__title">{{this.title}}</h1>
        </div>
      {{/if}}
    </div>
  </template>
}
