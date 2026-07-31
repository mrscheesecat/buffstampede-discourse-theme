// The site's navigation tree.
//
// This mirrors NAV_ITEMS in components/Nav.jsx in the site repo, item for item,
// including which sections have dropdowns. Relative URLs are resolved against
// the `main site url` theme setting, except "/" which means the forum itself.
//
// Keeping a second copy of a structure is how the previous theme's nav ended up
// missing the Support link, so this file is deliberately the only copy in the
// theme and it is shaped exactly like the site's so a diff between the two is
// easy to read. If it drifts again, the durable fix is to serve the tree from
// the site at /api/nav and fetch it here, with this array as the fallback.

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

export function navItems() {
  const base = settings.main_site_url || "https://www.buffstampede.com";

  return NAV_ITEMS.map((item) => {
    const resolved = resolve(item, base);

    if (item.children) {
      resolved.children = item.children.map((child) => resolve(child, base));
    }

    return resolved;
  });
}
