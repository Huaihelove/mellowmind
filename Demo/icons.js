(() => {
  "use strict";

  // Wobbly, intentionally imperfect line icons. Every icon inherits currentColor.
  const icons = {
    home: '<path d="M12.2 3.1c.2.9.1 1.8 0 2.7M12 18.2c.1.9.2 1.8 0 2.7M3.3 12.2c.9-.2 1.8-.1 2.7 0M18 12c.9-.1 1.8 0 2.7.2"/><path d="M12.3 8.2c2-.1 3.7 1.5 3.8 3.5.1 1.9-1.4 3.5-3.3 3.7-2 .2-3.7-1.3-3.8-3.3-.1-1.8 1.3-3.4 3.1-3.7Z"/><path d="M5.8 5.9c.5.5 1 .9 1.5 1.2M16.9 16.7c.4.5.8.9 1.4 1.4M18.2 5.8c-.5.5-.9 1-1.2 1.5M7.1 16.8c-.4.5-.8 1-1.2 1.5"/>',
    profile: '<path d="M12.1 4.3c2 0 3.6 1.5 3.7 3.5.1 2.2-1.5 3.8-3.7 3.9-2.1.1-3.7-1.5-3.8-3.6-.1-2 1.6-3.7 3.6-3.8Z"/><path d="M4.7 20.3c.7-3.6 3.4-5.7 7.3-5.8 4-.1 6.7 1.8 7.4 5.5"/><path d="M9.1 19.4c1.9-.7 3.9-.7 5.9 0"/>',
    cards: '<path d="M6.7 4.1c3.5-.5 6.9-.4 10.1.4.8.2 1.2.8 1.1 1.6-.3 3.8-.4 7.6-.4 11.4 0 .8-.5 1.3-1.3 1.3-3.2.1-6.4.2-9.6.1-.8 0-1.3-.5-1.3-1.3 0-3.8-.1-7.5-.5-11.2-.1-.8.5-1.7 1.2-1.9.2 0 .4-.1.7-.4Z"/><path d="M3.9 8.3c-.1 3.2 0 6.4.3 9.5.1.9.6 1.4 1.5 1.6 2 .4 4 .6 6 .7M9.7 8.2c1.2-.3 2.4-.3 3.6 0M9.7 11.1c.9-.2 1.9-.2 2.8 0"/>',
    spark: '<path d="M12.2 3.3c.4 3.3 1.4 5.7 2.9 7.2 1.4 1.5 3.2 2.3 5.5 2.7-2.4.4-4.2 1.2-5.6 2.7-1.5 1.5-2.4 3.8-2.8 7.1-.4-3.2-1.3-5.5-2.8-7.1-1.4-1.5-3.3-2.4-5.7-2.8 2.3-.4 4.2-1.2 5.7-2.7 1.4-1.5 2.3-3.9 2.8-7.1Z"/><path d="M18.8 3.7c.1 1.1.4 1.8.8 2.3.4.4 1 .7 1.7.8-.8.2-1.3.4-1.7.8-.4.4-.7 1.1-.8 2.3-.1-1.2-.4-1.9-.8-2.3-.4-.4-1-.6-1.7-.8.7-.1 1.3-.4 1.7-.8.4-.5.7-1.2.8-2.3Z"/>',
    calendar: '<path d="M4.3 6.2c0-.8.5-1.3 1.3-1.4 4.3-.5 8.6-.5 12.9.1.7.1 1.2.6 1.2 1.3.1 4.4.1 8.8-.1 13.2 0 .7-.5 1.2-1.2 1.3-4.3.5-8.6.5-12.9 0-.8-.1-1.3-.6-1.3-1.4-.1-4.3-.1-8.7.1-13.1Z"/><path d="M7.4 3.7c.1 1.2.1 2.3 0 3.5M16.4 3.6c.1 1.2.2 2.4.1 3.6M4.1 9.4c4.9.4 9.8.4 15.6 0M8 13.1h.1M12 13.2h.1M16.1 13.2h.1M8.1 16.7h.1M12.1 16.6h.1"/>',
    heart: '<path d="M12.1 20.1c-.4-.5-.9-.9-1.4-1.3-2.2-1.9-4.3-3.7-5.5-6-1.1-2.1-.7-4.6 1-6 1.7-1.5 4.4-1.2 5.8.7.6-.6 1.1-1.1 1.8-1.5 2-1.1 4.4-.4 5.5 1.5 1.3 2.2.6 4.8-.9 6.7-1.5 2-3.5 3.7-5.4 5.2-.3.2-.6.4-.9.7Z"/><path d="M8.2 11.3c1.4.3 2.8-.1 3.8-1.2"/>',
    grid: '<path d="M4.6 5.4c0-.4.3-.7.7-.8 1.5-.1 3-.1 4.5 0 .4 0 .7.3.7.7.1 1.6.1 3.2 0 4.7 0 .4-.3.7-.7.7-1.5.1-3 .1-4.5 0-.4 0-.7-.3-.7-.7-.1-1.5-.1-3.1 0-4.6Z"/><path d="M14 5.2c1.6-.2 3.2-.2 4.8 0 .3 0 .6.3.6.6 0 1.6 0 3.2-.1 4.8 0 .4-.3.6-.6.7-1.6.1-3.2.1-4.8 0-.4 0-.6-.3-.7-.7V5.8c0-.3.3-.5.8-.6Z"/><path d="M4.5 14.2c1.6-.2 3.2-.2 4.8 0 .3 0 .6.3.6.6 0 1.6 0 3.2-.1 4.8 0 .3-.2.6-.6.7-1.6.1-3.2.1-4.8 0-.4 0-.6-.3-.7-.7v-4.7c0-.3.3-.6.8-.7Z"/><path d="M14 14c1.6-.2 3.2-.2 4.8 0 .4 0 .6.3.7.7v4.7c0 .4-.3.7-.7.7-1.6.2-3.2.2-4.8 0-.4 0-.6-.3-.7-.7v-4.7c0-.4.3-.6.7-.7Z"/>',
    theme: '<path d="M19.4 15.2c-1.7 1.4-3.8 2.2-6 2-4.1-.3-7-3.8-6.6-7.9.3-3.1 2.4-5.6 5.3-6.3-2.1 2.5-2.5 6.1-.8 9 1.6 2.7 4.7 4.1 8.1 3.2Z"/><path d="M17.3 3.6c.1 1.1.5 1.8.9 2.2.4.4 1 .7 1.8.8-.8.2-1.4.4-1.8.8-.4.4-.8 1.2-.9 2.2-.1-1.1-.5-1.8-.9-2.2-.4-.4-1-.6-1.8-.8.8-.1 1.4-.4 1.8-.8.4-.4.8-1.1.9-2.2Z"/>',
    settings: '<path d="M12.1 8.8c1.8-.1 3.4 1.3 3.5 3.1.1 1.9-1.3 3.4-3.2 3.5-1.8.1-3.4-1.3-3.5-3.1-.1-1.8 1.3-3.4 3.2-3.5Z"/><path d="M12 2.9c.2 1 .2 1.9.1 2.9M12 18.2c.1 1 .1 1.9 0 2.9M2.8 12c1-.2 2-.2 3-.1M18.2 12c1-.1 2-.1 3 0M5.5 5.5c.7.7 1.4 1.4 2 2.1M16.5 16.5c.7.7 1.4 1.4 2.1 2M18.5 5.6c-.7.7-1.4 1.4-2.1 2M7.5 16.5c-.7.7-1.4 1.4-2 2.1"/>',
    restart: '<path d="M19.2 8.6c-1.4-2.5-3.9-4-6.8-4-4.2.1-7.6 3.6-7.5 7.8.1 4.2 3.6 7.5 7.8 7.4 3.2-.1 5.9-2.1 7-5"/><path d="M19.5 3.8c-.1 1.6-.2 3.2-.2 4.8-1.4.4-2.8.7-4.2.9"/>',
    shield: '<path d="M12.1 3.2c2.5.8 4.8 1.7 7.1 2.8-.1 2.3-.1 4.6-.2 6.9-.1 3.1-2.4 5.8-6.6 7.8-4.4-2-6.9-4.7-7-7.9-.1-2.3-.1-4.6-.1-6.8 2.2-1 4.5-1.8 6.8-2.8Z"/><path d="M8.7 12.1c1.3.9 2.5 1.8 3.8 2.9 1.2-2.2 2.5-4 4-5.6"/>',
    gauge: '<path d="M4.1 17.2c-1.5-4.5.8-9.3 5.1-11 4.4-1.7 9.3.5 10.9 4.9.5 1.4.6 2.8.4 4.2"/><path d="M12 13.9c1.5-1.6 3-3.1 4.5-4.6"/><path d="M12 13.9c-.6.3-1.1.9-1.1 1.6 0 .9.7 1.6 1.6 1.6.9 0 1.6-.8 1.5-1.7 0-.7-.6-1.3-1.3-1.5M4.4 17c.8.1 1.6.1 2.4 0M17.5 17.1c.7.1 1.4.1 2.2 0"/>',
    wind: '<path d="M3.7 8.7c3.2-.2 6.3-.1 9.5 0 1.8 0 3.1-2.7 1.4-4-1.1-.8-2.6-.5-3.2.7"/><path d="M3.7 12.2c4.6-.2 9.2-.2 13.8 0 2.2 0 2.7 3.2.5 4.1-1.2.5-2.5 0-3-1.1"/><path d="M3.7 15.7c1.8-.2 3.5-.2 5.2 0"/>',
    compass: '<path d="M12.1 3.3c4.8-.1 8.8 3.8 8.8 8.7 0 4.8-3.8 8.7-8.6 8.8-4.8.1-8.8-3.8-8.8-8.6-.1-4.8 3.7-8.8 8.6-8.9Z"/><path d="M15.7 8.3c-.6 1.8-1.3 3.6-2 5.3-1.7.7-3.4 1.4-5.2 2 .6-1.8 1.2-3.5 1.9-5.3 1.7-.7 3.5-1.4 5.3-2Z"/><path d="M12 11.8c.2.1.4.3.4.6 0 .3-.3.5-.6.5-.3 0-.5-.3-.5-.6s.3-.5.7-.5Z"/>',
    drop: '<path d="M12 3.2c2.7 3.5 5.4 6.3 5.5 9.6.1 3.2-2.4 5.8-5.5 5.8-3.2 0-5.7-2.5-5.6-5.7.1-3.3 2.7-6.2 5.6-9.7Z"/><path d="M9.2 13.5c.2 1.3 1 2.2 2.3 2.5"/>',
    leaf: '<path d="M19.7 4.4c-5.6.3-10.2 2.3-12.9 5.6-2.1 2.6-1.6 5.8.5 7.1 2.2 1.4 5.1.9 7-1.1 2.6-2.7 4.2-6.6 5.4-11.6Z"/><path d="M5.6 20.1c2.3-5.2 5.9-9.1 11.2-11.4M9.5 16.4c-.1-1.6-.6-3-1.6-4.3"/>',
    message: '<path d="M19.9 12.2c.1 4.1-3.4 7.3-7.8 7.3-1 0-1.9-.1-2.8-.4-1.4.7-2.8 1.2-4.4 1.4.4-1.2.9-2.4 1.2-3.6-1.1-1.3-1.7-2.8-1.7-4.4 0-4 3.5-7.2 7.9-7.2 4.4.1 7.5 3.1 7.6 6.9Z"/><path d="M8.3 11.8h.1M12 11.9h.1M15.6 11.8h.1"/>',
    music: '<path d="M9.3 6.6c3-.7 5.9-1.4 8.8-2.3.1 3.5.1 7 0 10.5-.1 2.1-1.8 3.6-3.8 3.6-1.7 0-3-1.1-3.1-2.6-.1-1.8 1.3-3.2 3.1-3.3 1.1 0 2.1.3 2.9.9M9.3 6.7c.1 3.6.1 7.2 0 10.8"/><path d="M7.1 17.5c.1 1.5-1.2 2.8-2.8 2.8-1 0-1.9-.7-2-1.7-.1-1.2.9-2.3 2.1-2.3.9 0 1.8.4 2.6 1.1"/>',
    lock: '<path d="M5.3 10c-.1 3.1-.1 6.3 0 9.4 0 .8.5 1.3 1.3 1.3 3.6.2 7.2.2 10.8 0 .8 0 1.3-.5 1.3-1.3.1-3.1.1-6.3 0-9.4 0-.8-.5-1.3-1.3-1.3-3.6-.2-7.2-.2-10.8 0-.8 0-1.3.5-1.3 1.3Z"/><path d="M8.3 9.8c-.1-1.5 0-3 .2-4.4.4-1.9 2-3.1 3.8-2.9 1.9.2 3.2 1.8 3.1 3.7-.1 1.2-.1 2.4 0 3.6M12 13.5c.1 1.1.1 2.2 0 3.3"/>',
    check: '<path d="M5.2 12.3c1.4 1.3 2.7 2.7 4.1 4.1 3.1-3.3 6.1-6.4 9.5-9.3"/>',
    arrow: '<path d="M4.2 12.1c4.8-.3 9.6-.3 14.4 0M13.9 7.3c1.5 1.5 3 3.1 4.7 4.6-1.7 1.6-3.2 3.2-4.7 4.8"/>',
    book: '<path d="M4.1 5.7c2.7-.9 5.3-.5 7.9 1.3-.1 3.9-.1 7.8 0 11.7-2.6-1.7-5.2-2.1-7.9-1.3-.1-3.9-.1-7.8 0-11.7Z"/><path d="M19.9 5.7c-2.7-.8-5.3-.4-7.9 1.3.1 3.9.1 7.8 0 11.7 2.6-1.7 5.2-2.1 7.9-1.3.1-3.9.1-7.8 0-11.7Z"/>',
    moon: '<path d="M19.1 15.1c-1.3.9-2.9 1.4-4.5 1.3-4.1-.2-7.1-3.7-6.8-7.7.2-3 2.2-5.5 5-6.3-2 2.5-2.4 5.9-.8 8.7 1.4 2.4 3.9 3.8 7.1 4Z"/>',
    close: '<path d="M6.2 5.9c4 3.9 7.9 7.9 11.8 12M18 6.1c-4 3.9-7.9 7.9-11.8 11.8"/>',
    edit: '<path d="M4.7 16.8c-.3 1.1-.6 2.1-.9 3.2 1.1-.3 2.2-.6 3.3-.9 3.8-3.6 7.5-7.3 11.2-11.1-1-1-1.9-2-2.9-2.9-3.6 3.8-7.2 7.7-10.7 11.7Z"/><path d="M14.6 6.9c.8.8 1.7 1.6 2.5 2.5"/>',
    flower: '<path d="M12.1 10c-1.3-1.6-1.4-3.8-.1-5.4 1.8 1.2 2.1 3.3.9 5.2M13.9 11.8c2.1-.8 4.2-.2 5.3 1.7-1.7 1.4-3.9 1.1-5.4-.6M11.8 13.9c.9 2.1.4 4.3-1.5 5.5-1.5-1.7-1.2-4 .4-5.5M10 12c-2.1.9-4.3.4-5.5-1.4 1.6-1.5 3.8-1.2 5.4.4"/><path d="M12 10.2c1-.2 2 .7 1.9 1.7-.1 1-1.1 1.7-2 1.4-1-.3-1.5-1.3-1.1-2.2.2-.5.7-.8 1.2-.9Z"/>',
    cloud: '<path d="M6.5 17.3c-2 .1-3.5-1.4-3.6-3.2-.1-1.7 1.2-3.2 3-3.4.3-2.6 2.4-4.5 5-4.5 2.4 0 4.4 1.6 4.9 3.9 2.2-.2 4.1 1.3 4.3 3.4.2 2-1.3 3.7-3.4 3.8-3.4.2-6.8.2-10.2 0Z"/><path d="M9.2 19.7c1.9.3 3.8.3 5.8 0"/>',
    eye: '<path d="M2.9 12c2.5-3.5 5.6-5.3 9.2-5.4 3.6-.1 6.7 1.7 9 5.3-2.4 3.7-5.5 5.5-9.2 5.5-3.6 0-6.7-1.8-9-5.4Z"/><path d="M12.1 9.3c1.5-.1 2.8 1.1 2.9 2.6.1 1.6-1.1 2.9-2.7 2.9-1.5.1-2.8-1.1-2.8-2.6-.1-1.5 1.1-2.8 2.6-2.9Z"/>'
  };

  const escapeHTML = value => String(value).replace(/[&<>"']/g, ch => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[ch]));

  const svgDefs = `
    <svg class="mm-svg-defs" width="0" height="0" aria-hidden="true" focusable="false">
      <defs>
        <filter id="mm-pencil" x="-18%" y="-18%" width="136%" height="136%" color-interpolation-filters="sRGB">
          <feTurbulence type="fractalNoise" baseFrequency=".045" numOctaves="2" seed="11" result="warp"/>
          <feDisplacementMap in="SourceGraphic" in2="warp" scale=".72" xChannelSelector="R" yChannelSelector="G"/>
        </filter>
      </defs>
    </svg>`;

  const ensureDefs = () => {
    if (document.querySelector(".mm-svg-defs") || !document.body) return;
    document.body.insertAdjacentHTML("afterbegin", svgDefs);
  };

  const svg = (name, className = "ui-icon") => {
    const body = icons[name] || icons.spark;
    return '<svg class="' + className + '" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.55" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><g filter="url(#mm-pencil)">' + body + '</g></svg>';
  };

  const navIcons = { home: "home", profile: "profile", tarot: "cards", wish: "spark", calendar: "calendar", heal: "heart", collection: "book" };
  const pageIcons = { profile: "profile", tarot: "cards", wish: "spark", calendar: "calendar", heal: "leaf", collection: "book" };
  const tabIcons = { tree: "message", dissect: "compass", audio: "music", draw: "spark", wall: "heart", seal: "lock", checkin: "check", cards: "book", store: "grid" };

  const heroLineArt = `
    <svg class="hero-lineart" viewBox="0 0 520 420" aria-hidden="true" focusable="false">
      <g class="hero-art-ink" filter="url(#mm-pencil)">
        <path d="M45 309c8-24 30-39 55-36 5-28 29-48 56-47 23 1 42 16 49 37 25-4 47 11 52 33 24 2 41 18 44 38"/>
        <path d="M89 349c-22 5-38 18-44 38M329 330c26-27 55-43 88-48 18-3 35 1 49 10"/>
        <path d="M49 374c76 18 151 23 226 15 65-7 124-27 176-58"/>
        <path d="M387 270c-23 1-42 14-51 36 24 3 45-10 51-36Z"/>
        <path d="M355 307c13-11 28-20 44-27"/>
        <path d="M81 230c15-12 27-27 36-44M96 174c11-13 16-28 15-44M438 177c11 9 18 20 22 33M67 131c10-4 17-10 22-19"/>
        <path d="M114 221c8-2 14-7 19-14 3 8 9 13 17 16-8 3-14 8-17 16-5-7-11-12-19-18Z"/>
        <path d="M423 119c2 9 7 14 15 17-8 3-13 8-15 17-3-9-8-14-16-17 8-3 13-8 16-17Z"/>
        <circle cx="103" cy="95" r="2"/>
        <circle cx="455" cy="239" r="2.2"/>
      </g>
      <g class="hero-art-soft" filter="url(#mm-pencil)">
        <path d="M24 285c22-10 44-11 66-3M334 381c42 7 82 3 118-11M450 303c8 9 13 19 14 31"/>
        <path d="M146 255c13 4 25 9 38 15M369 133c-11 4-21 10-30 17"/>
      </g>
    </svg>`;

  const ambientArt = `
    <div class="mm-page-decor" aria-hidden="true">
      <span class="mm-decor-cloud mm-decor-cloud-a">${svg("cloud")}</span>
      <span class="mm-decor-cloud mm-decor-cloud-b">${svg("cloud")}</span>
      <span class="mm-decor-leaf mm-decor-leaf-a">${svg("leaf")}</span>
      <span class="mm-decor-leaf mm-decor-leaf-b">${svg("leaf")}</span>
      <span class="mm-decor-flower">${svg("flower")}</span>
      <span class="mm-decor-star mm-decor-star-a">${svg("spark")}</span>
      <span class="mm-decor-star mm-decor-star-b">${svg("spark")}</span>
      <span class="mm-decor-wave">${svg("wind")}</span>
    </div>`;

  const addIcon = (node, name, className, placement = "afterbegin") => {
    if (!node || node.querySelector(":scope > ." + className)) return;
    node.insertAdjacentHTML(placement, '<span class="' + className + '">' + svg(name) + "</span>");
  };

  const replaceTextWithIcon = (node, name) => {
    if (!node || node.dataset.mmIcon === name) return;
    node.textContent = "";
    node.insertAdjacentHTML("afterbegin", svg(name));
    node.dataset.mmIcon = name;
  };

  const markerIconFor = (item, index) => {
    const text = (item.textContent || "").toLowerCase();
    if (/water|drink|tear/.test(text)) return "drop";
    if (/breath|slow|soften|shoulder|stretch|rest|quiet/.test(text)) return "wind";
    if (/write|note|letter|journal/.test(text)) return "edit";
    if (/music|sound|listen/.test(text)) return "music";
    if (/lock|seal|encrypt|private/.test(text)) return "lock";
    if (/safe|local|device|privacy/.test(text)) return "shield";
    if (/wish|bless|intention/.test(text)) return "spark";
    if (/card|reflection/.test(text)) return "cards";
    if (/heart|care|kind/.test(text)) return "heart";
    return ["leaf", "spark", "flower", "cloud"][index % 4];
  };

  const decorateListMarkers = root => {
    root.querySelectorAll(".clean-item > span, .guide-item > span").forEach((span, index) => {
      if (span.querySelector("svg")) return;
      const label = span.textContent.trim();
      if (!label || label.length > 8) return;
      span.classList.add("mm-marker-icon");
      span.setAttribute("role", "img");
      span.setAttribute("aria-label", label);
      span.title = label;
      span.innerHTML = svg(markerIconFor(span.parentElement, index)) + '<span class="marker-text">' + escapeHTML(label) + "</span>";
    });
  };

  const addCardDoodles = root => {
    const doodles = [
      ["#homeProfilePanel", "leaf"],
      ["#homeInsightPanel", "spark"],
      ["#homeDailyPanel", "cloud"],
      ["#homeQuickPanel", "flower"]
    ];
    doodles.forEach(([selector, name]) => {
      const card = root.querySelector(selector);
      if (card && !card.querySelector(".card-doodle")) card.insertAdjacentHTML("afterbegin", '<span class="card-doodle" aria-hidden="true">' + svg(name) + "</span>");
    });
  };

  const decorate = (root = document) => {
    ensureDefs();

    root.querySelectorAll(".side-nav .nav-item[data-page], .mobile-nav button[data-page]").forEach(button => {
      const holder = button.querySelector(":scope > .nav-icon");
      if (holder && holder.dataset.mmIcon === (navIcons[button.dataset.page] || "spark")) return;
      const target = holder || button.querySelector(":scope > span") || document.createElement("span");
      if (!target.parentNode) button.prepend(target);
      target.className = "nav-icon";
      target.innerHTML = svg(navIcons[button.dataset.page] || "spark");
      target.dataset.mmIcon = navIcons[button.dataset.page] || "spark";
    });

    [[root.querySelector("#themeBtn"), "theme"], [root.querySelector("#settingsTopBtn"), "settings"], [root.querySelector("#restartBtn"), "restart"]].forEach(([button, name]) => {
      if (!button || button.dataset.mmIcon === name) return;
      button.innerHTML = svg(name);
      button.dataset.mmIcon = name;
    });

    const heroActions = root.querySelector(".hero-actions");
    if (heroActions) {
      addIcon(heroActions.querySelector('[data-go="tarot"]'), "cards", "button-icon");
      addIcon(heroActions.querySelector('[data-go="heal"]'), "leaf", "button-icon");
    }

    addIcon(root.querySelector(".local-pill"), "shield", "inline-icon");
    addIcon(root.querySelector("#settingsBtn"), "settings", "button-icon");
    addIcon(root.querySelector(".local-chip"), "leaf", "inline-icon");

    root.querySelectorAll("[data-heal], [data-wish], [data-collection]").forEach(button => {
      if (!button.closest(".segmented")) return;
      const name = tabIcons[button.dataset.heal || button.dataset.wish || button.dataset.collection];
      if (name) addIcon(button, name, "tab-icon");
    });

    root.querySelectorAll(".page[id^='page-']").forEach(page => {
      const intro = page.querySelector(".page-intro");
      const name = pageIcons[page.id.replace("page-", "")];
      if (intro && name && !intro.querySelector(".page-sigil")) {
        intro.insertAdjacentHTML("afterbegin", '<span class="page-sigil" aria-hidden="true">' + svg(name) + "</span>");
      }
    });

    const orbit = root.querySelector(".hero-orbit");
    if (orbit && !orbit.querySelector(".hero-lineart")) orbit.insertAdjacentHTML("afterbegin", heroLineArt);

    const shell = root.querySelector(".app-shell");
    if (shell && !shell.querySelector(".mm-page-decor")) shell.insertAdjacentHTML("afterbegin", ambientArt);

    root.querySelectorAll(".metric-card").forEach((card, index) => {
      if (card.querySelector(".metric-icon")) return;
      const name = index === 0 ? "gauge" : index === 1 ? "wind" : "flower";
      card.insertAdjacentHTML("afterbegin", '<span class="metric-icon" aria-hidden="true">' + svg(name) + "</span>");
    });

    root.querySelectorAll(".quick-card").forEach(card => {
      if (card.querySelector(".quick-icon")) return;
      const name = card.dataset.wishJump === "checkin" ? "check" : card.dataset.go === "tarot" ? "cards" : card.dataset.go === "wish" ? "spark" : "heart";
      card.insertAdjacentHTML("afterbegin", '<span class="quick-icon" aria-hidden="true">' + svg(name) + "</span>");
      card.insertAdjacentHTML("beforeend", '<span class="quick-arrow" aria-hidden="true">' + svg("arrow") + "</span>");
    });

    root.querySelectorAll(".fusion-card").forEach(card => {
      const icon = card.querySelector(".fusion-icon");
      if (!icon || icon.dataset.mmIcon) return;
      const initial = icon.textContent.trim().charAt(0);
      replaceTextWithIcon(icon, initial === "Z" ? "leaf" : initial === "S" ? "home" : initial === "B" ? "drop" : "profile");
    });

    root.querySelectorAll(".calendar-card .card-icon").forEach((icon, index) => {
      replaceTextWithIcon(icon, ["wind", "leaf", "drop"][index] || "spark");
    });

    root.querySelectorAll(".reading-sections .reading-section").forEach((section, index) => {
      const label = section.querySelector("small");
      if (!label || label.querySelector(".section-type-icon")) return;
      const name = ["drop", "eye", "leaf"][index] || "spark";
      label.insertAdjacentHTML("afterbegin", '<span class="section-type-icon" aria-hidden="true">' + svg(name) + "</span>");
    });

    root.querySelectorAll(".collect-card .kind").forEach(kind => {
      if (kind.querySelector(".type-icon")) return;
      const text = kind.textContent;
      const name = /Daily/i.test(text) ? "calendar" : /Wish/i.test(text) ? "spark" : "cards";
      kind.innerHTML = '<span class="type-icon" aria-hidden="true">' + svg(name) + "</span><span>" + text + "</span>";
    });

    root.querySelectorAll(".skin-card .preview").forEach((preview, index) => {
      if (preview.querySelector(".preview-art")) return;
      const name = ["spark", "moon", "drop", "lock", "book"][index] || "spark";
      preview.insertAdjacentHTML("beforeend", '<span class="preview-art" aria-hidden="true">' + svg(name) + "</span>");
    });

    root.querySelectorAll(".seal-item .seal-icon").forEach(icon => {
      if (icon.querySelector("svg")) return;
      const unlocked = icon.textContent.trim() === "◉" || /Unlocked/i.test(icon.closest(".seal-item")?.textContent || "");
      replaceTextWithIcon(icon, unlocked ? "check" : "lock");
    });

    const chatButton = root.querySelector(".chat-compose button");
    if (chatButton && !chatButton.querySelector("svg")) chatButton.innerHTML = svg("arrow");

    decorateListMarkers(root);
    addCardDoodles(root);
  };

  let scheduled = false;
  const refresh = (root = document) => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => {
      scheduled = false;
      decorate(root);
    });
  };

  window.MMIcons = { svg, decorate, refresh };
  ensureDefs();
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", () => decorate(), { once: true });
  else decorate();

  if (document.body) {
    const observer = new MutationObserver(mutations => {
      if (mutations.some(mutation => mutation.addedNodes.length || mutation.removedNodes.length)) refresh();
    });
    observer.observe(document.body, { childList: true, subtree: true });
  }
})();
