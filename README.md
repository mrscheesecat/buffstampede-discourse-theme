# BuffStampede Board — Discourse theme

The theme for [The Board](https://forum.buffstampede.com), the community forum for
[buffstampede.com](https://www.buffstampede.com). Installed into Discourse as a remote
theme from this repository, so every change is a commit rather than an edit in an
admin textarea.

## How the header works

The goal is that a reader moving from the site to the forum does not notice the
handoff. That is done with three bands:

| Band | What it is | Where it comes from | Sticky? |
|---|---|---|---|
| 1 | Thin dark bar: date, social links, account | `above-site-header` connector | No, scrolls away |
| 2 | Centered BuffStampede wordmark | `above-site-header` connector | No, scrolls away |
| 3 | Section nav, search | Discourse's own `.d-header` | Yes |
| 4 | Breadcrumb, title, forum controls | `below-site-header` connector | Yes, under band 3 |

Scrolling leaves bands 3 and 4 docked at the top, the black nav row with the
light board bar beneath it. Band 4 drops its title when docked, so what stays
pinned is a breadcrumb row and two icons.

## Band 4, the board bar

A copy of `components/PageHeader.jsx` from the site: `#e8e8e4`, a 3px gold rule,
1240px container, breadcrumb at 0.8rem / 700 / 0.06em uppercase, display-face
title. Every section of the site has this band, so the forum has it too.

It exists to empty the right side of band 3. Discourse put search, chat, a
hamburger and an avatar there; the site's nav row has a search icon and nothing
else, so the two rows could never match. The controls Discourse invented moved
down here, where the site has no counterpart to disagree with.

- **Search stays in band 3.** Same glyph, same position on both surfaces, so it
  reads as one control rather than a forum-specific one.
- **Chat and the hamburger live in band 4.** The hamburger forwards its click to
  Discourse's real `#toggle-hamburger-menu`, hidden rather than removed. Chat is
  a plain link to `/chat`, shown only when `chat_enabled`.
- **No title on a topic page.** Discourse renders the topic title as the H1
  there, and two H1s is a rule the site does not break. Breadcrumb and controls
  only.
- **Pinned with `top: var(--header-offset)`**, Discourse's own variable for the
  real height of its header. This is the pattern Discourse's Horizon theme uses
  for its list controls. No height is written down, and nothing touches
  `.d-header` or its wrapper.
- **`bars` and `comment`** are declared in the `svg_icons` modifier in
  `about.json` so they survive Discourse's icon subsetting.

## Where the account control lives

Band 1, because that is where the site puts it. `components/AuthButtons.jsx` on the
site renders Clerk's UserButton as a 28px square, a 12px divider, then the gold
MY ACCOUNT link, and this theme reproduces that cluster measurement for
measurement from Discourse's own user record. The picture is the same picture:
`discourse connect overrides avatar` is on, so the forum avatar is the Clerk
avatar.

A member must never see themselves twice. So:

- Discourse's Log In and Sign Up buttons in band 3 are hidden permanently. Band 1
  already carries LOGIN and JOIN FREE, and both route through DiscourseConnect.
- Discourse's avatar in band 3 is hidden **only while band 1 is on screen**. Once
  the bands scroll away and the header docks, `bs-docked` is set on the document
  element and Discourse's avatar returns, with its real notification badge and its
  real menu. Otherwise a scrolled reader would have no account control at all.
- `bs-docked` is set by an IntersectionObserver watching the masthead band, in
  `api-initializers/bs-board.gjs`. No band height is written down anywhere, so no
  two numbers can fall out of agreement.
- The band 1 avatar does not reimplement the user menu. It forwards its click to
  Discourse's real `#toggle-current-user`, which is hidden rather than removed, so
  Ember still owns the menu's state, position, and teardown.

The important part is what this theme does **not** do. Discourse already sets
`.d-header-wrap { position: sticky; top: 0 }`. Bands 1 and 2 are rendered as
siblings placed before the header in Discourse's application template, so they
scroll out of view without any help. This theme sets no `position`, no `top`, and
no fixed pixel offset on the header or its wrapper.

The theme this replaced did the opposite: it injected its own sticky header and
then pushed Discourse's header down with `top: 55px` while the injected band was
about 153px tall. Nothing kept those two numbers in agreement, which is why the
header's contents ended up floating in the middle of the page. It also hid the
real logo and painted a 24px fake one with a CSS `::before` background image.

## Rules for changing this theme

1. **No literal hex value or font-family string outside `stylesheets/_tokens.scss`.**
   Those tokens mirror `lib/tokens.js` in the site repo.
2. **Never set `position`, `top`, or a fixed height offset on `.d-header` or
   `.d-header-wrap`.** If something needs to sit below the header, use
   `--header-offset`, which Discourse measures for you.
3. **No `!important`** unless a comment names the Discourse rule that requires it.
4. **Prefer a site setting or a Discourse API over CSS.** Colours go through the
   palette in `about.json`. Fonts go through `--font-family` and
   `--heading-font-family`. Content width goes through `--d-max-width`. The logo
   goes through the Logo site settings. Hiding a feature is a site setting, not a
   `display: none`.
5. **Anything an editor might change belongs in `settings.yml`,** not in code. Nav
   links live there specifically because the previous theme hardcoded a copy of the
   site nav that silently drifted out of date.

## Layout

```
about.json                 theme metadata and the BuffStampede colour palette
settings.yml               editor-facing settings: nav links, socials, logo, width
locales/en.yml             setting descriptions shown in the admin panel
common/common.scss         imports the stylesheet partials, in order
common/head_tag.html       webfont preconnect and stylesheet
stylesheets/_tokens.scss   the only colours and font stacks in the repo
stylesheets/_base.scss     Discourse variables, headings, links, buttons
stylesheets/_chrome.scss   the three header bands and the footer
stylesheets/_lists.scss    list controls, topic list, categories, topic page
javascripts/discourse/
  lib/bs-links.js                              parses the pipe-delimited settings
  lib/bs-nav-config.js                         the nav tree, mirroring Nav.jsx
  components/bs-social-icon.gjs                the four brand marks
  connectors/above-site-header/…               bands 1 and 2
  connectors/before-header-panel/…             the section nav inside the header
  connectors/before-sidebar-sections/…         the sections in the hamburger panel
  api-initializers/bs-board.gjs                sends the header logo to the main site
```

## Discourse APIs used, and why each one

- **`above-site-header` plugin outlet** — declared in Discourse's `application.gjs`
  immediately before `<GlimmerSiteHeader>`. The supported place to put chrome that
  should scroll away above the sticky header.
- **`before-header-panel` outlet** — declared in Discourse's header contents
  component immediately before `.panel`, which holds the icons. Since `.panel` is
  `margin-left: auto`, this outlet naturally occupies the space between the logo
  and the icons, and the nav becomes a real child of `.d-header .contents` that
  inherits the header's flex layout and height. This was first built against
  `home-logo__after`, which is in the right place visually but renders inside
  `.home-logo-wrapper-outlet` — a box Discourse gives `overflow: hidden` so
  oversized logos can be clipped. That clipped the nav, and would have clipped
  the dropdowns.
- **`before-sidebar-sections` outlet** — declared in Discourse's hamburger panel,
  above its Categories and Tags links. Where the site's sections go on mobile.
  Discourse closes the panel automatically when any `a[href]` inside it is
  clicked, which is why the accordion parents are `<summary>` elements rather
  than links.
- **`home-logo-href` value transformer** — the supported way to change where the
  header logo points. Used so the logo goes to the main site, the way it does
  everywhere else on buffstampede.com. The forum home stays reachable through the
  "The Board" nav link.
- **`color_schemes` in `about.json`** — sets `--header_background`,
  `--header_primary`, `--primary`, `--tertiary` and the rest natively, which is why
  almost no colour overrides are needed in CSS.

## Site settings this theme expects

These are Discourse settings, not theme settings, so they are not in this repo.
They are recorded here so the pairing is not lost:

| Setting | Value | Why |
|---|---|---|
| Logo | the square BuffStampede mark | Band 3 shows a small mark; the wordmark is in band 2 |
| Logo small | the square BuffStampede mark | Shown when the header minimizes inside a topic |
| Mobile logo | the square BuffStampede mark | Otherwise Discourse falls back to Logo at full width |
| Navigation menu | Header Dropdown | The nav row is the navigation; a sidebar would duplicate it |
| Enable local logins | off | Clerk is the only identity |
| Auth immediately | on | Sends readers straight to Clerk with no interstitial |

The welcome banner is **not** in that list, because this theme owns it. `enable
welcome banner` is a themeable site setting, meaning the value is stored per theme
rather than globally, so switching the default theme brings the banner back even
if it was switched off for the previous one. That is exactly what happened here.
It is now declared in `about.json` under `theme_site_settings`, so it travels with
the theme and a fresh install gets it right:

```json
"theme_site_settings": { "enable_welcome_banner": false }
```

The banner is off because the masthead already is the welcome, and because while
the banner is showing Discourse hides the search icon in the header — so leaving
it on silently costs the nav row its magnifying glass.

## Working on it

Discourse checks this repository for updates once a day, and the **Check for
Updates** button in the admin panel picks up a commit immediately. To iterate
faster, use the [Discourse Theme CLI](https://meta.discourse.org/t/discourse-theme-cli-console-app-to-help-you-build-themes/82950),
which watches the working directory and pushes on save.
