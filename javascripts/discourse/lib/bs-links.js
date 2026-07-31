// Shared parser for the pipe-delimited theme settings lists.
//
// Discourse hands a `type: list` setting to JavaScript as a single string with
// entries separated by "|". Each of our entries is comma separated, so
// "Football,https://…|The Board,/" becomes two records. Keeping the parsing in
// one place means the nav band and the top bar cannot drift apart.

function splitEntries(value) {
  if (!value) {
    return [];
  }

  return String(value)
    .split("|")
    .map((entry) => entry.trim())
    .filter(Boolean);
}

export function parseNavLinks(value) {
  return splitEntries(value)
    .map((entry) => {
      const [label, url] = entry.split(",").map((part) => (part || "").trim());

      if (!label || !url) {
        return null;
      }

      // A relative URL points somewhere inside the forum, which is the section
      // the reader is currently in. The main site highlights the active section
      // in gold, so we do the same rather than hardcoding "The Board".
      return { label, url, internal: url.startsWith("/") };
    })
    .filter(Boolean);
}

export function parseSocialLinks(value) {
  return splitEntries(value)
    .map((entry) => {
      const [label, url, icon] = entry
        .split(",")
        .map((part) => (part || "").trim());

      if (!label || !url) {
        return null;
      }

      return { label, url, icon: (icon || "").toLowerCase() };
    })
    .filter(Boolean);
}
