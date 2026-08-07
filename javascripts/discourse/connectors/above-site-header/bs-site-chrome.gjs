import Component from "@glimmer/component";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import BsSocialIcon from "../../components/bs-social-icon";
import { socialItems } from "../../lib/bs-chrome-source";

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
    return socialItems();
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

  // ── The account cluster ──────────────────────────────────────────────
  // The site draws the member's avatar here, in band 1, through Clerk's
  // UserButton: a 28px square, then a 12px divider rule, then the gold
  // MY ACCOUNT link. See components/AuthButtons.jsx in the site repo.
  //
  // Clerk cannot run inside Discourse, so this draws the same cluster from
  // Discourse's own user record. The picture is identical either way:
  // `discourse connect overrides avatar` is on, so the forum avatar is the
  // Clerk avatar. Discourse's own copy of this control, down in the header
  // icon row, is hidden by CSS while these bands are on screen, so a member
  // never sees themselves twice.

  get displayName() {
    return (
      this.currentUser?.name || this.currentUser?.username || "My account"
    );
  }

  // avatar_template looks like "/user_avatar/…/{size}/13_2.png". 96 is one of
  // the sizes Discourse already generates, and covers a 28px box at 3x.
  get avatarUrl() {
    const template = this.currentUser?.avatar_template;

    if (!template) {
      return null;
    }

    return template.replace("{size}", "96");
  }

  // Discourse has renamed this counter more than once, so read whichever of
  // the two current properties exists rather than pinning to one.
  get unreadCount() {
    return (
      this.currentUser?.all_unread_notifications_count ??
      this.currentUser?.unread_notifications ??
      0
    );
  }

  get hasUnread() {
    return this.unreadCount > 0;
  }

  // Forward the click to Discourse's real toggle rather than reimplementing
  // the user menu. The button is hidden, not removed, so Ember still owns the
  // menu's state, its position, and its teardown — nothing here has to know
  // how any of that works. If a future Discourse renames the id, the member
  // still lands on their account page instead of on a dead control.
  @action
  openUserMenu(event) {
    const toggle = document.getElementById("toggle-current-user");

    if (toggle) {
      event.preventDefault();
      toggle.click();
    } else {
      window.location.href = this.accountUrl;
    }
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
                    <BsSocialIcon
                      @icon={{social.icon}}
                      @viewBox={{social.viewBox}}
                      @path={{social.path}}
                    />
                  </a>
                {{/each}}
              </div>
            {{/if}}

            {{#if this.showAuthLinks}}
              <div class="bs-topbar__auth">
                {{#if this.signedIn}}
                  {{#if this.avatarUrl}}
                    <button
                      type="button"
                      class="bs-topbar__avatar"
                      aria-label="Notifications and account"
                      {{on "click" this.openUserMenu}}
                    >
                      <img
                        src={{this.avatarUrl}}
                        alt={{this.displayName}}
                        width="28"
                        height="28"
                      />
                      {{#if this.hasUnread}}
                        <span
                          class="bs-topbar__avatar-dot"
                          aria-hidden="true"
                        ></span>
                      {{/if}}
                    </button>
                  {{/if}}

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
