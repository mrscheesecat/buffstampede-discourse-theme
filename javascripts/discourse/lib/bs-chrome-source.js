import { tracked } from "@glimmer/tracking";
import { parseSocialLinks } from "./bs-links";

// Reads the site's header from the site instead of restating it.
//
// buffstampede.com serves its nav, its socials and its design tokens as JSON at
// /api/chrome. Before that existed, this theme kept its own copy of the nav and
// the socials, and the two drifted three ways in a month with nobody editing
// either on purpose: Support and About swapped places, a Game Day Hub item
// appeared in both sport dropdowns that the site has never had, and the social
// row lost TikTok.
//
// How this behaves, in order:
//
//   1. On boot, the last payload is read out of localStorage and rendered
//      immediately. No network wait, no flash of a different nav.
//   2. A fetch goes out in the background. If it succeeds, the store updates
//      and the header re-renders in place.
//   3. If there is no cache and no successful fetch, every caller falls back to
//      the arrays bundled with this theme.
//
// So the worst case is the behaviour we had before this file existed, and the
// normal case is that changing the nav on the site changes it here on the next
// page load. Nothing here can leave the header empty.
//
// Imports nothing from Discourse. See rule 4 in common/common.scss.

const CACHE_KEY = "bs-chrome-v1";
const PAYLOAD_VERSION = 1;
const FETCH_TIMEOUT_MS = 5000;

class ChromeStore {
  @tracked payload = null;
}

export const chromeStore = new ChromeStore();

// A payload is only usable if it has the pieces every caller needs. Anything
// short of that is treated as absent, so a half-written cache entry or a future
// version of the endpoint falls back rather than rendering a broken header.
function isUsable(payload) {
  return Boolean(
    payload &&
      payload.version === PAYLOAD_VERSION &&
      Array.isArray(payload.nav) &&
      payload.nav.length &&
      Array.isArray(payload.socials) &&
      payload.board &&
      typeof payload.board.label === "string"
  );
}

// localStorage throws rather than returning null in Safari's private mode and
// when storage is full, so every access is guarded. A cache miss is not an
// error condition here, it is just the first visit.
function readCache() {
  try {
    const raw = window.localStorage.getItem(CACHE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function writeCache(payload) {
  try {
    window.localStorage.setItem(CACHE_KEY, JSON.stringify(payload));
  } catch {
    // Nothing to do. The next page load fetches again.
  }
}

async function fetchChrome(baseUrl) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);

  try {
    const response = await fetch(`${baseUrl}/api/chrome`, {
      signal: controller.signal,
      credentials: "omit",
    });

    if (!response.ok) {
      return null;
    }

    return await response.json();
  } catch {
    // Offline, blocked by a content policy, timed out, or the endpoint is
    // having a bad day. The cache or the bundled fallback covers all of them.
    return null;
  } finally {
    clearTimeout(timer);
  }
}

export async function loadChrome() {
  const baseUrl = (settings.main_site_url || "").replace(/\/$/, "");

  const cached = readCache();

  if (isUsable(cached)) {
    chromeStore.payload = cached;
  }

  if (!baseUrl) {
    return;
  }

  const fresh = await fetchChrome(baseUrl);

  if (isUsable(fresh)) {
    chromeStore.payload = fresh;
    writeCache(fresh);
  }
}

export function livePayload() {
  return chromeStore.payload;
}

// The social row, in the shape the top bar and the mobile menu already expect.
//
// The site sends the icon's viewBox and path data along with each account, so a
// network this theme has never drawn renders correctly without anyone adding a
// glyph here. That is how TikTok, missing from the theme's own list since July,
// appears the moment the fetch lands.
//
// The icon key is still derived and passed along so the bundled glyphs remain
// the fallback if a payload ever arrives without path data.
export function socialItems() {
  const payload = livePayload();

  if (!payload) {
    return parseSocialLinks(settings.topbar_socials);
  }

  return payload.socials.map((social) => ({
    label: social.label,
    url: social.href,
    icon: String(social.label || "")
      .toLowerCase()
      .replace(/[^a-z].*$/, ""),
    viewBox: social.viewBox,
    path: social.path,
  }));
}
