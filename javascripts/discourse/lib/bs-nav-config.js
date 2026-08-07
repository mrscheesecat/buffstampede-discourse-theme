// The site's navigation tree, as a fallback.
//
// The live tree comes from buffstampede.com/api/chrome now, read by
// bs-chrome-source.js. This array is what renders on a first visit before the
// fetch lands, and whenever the fetch cannot be made at all. It is allowed to
// go a little stale; it is not allowed to be missing.
//
// This mirrors NAV_ITEMS in components/Nav.jsx in the site repo, item for item,
// including which sections have dropdowns. Relative URLs are resolved against
// the `main site url` theme setting, except "/" which means the forum itself.
//
// Keeping a second copy of a structure is how the previous theme's nav ended up
// missing the Support link, so this file is deliberately the only copy in the
// theme and it is shaped exactly like the site's so a diff between the two is
// easy to read.
//
// That comment used to end by saying the durable fix was to serve the tree from
// the site and fetch it here, with this array as the fallback. That is now what
// happens, so the three drifts this file had accumulated by August 6 (Support
// and About in the wrong order, a Game Day Hub item the site has never had, and
// a missing What's Coming) correct themselves the moment the fetch lands. They
// are left in place below rather than hand-corrected, because a fallback that
// somebody edits by hand is exactly the thing that drifted.

import { livePayload } from "./bs-chrome-source";

const NAV_ITEMS = [
  {
    label: "Football",
    href: "/football",
    children: [
      { label: "News", href: "/football/news" },
      { label: "Recruiting", href: "/football/recruiting" },
      { label: "Game Day Hub", href: "/football/game-day" },
      { label: "Schedule", href: "/football/schedule" },
      { label: "Roster", href: "/roster?sport=football" },
      { label: "Coaches", href: "/coaches?sport=football" },
    ],
  },
  {
    label: "Men's Basketball",
    href: "/mens-basketball",
    children: [
      { label: "News", href: "/mens-basketball/news" },
      { label: "Recruiting", href: "/mens-basketball/recruiting" },
      { label: "Game Day Hub", href: "/mens-basketball/game-day" },
      { label: "Schedule", href: "/mens-basketball/schedule" },
      { label: "Roster", href: "/roster?sport=mens-basketball" },
      { label: "Coaches", href: "/coaches?sport=mens-basketball" },
    ],
  },
  {
    label: "BuffStampede Radio",
    href: "/buffstampede-radio",
  },
  {
    // The section the reader is already in. Points at the forum root rather
    // than the main site, and is highlighted the way the site highlights the
    // active section.
    label: "The Board",
    href: "/",
    forum: true,
  },
  {
    label: "Support",
    href: "/support",
  },
  {
    label: "About",
    href: "/about",
    children: [
      { label: "About BuffStampede", href: "/about" },
      { label: "Our Team", href: "/our-team" },
      { label: "Contact", href: "/contact" },
      { label: "Advertising", href: "/advertising" },
    ],
  },
];

function resolve(item, base) {
  if (item.forum) {
    return { ...item, url: item.href, current: true };
  }

  return {
    ...item,
    url: `${base.replace(/\/$/, "")}${item.href}`,
    current: false,
  };
}

// The Board as this theme renders it: pointing at the forum root rather than
// the main site, and marked as the section the reader is already in.
function boardItem(label) {
  return { label, url: "/", forum: true, current: true };
}

// The live tree, in the shape the nav components already expect. The site
// sends absolute URLs, so there is nothing to resolve here.
function fromPayload(payload) {
  const items = payload.nav.map((item) => {
    const mapped = { ...item, url: item.href, current: false };

    if (item.children) {
      mapped.children = item.children.map((child) => ({
        ...child,
        url: child.href,
        current: false,
      }));
    }

    return mapped;
  });

  const { label, index, shownOnSite } = payload.board;
  const existing = items.findIndex((item) => item.label === label);

  if (existing >= 0) {
    // The site is showing The Board, so it is already in the right place. Point
    // it at the forum root and light it up.
    items[existing] = boardItem(label);
  } else if (!shownOnSite) {
    // The site hides The Board pre-launch, but a reader standing on the forum
    // should still see where they are. Slot it into the position it would
    // occupy on the site rather than appending it somewhere the site never
    // puts it.
    const at = Number.isInteger(index) ? Math.min(index, items.length) : items.length;
    items.splice(at, 0, boardItem(label));
  }

  return items;
}

export function navItems() {
  const payload = livePayload();

  if (payload) {
    return fromPayload(payload);
  }

  const base = settings.main_site_url || "https://www.buffstampede.com";

  return NAV_ITEMS.map((item) => {
    const resolved = resolve(item, base);

    if (item.children) {
      resolved.children = item.children.map((child) => resolve(child, base));
    }

    return resolved;
  });
}
