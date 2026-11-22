"use strict";

const $ = (selector, root = document) => root.querySelector(selector);
const $$ = (selector, root = document) => Array.from(root.querySelectorAll(selector));
const TODAY = () => new Date();
const dateKey = (date = new Date()) => `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
const escapeHTML = (value = "") => String(value).replace(/[&<>"']/g, ch => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[ch]));
const uid = () => Math.random().toString(36).slice(2, 10);
const hash = (text = "") => {
  let value = 2166136261;
  for (let i = 0; i < text.length; i += 1) { value ^= text.charCodeAt(i); value = Math.imul(value, 16777619); }
  return Math.abs(value);
};
const pick = (list, seed) => list[seed % list.length];
const load = (key, fallback) => {
  try { const raw = localStorage.getItem(`mm_demo_en_${key}`); return raw ? JSON.parse(raw) : fallback; }
  catch { return fallback; }
};
const save = (key, value) => {
  try { localStorage.setItem(`mm_demo_en_${key}`, JSON.stringify(value)); } catch {}
};
const motionEnabled = () => document.documentElement.dataset.motion !== "off";
const vibrate = (pattern = 12) => { if (navigator.vibrate) navigator.vibrate(pattern); };
let toastTimer;
function toast(message) {
  const node = $("#toast");
  if (!node) return;
  node.textContent = message;
  node.classList.add("show");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => node.classList.remove("show"), 2400);
}

const SIGNS = {
  Aries: { mode: "You prefer to move first and adjust direction through action. Direct expression helps you return to a lighter state.", friction: "You may mistake moving fast for needing to solve everything right now.", relief: "Add a ten-minute buffer before acting on the first impulse." },
  Taurus: { mode: "You feel safest with rhythm, consistency, and things you can touch and trust.", friction: "When change arrives too quickly, repeated checking can quietly drain you.", relief: "Change one small variable and let your body feel the answer." },
  Gemini: { mode: "Information and conversation are your energy doors. Naming a feeling helps it move.", friction: "Too many open possibilities can scatter your attention.", relief: "Write down the one question that matters most, then answer only that." },
  Cancer: { mode: "You are sensitive to atmosphere and relationships. Familiar routines help you feel held.", friction: "You may carry other people's moods and hide your own unmet needs.", relief: "Care for your own feeling first, then decide whether to respond." },
  Leo: { mode: "Being seen and appreciated gives you energy, and you naturally warm the room.", friction: "Sometimes looking strong comes before allowing yourself to feel.", relief: "Appreciate yourself first and do not hand your worth to outside approval." },
  Virgo: { mode: "You make a difficult day feel manageable by turning it into small, clear steps.", friction: "High standards can erase the satisfaction of what you already completed.", relief: "Aim for a solid seventy percent and leave room to breathe." },
  Libra: { mode: "You notice nuance and bring people together with thoughtful communication.", friction: "You may delay your own need while weighing everyone else's comfort.", relief: "Write down your first honest choice before considering how to compromise." },
  Scorpio: { mode: "You feel deeply and value honesty. A quiet, truthful conversation with yourself helps you gather your energy.", friction: "Deep reflection can turn into replaying the same scene and closing yourself off.", relief: "Separate what you feel from what is confirmed, then handle one small next step." },
  Sagittarius: { mode: "Space, exploration, and humor help you loosen from tension.", friction: "You may look far ahead while ignoring that your body is already tired.", relief: "Step outside or change rooms. Let your body feel a little freer first." },
  Capricorn: { mode: "Structure, responsibility, and steady progress help you feel secure.", friction: "You may turn rest into another task and keep raising your own bar.", relief: "Shrink today's must-do list to the one thing that truly matters." },
  Aquarius: { mode: "Independent space and a fresh perspective help you settle your emotions.", friction: "You may observe from a distance and miss what your body is saying.", relief: "State the feeling before analyzing the cause." },
  Pisces: { mode: "Empathy and imagination are gentle strengths. Music and spaciousness help you recover.", friction: "You may absorb the room and carry exhaustion that is not yours.", relief: "Try a kind boundary: whose feeling is this, really?" }
};

const ZODIACS = {
  Rat: { base: "Perceptive and quick-minded, with a gift for finding new possibilities in details.", strength: "You notice changes early and find nimble solutions.", soft: "Your mind may rehearse risks long after your body needs rest." },
  Ox: { base: "Steady and dependable, with a deep respect for rhythm and commitment.", strength: "You stay with small actions until they become stable.", soft: "You may carry too much alone before asking for help." },
  Tiger: { base: "Courageous and alive, willing to stand up for what matters.", strength: "You can take the decisive step when it counts.", soft: "You may confuse enduring alone with being strong." },
  Rabbit: { base: "Gentle and attentive, sensitive to the warmth between people.", strength: "You bring patience and care into ordinary moments.", soft: "You may place your own needs far behind when conflict feels uncomfortable." },
  Dragon: { base: "Imaginative and purposeful, drawn toward meaningful expression.", strength: "You can turn a vision into something that moves other people.", soft: "High hopes can make temporary setbacks feel like personal failure." },
  Snake: { base: "Quiet and perceptive, you prefer to observe before you act.", strength: "You notice nuance and respond with thoughtful judgment.", soft: "Too much inner analysis can turn concern into a loop." },
  Horse: { base: "Free-spirited and warm, you need space and genuine connection.", strength: "You can spark momentum and bring energy into a room.", soft: "Interrupted rhythm can leave you irritated and constrained." },
  Goat: { base: "Kind and gentle, you value safety and mutual care.", strength: "You create comfort through patience and a generous heart.", soft: "You may understand everyone else before asking what you need." },
  Monkey: { base: "Curious and flexible, with an instinct for new ways around an old problem.", strength: "You learn quickly and keep situations moving.", soft: "Too many options can scatter your attention and energy." },
  Rooster: { base: "Thoughtful and orderly, with your own standard for quality.", strength: "You can turn confusion into clear, workable steps.", soft: "Self-criticism may outshine the satisfaction of what is complete." },
  Dog: { base: "Loyal and reliable, you care deeply about trust and long relationships.", strength: "You stay present when someone needs you.", soft: "You may absorb other people's emotions as if they were your responsibility." },
  Pig: { base: "Sincere and spacious, you know how to appreciate life's softer details.", strength: "Your warmth makes relationships feel safer and lighter.", soft: "Under pressure, you may keep enduring instead of naming your limit." }
};

const BLOODS = {
  A: { sense: "Your emotional radar is finely tuned. You notice changes in atmosphere and relationships early.", social: "You value reliability and express care through thoughtful action.", hidden: "You may look composed while quietly needing clear, explicit reassurance.", tip: "Name the feeling before deciding whether to respond to it." },
  B: { sense: "Your emotions move directly, and your body often signals them before your words do.", social: "You are candid, independent, and protective of your natural rhythm.", hidden: "Freedom matters, but so does being respected rather than managed.", tip: "Move your body first, then say what you need in one clear sentence." },
  O: { sense: "You are emotionally resilient and often carry pressure before slowly digesting it.", social: "Direct and dependable, you naturally look after the situation and the people in it.", hidden: "Strength is a habit. You are also allowed to be cared for.", tip: "Change 'I can' into 'I am willing, and I also need rest.'" },
  AB: { sense: "Reason and sensitivity coexist. You move between perspectives with unusual awareness.", social: "You value thoughtful distance and high-quality conversation.", hidden: "You may analyze a great deal without saying the feeling underneath.", tip: "Scan your body first, then share with one person you trust." }
};

const DEFAULT_PROFILE = { blood: "O", birthday: "1995-10-28", year: 1995, sign: "Scorpio", zodiac: "Pig" };
const state = {
  profile: load("profile", DEFAULT_PROFILE),
  wishes: load("wishes", [
    { id: "w1", text: "I hope I can leave my phone in another room tonight and get a real rest.", display: "Anonymous", likes: 12, comments: [{ id: "c1", text: "I hope you get a soft, quiet evening too." }], createdAt: Date.now() - 7200000 },
    { id: "w2", text: "I finished something I had postponed for weeks. I want to give myself a little applause.", display: "Mia", likes: 8, comments: [], createdAt: Date.now() - 18000000 },
    { id: "w3", text: "May I keep a little blank space for myself in the middle of a busy day.", display: "Anonymous", likes: 6, comments: [{ id: "c2", text: "Blank space is not laziness. It is how we recharge." }], createdAt: Date.now() - 86400000 }
  ]),
  seals: load("seals", []),
  checkins: load("checkins", {}),
  collections: load("collections", [
    { id: "sample-1", kind: "Daily Almanac", title: "A note for today", body: "Slowing down is not falling behind. It is how you gather your strength back into your body.", createdAt: Date.now() - 3600000 },
    { id: "sample-2", kind: "Gentle Wish", title: "Peace · This moment is enough", body: "Take care of the next breath first. You do not have to walk the whole road at once.", createdAt: Date.now() - 86400000 }
  ]),
  ownedSkins: load("ownedSkins", ["mist"]),
  selectedSkins: Object.assign({ tarot: "mist", tube: "mist" }, load("selectedSkins", {})),
  tarotHistory: load("tarotHistory", [])
};
const UI = {
  page: "home", wishTab: "draw", healTab: "tree", collectionTab: "cards",
  onboardingStep: 0, onboardingDraft: { blood: state.profile.blood, birthday: state.profile.birthday, year: state.profile.year },
  wishRitual: { blessed: false, shaken: false, result: null },
  tarot: { stage: "charge", shuffle: 0, cards: [], chosen: null, card: null, cleansed: false },
  chat: [{ id: uid(), from: "ai", text: "Welcome to your quiet room. What would you like to set down today?", time: Date.now() }],
  audio: { index: 0, playing: false }, dissect: ""
};

function signFor(month, day) {
  const dates = [[1,20,"Capricorn"],[2,19,"Aquarius"],[3,21,"Pisces"],[4,20,"Aries"],[5,21,"Taurus"],[6,22,"Gemini"],[7,23,"Cancer"],[8,23,"Leo"],[9,23,"Virgo"],[10,24,"Libra"],[11,23,"Scorpio"],[12,22,"Sagittarius"]];
  const found = dates.find(([m, d]) => month === m && day < d);
  if (found) return found[2];
  return ["Capricorn","Aquarius","Pisces","Aries","Taurus","Gemini","Cancer","Leo","Virgo","Libra","Scorpio","Sagittarius"][month % 12];
}
function zodiacFor(year) {
  return ["Rat","Ox","Tiger","Rabbit","Dragon","Snake","Horse","Goat","Monkey","Rooster","Dog","Pig"][((Number(year) - 4) % 12 + 12) % 12];
}
function deriveProfile(blood, birthday, year) {
  const date = new Date(`${birthday}T12:00:00`);
  const safeYear = Number(year) || date.getFullYear();
  const month = Number.isFinite(date.getMonth()) ? date.getMonth() + 1 : 1;
  const day = Number.isFinite(date.getDate()) ? date.getDate() : 1;
  return { blood, birthday, year: safeYear, sign: signFor(month, day), zodiac: zodiacFor(safeYear) };
}
function personaFor(profile) {
  return { sign: SIGNS[profile.sign] || SIGNS.Libra, zodiac: ZODIACS[profile.zodiac] || ZODIACS.Pig, blood: BLOODS[profile.blood] || BLOODS.O };
}
function dailyFor(profile) {
  const seed = hash(`${profile.blood}-${profile.sign}-${profile.zodiac}-${dateKey()}`);
  const score = 72 + seed % 18;
  const strengths = ["breaking a complex day into one doable step", "keeping your rhythm without demanding perfection", "noticing what others need with real sensitivity", "turning mental clutter into clear order", "holding your boundary even under pressure"];
  const guides = [
    "Finish one small thing that takes ten minutes or less. Let your body feel that you are moving forward.",
    "Turn the worry you keep replaying into one question you can actually check today.",
    "Leave a pocket of time with no information coming in. A short walk, water, or sitting quietly all count.",
    "Ask for help in a specific way. You do not have to prove how tired you are first."
  ];
  const tasks = [["Drink a glass of water", "Let your body receive care first"], ["Leave the screen for five minutes", "Look into the distance and soften your shoulders"], ["Write down three things you finished", "Give your attention a gentle landing place"]];
  const zodiacReminders = ["You do not have to catch every responsibility. Check what is truly yours first.", "You do not need to keep proving yourself. Steadiness is already strength.", "Slow the rhythm a little. Your sensitivity will offer a clearer answer.", "Allow yourself to complete only part of it. The sense of completion will return."];
  const inner = ["overthinking", "pre-rehearsing", "over-responsibility", "comparison", "information overload"];
  const strengthIndex = Math.floor(seed / 7) % strengths.length;
  const strengthLabels = ["Small steps", "Steady rhythm", "Sensitivity", "Clear order", "Boundaries"];
  return {
    score, seed,
    strength: strengths[strengthIndex],
    strengthShort: strengthLabels[strengthIndex],
    guide: guides.map((_, i) => guides[(i + seed) % guides.length]),
    tasks: tasks.map((_, i) => tasks[(i + seed) % tasks.length]),
    zodiacReminder: pick(zodiacReminders, Math.floor(seed / 11)),
    bloodTip: BLOODS[profile.blood].tip || pick(guides, seed),
    innerPattern: pick(inner, Math.floor(seed / 13)),
    relaxation: `Today is a good day to slow your pace by about ${8 + seed % 14}% and trade "I must finish" for "I will take one small step".`
  };
}

const PAGE_TITLES = { home: "Today's Sanctuary", profile: "Personality Profile", tarot: "Gentle Reflection Cards", wish: "Wish Ritual", calendar: "Daily Emotional Almanac", heal: "Healing Space", collection: "Collection & Skins" };
function showPage(page) {
  UI.page = page;
  $$(".page").forEach(node => node.classList.toggle("active", node.id === `page-${page}`));
  $$("[data-page]").forEach(node => node.classList.toggle("active", node.dataset.page === page));
  const title = $("#topTitle"); if (title) { title.textContent = PAGE_TITLES[page] || "Mellow Mind"; title.classList.remove("title-arrive"); void title.offsetWidth; title.classList.add("title-arrive"); }
  window.scrollTo({ top: 0, behavior: "smooth" });
  renderPage(page);
}
function renderPage(page = UI.page) {
  if (page === "home") renderHome();
  if (page === "profile") renderProfile();
  if (page === "tarot") renderTarotScene();
  if (page === "wish") renderWish();
  if (page === "calendar") renderCalendar();
  if (page === "heal") renderHeal();
  if (page === "collection") renderCollection();
}
function renderAll() { updateToday(); renderHome(); renderProfile(); renderCalendar(); renderCollection(); if (UI.page === "wish") renderWish(); if (UI.page === "heal") renderHeal(); }
function updateToday() {
  const now = TODAY();
  $("#todayLabel").textContent = now.toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric", weekday: "long" });
}

function renderHome() {
  const profile = state.profile;
  const daily = dailyFor(profile);
  const identity = $("#homeIdentity");
  if (identity) identity.textContent = `${profile.sign} · ${profile.zodiac} · Type ${profile.blood}`;
  const score = $("#homeEaseScore");
  if (score) score.textContent = String(daily.score);
  const indexNote = $("#homeIndexNote");
  if (indexNote) { indexNote.textContent = "Today's inner index"; indexNote.title = daily.relaxation; }
  const frictionNote = $("#homeFrictionNote");
  if (frictionNote) { frictionNote.textContent = "Today's friction cue"; frictionNote.title = daily.innerPattern; }
  const strengthNote = $("#homeStrengthNote");
  if (strengthNote) { strengthNote.textContent = "Your gentle strength"; strengthNote.title = daily.strength; }
  const unwindList = $("#homeUnwindList");
  if (unwindList) unwindList.innerHTML = daily.tasks.slice(0, 3).map(task => `<li>${escapeHTML(task[0])}</li>`).join("");
}

function renderProfile() {
  const profile = state.profile;
  const p = personaFor(profile);
  $$("#bloodPicker [data-blood]").forEach(btn => btn.classList.toggle("active", btn.dataset.blood === profile.blood));
  if ($("#birthdayInput")) $("#birthdayInput").value = profile.birthday;
  if ($("#yearInput")) $("#yearInput").value = profile.year;
  if ($("#autoPreview")) $("#autoPreview").innerHTML = `Auto-converted: <b>${profile.sign}</b> · <b>${profile.zodiac}</b><br><span>These results are personality and emotional references, never future predictions.</span>`;
  const cards = [
    ["Z", `Zodiac · ${profile.zodiac}`, "Natural foundation", p.zodiac.base, "Strength", p.zodiac.strength, "Emotional soft spot", p.zodiac.soft],
    ["S", `Sun sign · ${profile.sign}`, "How you move through the world", p.sign.mode, "Source of friction", p.sign.friction, "A gentle way to unwind", p.sign.relief],
    ["B", `Blood type · ${profile.blood}`, "Emotional sensitivity", p.blood.sense, "How you relate", p.blood.social, "The hidden layer", p.blood.hidden]
  ];
  $("#profileResult").innerHTML = cards.map(card => `<article class="fusion-card"><div class="fusion-head"><div class="fusion-icon">${card[0]}</div><div><h4>${card[1]}</h4><span class="caption">Three-dimensional personality reference</span></div></div><div class="fusion-lines"><div><b>${card[2]}:</b> ${card[3]}</div><div><b>${card[4]}:</b> ${card[5]}</div><div><b>${card[6]}:</b> ${card[7]}</div></div></article>`).join("");
}

const TAROT_CARDS = [
  { name: "Moonlit Wanderer", glyph: "☾", theme: "A gentle pause", emotion: "You are slowly stepping back from a long stretch of tension. Your body noticed the fatigue before your words did.", ignored: "You need a quiet corner where you do not have to explain or be questioned.", advice: "Remove one unnecessary response from today and give the evening to something that truly softens you.", keyword: "Glow slowly" },
  { name: "The Beginner", glyph: "✦", theme: "A fresh possibility", emotion: "Part of you is ready to loosen, even if you are still waiting for a perfectly certain signal.", ignored: "You have a direction. What you may not want is to keep postponing the start until you feel fully prepared.", advice: "Make the first step small enough to finish in ten minutes. Let your body experience movement.", keyword: "Travel light" },
  { name: "Inner Garden", glyph: "❀", theme: "Tending yourself", emotion: "You have been caring for other people first, and your own feelings have been waiting at the back of the line.", ignored: "You want your effort to be seen, but you may need to acknowledge it yourself first.", advice: "Do one small thing only for you today, without needing to justify it.", keyword: "Care for me" },
  { name: "Still Water", glyph: "≈", theme: "Emotional settling", emotion: "There are ripples beneath a calm surface. You are trying hard not to let your feelings interrupt daily life.", ignored: "You do not have to understand everything immediately. Your feelings only need a safe place to exist.", advice: "Write 'Right now I feel...' and let the sentence rest on the page without judging or solving it.", keyword: "Let the ripples be" },
  { name: "Keeper of the Lamp", glyph: "✧", theme: "Boundaries and support", emotion: "You are carrying a great deal and are not used to saying, 'I need help with this.'", ignored: "Your wish for dependable connection has not disappeared. It is simply dressed as independence.", advice: "Choose one safe person and make one small, specific request.", keyword: "Help is allowed" },
  { name: "Soft Strength", glyph: "♡", theme: "Self-acknowledgment", emotion: "Your standards are high. You finish many things but rarely let yourself stop and receive your own approval.", ignored: "You want to be appreciated, and the first meaningful approval can come from you.", advice: "Write down three things you completed today. They do not need to be impressive, only true.", keyword: "I did enough" },
  { name: "Letter by Moonlight", glyph: "✉", theme: "Expression and release", emotion: "Some words have stayed inside for a long time, rehearsed but never given an exit.", ignored: "You want to be understood, not immediately corrected or persuaded.", advice: "Write an unsent letter and let the honest feeling have the whole page.", keyword: "Say what is true" },
  { name: "Morning Mist", glyph: "◌", theme: "Patience with uncertainty", emotion: "The answer is not clear yet, and you may be losing patience with yourself because of it.", ignored: "You do not need to think harder right now. The information needs time to settle.", advice: "Avoid a major decision today. Complete one certain small task and leave room for tomorrow.", keyword: "Not knowing is okay" },
  { name: "Toward Warmth", glyph: "☼", theme: "Restoring energy", emotion: "You are moving toward people and moments that feel warm, but have not fully allowed yourself to enjoy them.", ignored: "You are allowed to feel light without earning it through exhaustion first.", advice: "Make space for an unproductive moment: sunlight, music, or simply doing nothing.", keyword: "Move toward warmth" },
  { name: "Echo", glyph: "◎", theme: "Hearing yourself", emotion: "There are many outside voices, and your attention is being pulled in several directions.", ignored: "What you truly want may be quieter and simpler than you imagine.", advice: "Turn notifications off for ten minutes. Ask only: what would make this moment feel a little easier?", keyword: "Listen inward" },
  { name: "Gathering Light", glyph: "✺", theme: "Tiny achievements", emotion: "You notice the unfinished parts more easily than the road you have already walked.", ignored: "You need the reminder that living steadily and caring for yourself is already an achievement.", advice: "Record the smallest thing you completed today and sincerely tell yourself, 'That was good.'", keyword: "Gather small light" },
  { name: "Returning Home", glyph: "⌂", theme: "A sense of safety", emotion: "You are not asking for more stimulation. You want a familiar place where you can put down your guard.", ignored: "When you are tired, your need for safety becomes stronger than usual.", advice: "Tidy one small corner of your space. Let your body receive the signal: 'I am safe here.'", keyword: "Return to calm" }
];

function resetTarot() {
  UI.tarot = { stage: "charge", shuffle: 0, cards: [], chosen: null, card: null, cleansed: false };
  renderTarotScene();
}
function renderTarotScene() {
  const t = UI.tarot;
  const chargeWrap = $("#chargeWrap"), shuffleZone = $("#shuffleZone"), stage = $("#cardStage");
  if (!chargeWrap || !shuffleZone || !stage) return;
  chargeWrap.classList.toggle("hidden", t.stage !== "charge");
  shuffleZone.classList.toggle("hidden", t.stage !== "shuffle");
  stage.classList.toggle("hidden", !["choose", "reading"].includes(t.stage));
  $("#tarotStepLabel").textContent = t.stage === "charge" ? "Step 1 · Hold to gather energy" : t.stage === "shuffle" ? "Step 2 · Shuffle by hand" : t.stage === "choose" ? "Step 3 · You choose the card" : "Step 4 · A gentle reflection";
  $("#tarotPrompt").textContent = t.stage === "charge" ? "Bring your attention back to now" : t.stage === "shuffle" ? "Let the deck move with your breath" : t.stage === "choose" ? "Choose by intuition, not by explanation" : "This is not a prediction; it is a mirror for this moment";
  $("#tarotHint").textContent = t.stage === "charge" ? "Hold the moon orb for 1.6 seconds and take one quiet breath." : t.stage === "shuffle" ? "Press the deck and drag left or right until the shuffle is complete." : t.stage === "choose" ? "All three cards are available. You choose freely; the system never assigns one for you." : "After reading, swipe to soften the card and reveal today's emotional keyword.";
  if (t.stage === "choose" || t.stage === "reading") {
    stage.innerHTML = t.cards.map((card, index) => `<button class="tarot-card ${currentSkinClass("tarot")} ${t.chosen === index ? "flipped" : ""}" data-tarot-index="${index}" aria-label="Choose card ${index+1}" ${t.chosen !== null && t.chosen !== index ? "style='opacity:.24'" : ""}><div class="tarot-inner"><div class="card-face card-back"><span class="card-number">0${index+1}</span></div><div class="card-face card-front"><div class="card-glyph">${card.glyph}</div><strong>${card.name}</strong><small>${card.theme}</small></div></div></button>`).join("");
  }
  renderTarotReading();
}
function finishCharge() {
  if (UI.tarot.stage !== "charge") return;
  UI.tarot.stage = "shuffle"; vibrate([18, 40, 22]); toast("Energy gathered. Let the cards loosen gently."); renderTarotScene();
}
function completeShuffle() {
  if (UI.tarot.stage !== "shuffle") return;
  UI.tarot.cards = [...TAROT_CARDS].sort(() => Math.random() - .5).slice(0, 3);
  UI.tarot.stage = "choose"; vibrate([12, 30, 12, 30, 12]); renderTarotScene();
}
function chooseTarot(index) {
  if (UI.tarot.stage !== "choose") return;
  UI.tarot.chosen = index; UI.tarot.card = UI.tarot.cards[index]; UI.tarot.stage = "reading";
  vibrate([20, 35, 24]); renderTarotScene();
  setTimeout(() => $("#tarotReading")?.scrollIntoView({ behavior: "smooth", block: "nearest" }), 450);
}
function renderTarotReading() {
  const box = $("#tarotReading"), card = UI.tarot.card;
  if (!box) return;
  if (!card) { box.innerHTML = ""; return; }
  const p = personaFor(state.profile);
  box.innerHTML = `
    <article class="glass reading-card">
      <div class="reading-hero"><div class="reading-sigil">${card.glyph}</div><div><p class="eyebrow">CURRENT INNER WEATHER</p><h3>${card.name} · ${card.theme}</h3><p>A reflection shaped by ${state.profile.sign} / ${state.profile.zodiac} / Type ${state.profile.blood}</p></div></div>
      <div class="reading-sections"><div class="reading-section"><small>Your present emotional state</small><p>${card.emotion}</p></div><div class="reading-section"><small>A thought you may be overlooking</small><p>${card.ignored}</p></div><div class="reading-section"><small>A gentle way to soothe yourself</small><p>${card.advice}</p></div></div>
      <div class="keyword-bar"><div><small>Emotional keyword for today</small><strong id="tarotKeyword">${UI.tarot.cleansed ? card.keyword : "Swipe to let the word emerge"}</strong></div><button class="mini-action" data-collect-tarot="1">Save this reflection</button></div>
      <div class="cleanse-wrap"><p style="margin:0 0 10px;color:var(--soft-ink);font-size:.75rem">Swipe right to soften the card. This is a small body-based gesture of self-soothing, not a magical effect.</p><div class="cleanse-track" id="cleanseTrack"><i class="cleanse-fill" id="cleanseFill"></i><span id="cleanseLabel">Press and swipe right</span></div></div>
      <div class="button-row" style="margin-top:14px"><button class="soft-button" id="resetTarotBtn">Draw again</button><span class="tag">${p.sign.relief.split(".")[0]}</span></div>
    </article>`;
  bindCleanse();
  $("#resetTarotBtn")?.addEventListener("click", resetTarot);
}
function bindCleanse() {
  const track = $("#cleanseTrack"); if (!track) return;
  let dragging = false, startX = 0, progress = 0;
  const update = value => {
    progress = Math.max(0, Math.min(100, value));
    if ($("#cleanseFill")) $("#cleanseFill").style.width = `${progress}%`;
    if ($("#cleanseLabel")) $("#cleanseLabel").textContent = progress < 100 ? `Swipe right · ${Math.round(progress)}%` : "The card feels softer now";
  };
  track.addEventListener("pointerdown", event => { dragging = true; startX = event.clientX; track.setPointerCapture?.(event.pointerId); });
  track.addEventListener("pointermove", event => {
    if (!dragging) return;
    update(((event.clientX - startX) / Math.max(120, track.clientWidth - 40)) * 100);
  });
  const finish = () => {
    if (!dragging) return;
    dragging = false;
    if (progress >= 88) {
      UI.tarot.cleansed = true;
      if ($("#tarotKeyword") && UI.tarot.card) $("#tarotKeyword").textContent = UI.tarot.card.keyword;
      if ($("#cleanseLabel")) $("#cleanseLabel").textContent = "Softened · be gentle with yourself today";
      vibrate([12, 30, 12]); toast(`Today's emotional keyword: ${UI.tarot.card?.keyword || "Glow slowly"}`);
    } else update(0);
  };
  track.addEventListener("pointerup", finish);
  track.addEventListener("pointercancel", finish);
}

const WISH_CATEGORIES = [
  { name: "Peace", glyph: "P", note: "Return to a place where you can rest", lines: ["You do not have to solve everything in this moment. Let this breath slow down first.", "You are already trying hard to live well. It is okay to pause somewhere safe.", "The voice inside deserves to be heard and answered gently.", "Take care of the next small step. Calm will return one moment at a time."] },
  { name: "Healing", glyph: "H", note: "Let recovery happen at your own pace", lines: ["Recovery is not going back to the beginning. It is gathering your strength again.", "You do not need to feel better immediately. You only need to keep caring for yourself.", "Make 'should' quieter and your body's signals closer.", "A short rest or a glass of water can be the beginning of healing."] },
  { name: "Ease", glyph: "E", note: "Slowly let your shoulders come down", lines: ["You can finish one less thing today and leave more room to breathe.", "Ease is not a lack of ambition. It is how effort becomes sustainable.", "Unclench your jaw and soften your shoulders. Some answers arrive in quiet.", "You are allowed to have no output for a while. Your worth remains."] },
  { name: "Flow", glyph: "F", note: "Move with your own honest rhythm", lines: ["Moving slowly still counts as arriving. Direction matters more than speed.", "Start with the step you can take now and let the rest move naturally.", "You do not need to compare your rhythm with anyone else's.", "Break the complicated thing into a smaller piece and let the sense of flow return."] },
  { name: "Tenderness", glyph: "T", note: "Speak to yourself like a good friend", lines: ["If you are tired, give yourself one tender sentence first.", "You do not have to earn love through perfection. Being real is already precious.", "Be patient with yourself. What you are carrying is not light.", "You are allowed to gently decline one thing that drains you today."] }
];

function renderWish() {
  $$("#wishTabs button").forEach(btn => btn.classList.toggle("active", btn.dataset.wish === UI.wishTab));
  if (UI.wishTab === "draw") renderWishDraw();
  if (UI.wishTab === "wall") renderWishWall();
  if (UI.wishTab === "seal") renderSeal();
  if (UI.wishTab === "checkin") renderCheckin();
}
function renderWishDraw() {
  const ritual = UI.wishRitual, box = $("#wishContent");
  if (!box) return;
  if (ritual.result) {
    const category = WISH_CATEGORIES[ritual.result.index];
    box.innerHTML = `<article class="glass wish-altar"><div><div class="seal ${currentSkinClass("tube")}" style="margin:0 auto 10px">${category.glyph}</div><p class="eyebrow">A GENTLE NOTE FOR NOW</p><h3 style="font-size:1.9rem">${category.name} · ${category.note}</h3><p style="max-width:520px;color:var(--soft-ink);font-size:.85rem">${ritual.result.line}</p><div class="button-row" style="justify-content:center"><button class="primary-button" data-collect-wish="1">Save this wish note</button><button class="soft-button" id="resetWishRitual">Draw again</button></div><p style="margin:16px 0 0;color:var(--soft-ink);font-size:.64rem">This note offers a gentle everyday prompt. It does not judge good or bad fortune and does not predict the future.</p></div></article>`;
    $("#resetWishRitual")?.addEventListener("click", () => { UI.wishRitual = { blessed: false, shaken: false, result: null }; renderWishDraw(); });
    return;
  }
  const stageText = !ritual.blessed ? "Step 1 · Press with both palms together" : !ritual.shaken ? "Step 2 · Shake the wish tube" : "Step 3 · Pull a stick by hand";
  box.innerHTML = `
    <div class="ritual-grid">
      <article class="glass wish-altar"><div><div class="step-pill">${stageText}</div><div class="tube-scene"><div class="sticks"><i></i><i></i><i></i></div><div class="tube ${currentSkinClass("tube")}" id="wishTube"></div></div>
        ${!ritual.blessed ? `<button class="primary-button" id="prayBtn">Palms together · hold to make a wish</button><p style="margin:10px 0 0;color:var(--soft-ink);font-size:.68rem">Hold for 1.6 seconds and let your breath slow with the gesture</p>` : !ritual.shaken ? `<button class="primary-button" id="shakeBtn">Shake the wish tube</button><button class="text-button" id="enableMotionBtn" style="display:block;margin:12px auto 0">Enable real device shake</button>` : `<p style="color:var(--soft-ink);font-size:.74rem">The tube has become quiet. Choose one of the five sticks below with your own hand.</p>`}
        ${ritual.shaken ? `<div class="draw-sticks">${WISH_CATEGORIES.map((c, i) => `<button class="stick-choice" data-stick-index="${i}" aria-label="Choose wish stick ${i+1}">${c.name}</button>`).join("")}</div>` : ""}
      </div></article>
      <article class="glass wish-card"><p class="eyebrow">RITUAL GUIDE</p><h3>Turn a wish into self-care</h3><div class="clean-list" style="margin-top:16px"><div class="clean-item"><span>01</span><div><b>Make a wish</b><br>While holding, keep only one feeling you want to take care of.</div></div><div class="clean-item"><span>02</span><div><b>Shake</b><br>The iOS app uses CoreMotion, Haptics, and a physical tube animation. This demo provides a button fallback.</div></div><div class="clean-item"><span>03</span><div><b>Choose by hand</b><br>You select the stick yourself. A wish note offers a gentle life prompt, not an outcome.</div></div></div><div class="keyword-bar"><div><small>Five themes</small><strong>Peace · Healing · Ease · Flow · Tenderness</strong></div></div></article>
    </div>`;
  bindWishDraw();
}
function bindWishDraw() {
  const pray = $("#prayBtn");
  if (pray) {
    let holding = false, startedAt = 0, raf;
    const tick = () => {
      if (!holding) return;
      const ratio = Math.min(1, (performance.now() - startedAt) / 1600);
      pray.style.background = `linear-gradient(135deg, #82bfd9 ${ratio * 100}%, #4386a4 ${ratio * 100}%)`;
      pray.textContent = ratio >= 1 ? "Wish received" : `Palms together · ${Math.round(ratio * 100)}%`;
      if (ratio >= 1) { holding = false; UI.wishRitual.blessed = true; vibrate([15, 35, 18]); toast("Wish received. Shake the tube gently."); renderWishDraw(); return; }
      raf = requestAnimationFrame(tick);
    };
    pray.addEventListener("pointerdown", event => { event.preventDefault(); holding = true; startedAt = performance.now(); tick(); });
    const stop = () => { if (!holding) return; holding = false; cancelAnimationFrame(raf); pray.style.background = ""; pray.textContent = "Palms together · hold to make a wish"; };
    pray.addEventListener("pointerup", stop); pray.addEventListener("pointercancel", stop); pray.addEventListener("pointerleave", stop);
  }
  $("#shakeBtn")?.addEventListener("click", triggerWishShake);
  $("#enableMotionBtn")?.addEventListener("click", enableRealMotion);
  $$("[data-stick-index]").forEach(btn => btn.addEventListener("click", () => drawWishStick(Number(btn.dataset.stickIndex))));
}
function triggerWishShake() {
  if (!UI.wishRitual.blessed || UI.wishRitual.shaken) return;
  $("#wishTube")?.classList.add("shaking");
  vibrate([20, 28, 20, 28, 20, 28, 24]);
  setTimeout(() => { UI.wishRitual.shaken = true; renderWishDraw(); }, 900);
}
function enableRealMotion() {
  if (typeof DeviceMotionEvent === "undefined") { toast("This device does not support motion detection. Use the button instead."); return; }
  const start = () => {
    let lastTime = 0;
    window.addEventListener("devicemotion", event => {
      if (!UI.wishRitual.blessed || UI.wishRitual.shaken) return;
      const acc = event.accelerationIncludingGravity || {};
      const force = Math.abs(acc.x || 0) + Math.abs(acc.y || 0) + Math.abs(acc.z || 0);
      const now = Date.now();
      if (force > 24 && now - lastTime > 800) { lastTime = now; triggerWishShake(); }
    }, { passive: true });
    toast("Device shake is enabled. Gently shake your phone.");
  };
  if (typeof DeviceMotionEvent.requestPermission === "function") {
    DeviceMotionEvent.requestPermission().then(result => { if (result === "granted") start(); else toast("Motion permission was not granted. Use the button fallback."); }).catch(() => toast("Motion permission is unavailable. Use the button fallback."));
  } else start();
}
function drawWishStick(index) {
  if (!UI.wishRitual.shaken || UI.wishRitual.result) return;
  const category = WISH_CATEGORIES[index]; if (!category) return;
  UI.wishRitual.result = { index, line: pick(category.lines, hash(`${dateKey()}-${state.profile.blood}-${index}`)) };
  vibrate([15, 30, 15]); renderWishDraw();
}

function renderWishWall() {
  const box = $("#wishContent"); if (!box) return;
  const list = state.wishes.map(wish => `<article class="wish-item"><div class="wish-meta"><span>${escapeHTML(wish.display)} · ${new Date(wish.createdAt).toLocaleDateString("en-US")}</span><span>Kindness only</span></div><p>${escapeHTML(wish.text)}</p>${wish.comments?.length ? `<div class="comment-list">${wish.comments.map(c => `<div class="comment">♡ ${escapeHTML(c.text)}</div>`).join("")}</div>` : ""}<div class="inline-form"><button class="mini-action ${wish.likedByMe ? "liked" : ""}" data-like-wish="${wish.id}">♡ ${wish.likes}</button><input id="comment-${wish.id}" maxlength="100" placeholder="Leave one kind sentence"><button class="mini-action" data-comment-wish="${wish.id}">Send support</button></div></article>`).join("");
  box.innerHTML = `
    <div class="content-grid two-one"><article class="glass wish-card"><p class="eyebrow">SHARE A GENTLE WISH</p><h3>Write a wish</h3><textarea class="field-textarea" id="newWishText" maxlength="180" placeholder="Write only what you truly want to take care of in this moment..."></textarea><div class="switch-row"><span>Post anonymously (demo data stays on this device)</span><label class="toggle"><input type="checkbox" id="wishAnonymous" checked><i></i></label></div><button class="primary-button wide" id="publishWishBtn">Add to local wish wall</button></article><article class="glass wish-card"><p class="eyebrow">COMMUNITY PRINCIPLE</p><h3>No comparison. Only light.</h3><p style="color:var(--soft-ink);font-size:.76rem">You can like and leave an encouraging note. This demo is a single-device community with no public uploads. A networked release would require moderation, reporting, and blocking before launch.</p><div class="keyword-bar"><div><small>Gentle reminder</small><strong>Your wish deserves to be heard</strong></div></div></article></div>
    <div class="wish-list">${list}</div>`;
  $("#publishWishBtn")?.addEventListener("click", () => {
    const field = $("#newWishText"), text = field?.value.trim();
    if (!text) { toast("Write a wish first"); field?.focus(); return; }
    state.wishes.unshift({ id: uid(), text, display: $("#wishAnonymous")?.checked ? "Anonymous" : "Me", likes: 0, comments: [], likedByMe: false, createdAt: Date.now() });
    save("wishes", state.wishes); vibrate(14); toast("Your wish was added to the local wall"); renderWishWall();
  });
  $$("[data-like-wish]").forEach(btn => btn.addEventListener("click", () => {
    const wish = state.wishes.find(item => item.id === btn.dataset.likeWish); if (!wish) return;
    wish.likedByMe = !wish.likedByMe; wish.likes = Math.max(0, (wish.likes || 0) + (wish.likedByMe ? 1 : -1));
    save("wishes", state.wishes); vibrate(10); renderWishWall();
  }));
  $$("[data-comment-wish]").forEach(btn => btn.addEventListener("click", () => {
    const wish = state.wishes.find(item => item.id === btn.dataset.commentWish); const input = $(`#comment-${btn.dataset.commentWish}`); const text = input?.value.trim();
    if (!wish || !text) { toast("Write one kind sentence first"); input?.focus(); return; }
    wish.comments = wish.comments || []; wish.comments.push({ id: uid(), text });
    save("wishes", state.wishes); vibrate(10); toast("Your encouragement has arrived"); renderWishWall();
  }));
}

const encodeSeal = text => btoa(String.fromCharCode(...new TextEncoder().encode(text)));
const decodeSeal = text => { try { return new TextDecoder().decode(Uint8Array.from(atob(text), c => c.charCodeAt(0))); } catch { return "This sealed note could not be read."; } };
function renderSeal() {
  const box = $("#wishContent"); if (!box) return;
  UI.sealDays = UI.sealDays || 7;
  const records = state.seals.map(record => {
    const unlocked = Date.now() >= record.unlockAt;
    const days = Math.ceil((record.unlockAt - Date.now()) / 86400000);
    return `<div class="seal-item"><div class="seal-icon">${unlocked ? "◉" : "✧"}</div><div><p>${unlocked ? escapeHTML(decodeSeal(record.payload)) : "A sealed wish, encrypted for later"}</p><small>${unlocked ? "Unlocked · revisit how this moment felt" : `Unlocks in ${days} day${days === 1 ? "" : "s"}`}</small></div>${unlocked ? `<button class="mini-action" data-remove-seal="${record.id}">Delete</button>` : `<button class="mini-action" data-preview-seal="${record.id}">Demo unlock</button>`}</div>`;
  }).join("");
  box.innerHTML = `
    <div class="content-grid"><article class="glass seal-card"><p class="eyebrow">SEAL FOR LATER</p><h3>Leave a note for your future self</h3><textarea class="field-textarea" id="sealText" maxlength="280" placeholder="Write down how this moment feels, what you hope for, or what you want your future self to know..."></textarea><label class="field-label">Choose an unlock time</label><div class="chip-row" id="sealDayPicker"><button class="choice-chip ${UI.sealDays === 7 ? "active" : ""}" data-seal-days="7">7 days</button><button class="choice-chip ${UI.sealDays === 30 ? "active" : ""}" data-seal-days="30">30 days</button></div><button class="primary-button wide" id="saveSealBtn" style="margin-top:16px">Encrypt and seal</button><p style="margin:12px 0 0;color:var(--soft-ink);font-size:.65rem">The demo encodes content locally. The iOS app uses AES-GCM encryption with the key held in Keychain. Unlimited sealed wishes are a premium entitlement.</p></article><article class="glass seal-card"><p class="eyebrow">YOUR SEALED MOMENTS</p><h3>Archive</h3><div class="seal-list">${records || `<div class="empty-state">No sealed wishes yet. Leave today's feeling a note for later.</div>`}</div></article></div>`;
  $$("[data-seal-days]").forEach(btn => btn.addEventListener("click", () => { UI.sealDays = Number(btn.dataset.sealDays); renderSeal(); }));
  $("#saveSealBtn")?.addEventListener("click", () => {
    const text = $("#sealText")?.value.trim(); if (!text) { toast("Write the wish you want to seal first"); return; }
    const days = UI.sealDays || 7;
    state.seals.unshift({ id: uid(), payload: encodeSeal(text), unlockAt: Date.now() + days * 86400000, createdAt: Date.now() });
    save("seals", state.seals); vibrate([12, 30, 12]); toast(`Wish sealed. You can revisit it in ${days} days.`); renderSeal();
  });
  $$("[data-preview-seal]").forEach(btn => btn.addEventListener("click", () => {
    const record = state.seals.find(item => item.id === btn.dataset.previewSeal); if (!record) return;
    record.unlockAt = Date.now() - 1000; save("seals", state.seals); renderSeal();
  }));
  $$("[data-remove-seal]").forEach(btn => btn.addEventListener("click", () => {
    state.seals = state.seals.filter(item => item.id !== btn.dataset.removeSeal); save("seals", state.seals); renderSeal();
  }));
}

const MICRO_TASKS = [
  { id: "water", text: "Drink a glass of water with attention" },
  { id: "eyes", text: "Look away from the screen for five minutes" },
  { id: "stretch", text: "Soften your shoulders and stretch slowly" },
  { id: "three", text: "Write down three things you finished today" },
  { id: "kind", text: "Say one kind sentence to yourself" }
];
function renderCheckin() {
  const box = $("#wishContent"); if (!box) return;
  const today = dateKey(), done = state.checkins[today] || [];
  let streak = 0;
  for (let i = 0; i < 60; i += 1) {
    const d = new Date(); d.setDate(d.getDate() - i);
    if ((state.checkins[dateKey(d)] || []).length) streak += 1; else if (i > 0) break;
  }
  const days = [];
  for (let i = 6; i >= 0; i -= 1) {
    const d = new Date(); d.setDate(d.getDate() - i); const key = dateKey(d);
    days.push(`<div class="day-dot ${(state.checkins[key] || []).length ? "done" : ""}"><i>${d.getDate()}</i><span>${d.toLocaleDateString("en-US", { weekday: "short" }).slice(0, 2)}</span></div>`);
  }
  box.innerHTML = `
    <div class="content-grid two-one"><article class="glass checkin-card"><p class="eyebrow">TINY ACTS OF RETURN</p><h3>Today's check-in</h3><p style="color:var(--soft-ink);font-size:.78rem">Let one small act of care become a moment you remember.</p><div class="streak-banner"><div><small>Self-care streak</small><strong>${streak} day${streak === 1 ? "" : "s"}</strong></div><div class="equalizer"><i></i><i></i><i></i><i></i></div></div><div class="clean-list">${MICRO_TASKS.map(task => `<button class="wish-item" data-check-task="${task.id}" style="width:100%;text-align:left;cursor:pointer"><div class="wish-meta"><span>${done.includes(task.id) ? "✓ Completed" : "A small step"}</span><span>${done.includes(task.id) ? "Recorded" : "Tap to check in"}</span></div><p style="margin:0">${task.text}</p></button>`).join("")}</div></article><article class="glass checkin-card"><p class="eyebrow">LAST 7 DAYS</p><h3>Little traces of care</h3><div class="checkin-grid">${days.join("")}</div><div class="keyword-bar"><div><small>Growth reward</small><strong>Keep checking in to unlock basic card and wish-tube skins</strong></div></div><p style="margin:12px 0 0;color:var(--soft-ink);font-size:.65rem">One completed micro-task counts as the daily self-care check-in.</p></article></div>`;
  $$("[data-check-task]").forEach(btn => btn.addEventListener("click", () => {
    const id = btn.dataset.checkTask, current = state.checkins[today] || [];
    state.checkins[today] = current.includes(id) ? current.filter(item => item !== id) : [...current, id];
    save("checkins", state.checkins); vibrate(12); toast(state.checkins[today].includes(id) ? "A small act of care is still worth remembering" : "Check-in removed"); renderCheckin();
  }));
}

function renderCalendar() {
  const box = $("#calendarContent"); if (!box) return;
  const daily = dailyFor(state.profile), p = personaFor(state.profile);
  box.innerHTML = `
    <article class="glass calendar-hero"><div class="score-ring" style="--score:${daily.score}"><div><strong>${daily.score}</strong><small>Ease index today</small></div></div><div><p class="eyebrow">${dateKey()} · Refreshed daily</p><h3 style="font-size:1.7rem">${daily.relaxation}</h3><p style="color:var(--soft-ink);font-size:.8rem">${p.zodiac.base} ${p.sign.mode}</p><div class="button-row"><button class="primary-button" data-collect-calendar="1">Save today's almanac</button><button class="soft-button" data-go="heal">Open sound therapy</button></div></div></article>
    <div class="calendar-cards"><article class="calendar-card"><div class="card-icon">◌</div><h4>Friction guide</h4><p>Today you may spend energy on ${daily.innerPattern}. Ask yourself: does this need my attention now, or am I rehearsing it in advance?</p></article><article class="calendar-card"><div class="card-icon">✦</div><h4>Small ways to unwind</h4><p>${daily.tasks[0][0]}; ${daily.tasks[1][0]}. Set the bar at seventy percent and let your body feel some ease.</p></article><article class="calendar-card"><div class="card-icon">B</div><h4>Blood-type self-care</h4><p>${daily.bloodTip} This is not a destiny judgment, only an emotional-care experiment that may suit you.</p></article></div>
    <div class="content-grid" style="margin-top:16px"><article class="glass panel"><div class="section-title"><h3>${state.profile.zodiac} · Mindset reminder</h3><span>Use your strength gently</span></div><div class="insight-quote">“${daily.zodiacReminder}”</div><p style="margin:0;color:var(--soft-ink);font-size:.76rem">${p.zodiac.strength} Bring that strength to one small thing today.</p></article><article class="glass panel"><div class="section-title"><h3>${state.profile.sign} · Emotional fit</h3><span>No future prediction</span></div><p style="color:var(--soft-ink);font-size:.8rem">${p.sign.friction}</p><div class="keyword-bar"><div><small>Try this today</small><strong>${p.sign.relief}</strong></div></div></article></div>`;
}

function renderHeal() {
  $$("#healTabs button").forEach(btn => btn.classList.toggle("active", btn.dataset.heal === UI.healTab));
  if (UI.healTab === "tree") renderTreeHole();
  if (UI.healTab === "dissect") renderDissect();
  if (UI.healTab === "audio") renderAudio();
}
function renderTreeHole() {
  const box = $("#healContent"); if (!box) return;
  box.innerHTML = `<article class="glass chat-panel"><div class="chat-messages" id="chatMessages">${UI.chat.map(message => `<div class="chat-bubble ${message.from === "me" ? "me" : ""}">${escapeHTML(message.text)}<small>${message.from === "me" ? "Me" : "Gentle companion"}</small></div>`).join("")}</div><form class="chat-compose" id="chatForm"><input id="chatInput" maxlength="400" autocomplete="off" placeholder="You can say anything here..."><button type="submit" aria-label="Send">↑</button></form></article><p style="margin:10px 2px 0;color:var(--soft-ink);font-size:.64rem">This is a local simulated companion, not psychological diagnosis or a substitute for professional care. If your distress feels unmanageable, please contact someone you trust or local professional support.</p>`;
  const messages = $("#chatMessages"); if (messages) messages.scrollTop = messages.scrollHeight;
  $("#chatForm")?.addEventListener("submit", event => {
    event.preventDefault(); const input = $("#chatInput"), text = input?.value.trim(); if (!text) return;
    UI.chat.push({ id: uid(), from: "me", text, time: Date.now() }); if (input) input.value = ""; renderTreeHole();
    setTimeout(() => { UI.chat.push({ id: uid(), from: "ai", text: localCompanionReply(text), time: Date.now() }); renderTreeHole(); vibrate(10); }, 520);
  });
}
function localCompanionReply(text) {
  if (/suicide|kill myself|self-harm|hurt myself|end my life|don't want to live/i.test(text)) return "I care about your safety right now. Please do not stay alone with this: contact someone you trust immediately, or local emergency and crisis support. If you are in immediate danger, call your local emergency number now. You deserve to be protected and supported.";
  const p = personaFor(state.profile);
  if (/tired|exhausted|burned out|no energy|drained/i.test(text)) return `It sounds like you have been holding on for a long time. As a Type ${state.profile.blood}, ${p.blood.sense} You do not have to solve everything now. Could you do one small thing for your body, like drinking water, leaning back, or letting your shoulders drop?`;
  if (/anxious|worried|nervous|afraid|overthinking|spiraling/i.test(text)) return `The worry is real, and it does not need to disappear before you can be kind to yourself. Write the sentence down, then divide it into 'what I can do now' and 'what I cannot control yet'. As a ${state.profile.sign}, ${p.sign.relief}`;
  if (/sleep|insomnia|awake|can't sleep/i.test(text)) return "Tonight, do not require yourself to fall asleep immediately. Dim the screen, breathe slowly, and allow yourself to simply rest. Sleep is not a task; your body will receive the signal of safety one small step at a time.";
  if (/work|study|exam|boss|school|deadline|project/i.test(text)) return "When pressure is high, make the goal smaller. Choose one thing you can begin in ten minutes. Replace 'finish everything' with 'take one step'. The rest can wait until this step is complete.";
  if (/relationship|friend|family|lonely|alone|partner|breakup/i.test(text)) return `Being moved by relationships does not mean you are fragile. Ask yourself: do I need to be heard, to have company, or to receive a concrete suggestion? ${p.sign.mode}`;
  return "Thank you for putting this into words. You do not have to evaluate yourself or find the answer immediately. Try asking: which part of this feels hardest? If I could care for myself just a little right now, what would I do first?";
}

function dissectAnxiety(text) {
  if (/suicide|kill myself|self-harm|hurt myself|end my life|don't want to live/i.test(text)) return { urgent: true, root: "This may involve a safety risk. Prioritize real-world support and professional help.", steps: ["Contact someone you trust now and ask them to stay with you.", "If there is immediate danger, call local emergency services or go to the nearest emergency department.", "Move away from anything that could hurt you and place yourself in a safer environment."] };
  const p = personaFor(state.profile);
  const theme = /work|study|exam|boss|school|deadline|project/i.test(text) ? "performance pressure and accumulating responsibility" : /relationship|friend|family|lonely|alone|partner|breakup/i.test(text) ? "relationship expectations and unclear boundaries" : /choice|decide|future|uncertain/i.test(text) ? "repeated weighing caused by uncertainty" : "physical fatigue and mental overload amplifying each other";
  return {
    urgent: false,
    root: `From the personality reference of Type ${state.profile.blood}, ${state.profile.sign}, and ${state.profile.zodiac}, this drain may be connected to ${theme}. ${p.sign.friction}`,
    steps: [
      "Ground your body first: feel both feet on the floor and exhale slowly six times.",
      `Shrink the problem into one doable question: 'What is the next small step I can take?' ${p.zodiac.strength}`,
      `Give yourself a boundary action: ${p.sign.relief} When it is complete, allow a pause without checking again.`
    ]
  };
}
function renderDissect() {
  const box = $("#healContent"); if (!box) return;
  const result = UI.dissectResult;
  box.innerHTML = `<div class="content-grid"><article class="glass panel"><p class="eyebrow">ANXIETY SORTER</p><h3>Turn a tangle of worry into pieces you can breathe around</h3><p style="color:var(--soft-ink);font-size:.76rem">This reflection uses the personality and emotional references of Type ${state.profile.blood}, ${state.profile.sign}, and ${state.profile.zodiac} to suggest a present-focused care plan.</p><textarea class="field-textarea" id="dissectInput" maxlength="600" placeholder="Write down the situation that has been draining you...">${escapeHTML(UI.dissect || "")}</textarea><button class="primary-button wide" id="dissectBtn" style="margin-top:12px">Gently sort this anxiety</button></article><article class="glass panel"><p class="eyebrow">GENTLE REFRAME</p><h3>Reflection</h3>${result ? `<div class="analysis-result"><h4>${result.urgent ? "Safety comes first" : "Possible source of drain"}</h4><p>${escapeHTML(result.root)}</p><h4>${result.urgent ? "Please do this now" : "Three things to try"}</h4><ol>${result.steps.map(step => `<li>${escapeHTML(step)}</li>`).join("")}</ol><p style="margin-bottom:0;font-size:.66rem">This is not a medical diagnosis and does not decide anything for you. If distress keeps affecting daily life, please seek professional psychological support.</p></div>` : `<div class="empty-state">Write down the worry, then sort it. The result will not decide for you; it will make the next step smaller.</div>`}</article></div>`;
  $("#dissectBtn")?.addEventListener("click", () => {
    const text = $("#dissectInput")?.value.trim(); if (!text) { toast("Write down what is draining you first"); return; }
    UI.dissect = text; UI.dissectResult = dissectAnxiety(text); vibrate(12); renderDissect();
  });
}

const AUDIO_TRACKS = [
  { title: "Cloud Rain", file: "cloud_rain.wav", note: "For card reading · soft rainfall", duration: "About 1 minute" },
  { title: "Moon Breath", file: "moon_breath.wav", note: "For winding down · slow breathing", duration: "About 1 minute" },
  { title: "Quiet Stream", file: "quiet_stream.wav", note: "For sorting worry · water ambience", duration: "About 1 minute" },
  { title: "Soft Hearth", file: "soft_hearth.wav", note: "For wish rituals · warm ambience", duration: "About 1 minute" }
];
const audioEl = new Audio(); audioEl.preload = "metadata"; audioEl.loop = true;
function renderAudio() {
  const box = $("#healContent"); if (!box) return;
  const active = UI.audio.index;
  box.innerHTML = `<div class="content-grid two-one"><article class="glass panel"><p class="eyebrow">LOCAL SOUND THERAPY</p><h3>Sound therapy</h3><p style="color:var(--soft-ink);font-size:.76rem">Audio comes from local project resources with no remote server. The iOS app uses AVAudioPlayer and AVAudioSession, with lock-screen and interruption handling.</p><div class="audio-list">${AUDIO_TRACKS.map((track, index) => `<div class="audio-item"><button class="audio-play" data-audio-play="${index}" aria-label="Play ${track.title}">${active === index && UI.audio.playing ? "Ⅱ" : "▶"}</button><div><h4>${track.title}</h4><small>${track.note} · ${track.duration}</small></div><div class="equalizer ${active === index && UI.audio.playing ? "" : "paused"}"><i></i><i></i><i></i><i></i></div></div>`).join("")}</div></article><article class="glass panel"><p class="eyebrow">NOW PLAYING</p><h3 id="audioPlayerTitle">${AUDIO_TRACKS[active].title}</h3><p id="audioPlayerNote" style="color:var(--soft-ink);font-size:.75rem">${AUDIO_TRACKS[active].note}</p><div class="audio-player"><div style="display:flex;align-items:center;justify-content:space-between;gap:12px"><span class="tag">Local WAV</span><button class="primary-button" id="audioToggle">${UI.audio.playing ? "Pause" : "Play"}</button></div><div class="audio-progress"><i id="audioProgress"></i></div><div style="display:flex;justify-content:space-between;margin-top:8px;color:var(--soft-ink);font-size:.62rem"><span id="audioCurrent">00:00</span><span>${AUDIO_TRACKS[active].duration}</span></div></div><div class="clean-list" style="margin-top:14px"><div class="clean-item"><span>☾</span><div><b>Card scene</b><br>Start after choosing a card to return from the reading to your body.</div></div><div class="clean-item"><span>✦</span><div><b>Wish scene</b><br>Use low-stimulation ambience during the wish ritual.</div></div></div></article></div>`;
  $$("[data-audio-play]").forEach(btn => btn.addEventListener("click", () => toggleAudio(Number(btn.dataset.audioPlay))));
  $("#audioToggle")?.addEventListener("click", () => toggleAudio(UI.audio.index));
  updateAudioUI();
}
function toggleAudio(index) {
  const track = AUDIO_TRACKS[index]; if (!track) return;
  if (!audioEl.getAttribute("src") || UI.audio.index !== index) {
    UI.audio.index = index; UI.audio.playing = false; audioEl.pause(); audioEl.src = `../../MellowMind/Resources/Audio/${track.file}`; audioEl.load();
  }
  if (UI.audio.playing) { audioEl.pause(); UI.audio.playing = false; updateAudioUI(); return; }
  const player = audioEl.play();
  if (player?.catch) player.then(() => { UI.audio.playing = true; updateAudioUI(); }).catch(() => toast("The browser blocked playback. Tap play again."));
  else { UI.audio.playing = true; updateAudioUI(); }
}
function updateAudioUI() {
  const active = UI.audio.index, playing = UI.audio.playing;
  if ($("#audioPlayerTitle")) $("#audioPlayerTitle").textContent = AUDIO_TRACKS[active].title;
  if ($("#audioPlayerNote")) $("#audioPlayerNote").textContent = AUDIO_TRACKS[active].note;
  if ($("#audioToggle")) $("#audioToggle").textContent = playing ? "Pause" : "Play";
  $$("[data-audio-play]").forEach(btn => {
    const index = Number(btn.dataset.audioPlay); btn.textContent = index === active && playing ? "Ⅱ" : "▶";
    btn.closest(".audio-item")?.querySelector(".equalizer")?.classList.toggle("paused", !(index === active && playing));
  });
}
function formatTime(seconds) { return !Number.isFinite(seconds) ? "00:00" : `${String(Math.floor(seconds / 60)).padStart(2, "0")}:${String(Math.floor(seconds % 60)).padStart(2, "0")}`; }

const SKINS = [
  { id: "mist", title: "Mist Light", type: "Free", description: "A basic moon-white and lavender look for cards and the wish tube.", preview: "M" },
  { id: "moon", title: "Moon Shadow", type: "Card skin pack", description: "Deep violet card backs with silver starlight. Premium unlock.", preview: "☾" },
  { id: "porcelain", title: "Celadon Wish Tube", type: "Wish-tube skin pack", description: "Soft milk-blue porcelain texture. Premium unlock.", preview: "C" },
  { id: "seal", title: "Unlimited Wish Seals", type: "Entitlement", description: "Seal unlimited wishes and keep the full history.", preview: "✧" },
  { id: "report", title: "Daily Deep Report", type: "Subscription", description: "A more complete emotional-support report, billed monthly.", preview: "R" }
];
const APPLICABLE_SKINS = new Set(["mist", "moon", "porcelain"]);
function currentSkinClass(kind) {
  return `skin-${state.selectedSkins[kind] || "mist"}`;
}
function isSkinSelected(id) {
  return state.selectedSkins.tarot === id || state.selectedSkins.tube === id;
}
function applyDemoSkin(id) {
  if (id !== "mist" && !state.ownedSkins.includes(id)) return false;
  if (id === "mist") {
    state.selectedSkins.tarot = "mist";
    state.selectedSkins.tube = "mist";
  } else if (id === "moon") {
    state.selectedSkins.tarot = "moon";
  } else if (id === "porcelain") {
    state.selectedSkins.tube = "porcelain";
  } else {
    return false;
  }
  save("selectedSkins", state.selectedSkins);
  vibrate([10, 25, 10]);
  renderStore();
  return true;
}
function renderCollection() {
  $$("#collectionTabs button").forEach(btn => btn.classList.toggle("active", btn.dataset.collection === UI.collectionTab));
  if (UI.collectionTab === "cards") renderCollectionCards();
  if (UI.collectionTab === "store") renderStore();
}
function addCollection(item) {
  if (state.collections.find(entry => entry.title === item.title && entry.body === item.body)) { toast("This reflection is already saved"); return; }
  state.collections.unshift({ id: uid(), createdAt: Date.now(), ...item });
  save("collections", state.collections); vibrate([10, 25, 10]); toast("Saved to your healing album"); renderCollection();
}
function renderCollectionCards() {
  const box = $("#collectionContent"); if (!box) return;
  const cards = state.collections.map(item => `<article class="collect-card"><span class="kind">${escapeHTML(item.kind)}</span><h4>${escapeHTML(item.title)}</h4><p>${escapeHTML(item.body)}</p><div class="collect-actions"><span class="tag">${new Date(item.createdAt).toLocaleDateString("en-US")}</span><button class="text-button" data-remove-collect="${item.id}">Delete</button></div></article>`).join("");
  box.innerHTML = `<div class="section-title"><div><p class="eyebrow">PERSONAL HEALING ALBUM</p><h3 style="margin:4px 0 0">Saved reflections</h3></div><span>${state.collections.length} cards</span></div>${cards ? `<div class="collection-grid">${cards}</div>` : `<div class="empty-state">Nothing saved yet. After a card, wish note, or almanac entry, you can keep the words that help.</div>`}<div class="keyword-bar" style="margin-top:18px"><div><small>Local persistence</small><strong>Saved only on this device</strong></div><button class="mini-action" data-go="calendar">Read today's almanac</button></div>`;
  $$("[data-remove-collect]").forEach(btn => btn.addEventListener("click", () => {
    state.collections = state.collections.filter(item => item.id !== btn.dataset.removeCollect); save("collections", state.collections); toast("Removed from your healing album"); renderCollectionCards();
  }));
}
function renderStore() {
  const box = $("#collectionContent"); if (!box) return;
  const cards = SKINS.map(skin => {
    const owned = skin.id === "mist" || state.ownedSkins.includes(skin.id);
    const applicable = APPLICABLE_SKINS.has(skin.id);
    const selected = applicable && isSkinSelected(skin.id);
    const action = owned
      ? (applicable ? `<span class="tag skin-apply">Available</span>` : `<span class="tag">Available</span>`)
      : `<button class="mini-action" data-buy-skin="${skin.id}">Demo unlock</button>`;
    const applyAttrs = owned && applicable ? ` data-apply-skin="${skin.id}" role="button" tabindex="0" aria-pressed="${selected}"` : "";
    return `<article class="skin-card ${owned ? "owned" : "locked"} ${selected ? "selected" : ""} ${owned && applicable ? "selectable" : ""}"${applyAttrs}><div class="preview preview-${skin.id}">${skin.preview}</div><h4>${skin.title}</h4><p>${skin.description}</p><div class="collect-actions"><span class="tag">${skin.type}</span>${action}</div></article>`;
  }).join("");
  box.innerHTML = `<div class="section-title"><div><p class="eyebrow">SKIN & ENTITLEMENT</p><h3 style="margin:4px 0 0">Skin shop</h3></div><span>StoreKit 2 framework</span></div><div class="skin-live-preview" aria-hidden="true"><div class="skin-live-card ${currentSkinClass("tarot")}"><span>☾</span></div><div class="skin-live-tube ${currentSkinClass("tube")}"></div></div><div class="skin-grid">${cards}</div><div class="content-grid" style="margin-top:18px"><article class="glass panel"><h3>Growth unlocks</h3><p style="color:var(--soft-ink);font-size:.76rem">Daily check-ins and accumulated wishes earn growth progress that unlocks basic wish-tube and card skins. Premium skins are one-time purchases and support restore.</p><button class="soft-button" data-restore-purchase="1">Restore purchases</button></article><article class="glass panel"><h3>App Store products</h3><div class="clean-list"><div class="clean-item"><span>C</span><div><b>com.mellowmind.iap.tarot.skinpack</b><br>Premium card-face skin pack</div></div><div class="clean-item"><span>W</span><div><b>com.mellowmind.iap.tube.skinpack</b><br>Premium wish-tube skin pack</div></div><div class="clean-item"><span>S</span><div><b>com.mellowmind.iap.unlimited.wishseals</b><br>Unlimited sealed wishes and history</div></div><div class="clean-item"><span>R</span><div><b>com.mellowmind.iap.dailyreport.monthly</b><br>Daily deep emotional-support report</div></div></div></article></div>`;
  $$("[data-buy-skin]").forEach(btn => btn.addEventListener("click", () => openPurchase(btn.dataset.buySkin)));
  $$("[data-apply-skin]").forEach(card => {
    const apply = () => applyDemoSkin(card.dataset.applySkin);
    card.addEventListener("click", apply);
    card.addEventListener("keydown", event => {
      if (event.key === "Enter" || event.key === " ") { event.preventDefault(); apply(); }
    });
  });
  $("[data-restore-purchase]")?.addEventListener("click", () => { toast("Demo restored basic skins. The iOS app calls StoreKit 2 AppStore.sync()."); renderStore(); });
}
function openPurchase(id) {
  const skin = SKINS.find(item => item.id === id); if (!skin) return;
  openModal(`<p class="eyebrow">STOREKIT 2 PREVIEW</p><h2>${skin.title}</h2><p>${skin.description}</p><div class="flow-lines"><div class="clean-item"><span>1</span><div>The iOS app displays the localized App Store price through StoreKit 2.</div></div><div class="clean-item"><span>2</span><div>After verification, the entitlement is saved in SwiftData and the skin is refreshed.</div></div><div class="clean-item"><span>3</span><div>No ads, no ad pop-ups, and no advertising SDK.</div></div></div><div class="modal-actions"><button class="soft-button" data-close-modal="1">Cancel</button><button class="primary-button" id="demoPurchaseBtn">Demo unlock</button></div>`);
  $("#demoPurchaseBtn")?.addEventListener("click", () => {
    if (!state.ownedSkins.includes(id)) state.ownedSkins.push(id);
    save("ownedSkins", state.ownedSkins); closeModal(); vibrate([12, 30, 12]); toast("Demo unlock complete. The iOS app uses StoreKit 2 for the real transaction."); renderStore();
  });
}

function privacyHTML() {
  return `<p class="eyebrow">PRIVACY</p><h2 id="modalTitle">Privacy Policy</h2><p>Mellow Mind is local-first. This demo uses browser localStorage. The iOS app uses SwiftData and stores user data on the device.</p><ul><li>Data used: blood type, birth year, solar birthday, saved reflections, wishes, sealed wishes, and check-ins.</li><li>Purpose: to generate playful personality references, daily emotional-fit content, and local self-care experiences. It is not used for advertising profiles or tracking.</li><li>Sharing: no remote upload, no third-party tracking, and no advertising SDK.</li><li>Security: the iOS app encrypts sealed wishes with AES-GCM and keeps the key in Keychain.</li><li>Deletion: Settings supports one-tap removal of birthday, blood type, wishes, and all local data.</li><li>Contact: support@mellowmind.app (replace with the production address before release).</li></ul><p style="font-size:.68rem">This is a demo privacy framework. A final privacy policy must be reviewed by the publisher and hosted at a public URL before launch.</p>`;
}
function termsHTML() {
  return `<p class="eyebrow">TERMS</p><h2 id="modalTitle">Terms of Use</h2><p>Mellow Mind is an emotional journaling, playful personality-reflection, and stress-relief tool. It does not provide medical care, psychological diagnosis, or fortune prediction.</p><ul><li>Sun signs, zodiac animals, blood types, cards, and wish notes are used only for self-awareness, emotional soothing, and positive prompts.</li><li>Wish notes do not judge good or bad fortune and do not predict future outcomes.</li><li>If emotional distress continues to affect daily life, please seek professional mental-health or medical support.</li><li>Purchases are processed by the App Store. Auto-renewable subscriptions can be managed or cancelled in system settings.</li><li>Premium skins and entitlements follow App Store purchase terms and support restore purchases.</li></ul>`;
}
function aboutHTML() {
  return `<p class="eyebrow">ABOUT MELLOW MIND</p><h2 id="modalTitle">About Us</h2><p style="font-size:1.35rem;color:var(--ink)">Set down emotional tension. Make ordinary days gentler.</p><p>Mellow Mind is a local-first emotional wellness tool. We do not judge destiny; we use cards, wish notes, starlight, and sound as small doorways into how you feel right now.</p><div class="clean-list"><div class="clean-item"><span>V</span><div><b>Version 1.0.0</b><br>iOS 17+ · SwiftUI + SwiftData + StoreKit 2</div></div><div class="clean-item"><span>P</span><div><b>Local first</b><br>No ads, no account, and no third-party tracking.</div></div><div class="clean-item"><span>C</span><div><b>support@mellowmind.app</b><br>Replace with the production support channel.</div></div></div><p style="margin-top:16px;font-size:.68rem">This content is for emotional support and lighthearted personality reflection. It is not a prediction of destiny and is intended for self-healing only.</p>`;
}
function settingsHTML() {
  const theme = document.documentElement.dataset.theme || "auto";
  return `<p class="eyebrow">SETTINGS</p><h2 id="modalTitle">Settings</h2><div class="switch-row"><span>Dark / light appearance</span><button class="mini-action" id="settingsThemeBtn">Current: ${theme === "auto" ? "System" : theme === "dark" ? "Dark" : "Light"}</button></div><div class="switch-row"><span>Daily check-in reminder</span><button class="mini-action" id="notificationBtn">Request notification permission</button></div><div class="clean-list"><button class="clean-item" data-legal="privacy" style="width:100%;text-align:left"><span>P</span><div><b>Privacy Policy</b><br>Local data and one-tap deletion</div></button><button class="clean-item" data-legal="terms" style="width:100%;text-align:left"><span>T</span><div><b>Terms of Use</b><br>Content boundaries, subscriptions, and restore</div></button><button class="clean-item" data-legal="about" style="width:100%;text-align:left"><span>A</span><div><b>About Us</b><br>Version, positioning, and support</div></button></div><div class="modal-actions" style="justify-content:space-between"><button class="soft-button" id="clearDataBtn">Clear demo data</button><button class="primary-button" data-close-modal="1">Done</button></div><p style="margin-top:16px;font-size:.66rem">In the iOS app, vibration and audio playback do not require a system permission prompt. Notifications use the standard system authorization request. We do not fabricate permission prompts.</p>`;
}
function openSettings() {
  openModal(settingsHTML());
  const settingsBody = $("#modalBody");
  const firstSwitch = settingsBody?.querySelector(".switch-row");
  if (firstSwitch && !$("#motionToggle")) firstSwitch.insertAdjacentHTML("afterend", `<div class="switch-row"><span>Gentle motion</span><label class="toggle"><input type="checkbox" id="motionToggle" ${motionEnabled() ? "checked" : ""}><i></i></label></div>`);
  $("#motionToggle")?.addEventListener("change", toggleMotion);
  $("#settingsThemeBtn")?.addEventListener("click", toggleTheme);
  $("#notificationBtn")?.addEventListener("click", requestNotifications);
  $("#clearDataBtn")?.addEventListener("click", clearAllData);
}
function openLegal(kind) { openModal(kind === "privacy" ? privacyHTML() : kind === "terms" ? termsHTML() : aboutHTML()); }
function openModal(html) {
  const backdrop = $("#modalBackdrop"), body = $("#modalBody"); if (!backdrop || !body) return;
  body.innerHTML = html; backdrop.classList.remove("hidden"); document.body.style.overflow = "hidden";
}
function closeModal() { $("#modalBackdrop")?.classList.add("hidden"); document.body.style.overflow = ""; }
function requestNotifications() {
  if (!("Notification" in window)) { toast("This browser does not support notifications"); return; }
  Notification.requestPermission().then(result => toast(result === "granted" ? "Notification permission granted (demo)" : "Notifications were not enabled. You can change this later in system settings.")).catch(() => toast("The notification permission request did not complete"));
}
function clearAllData() {
  if (!confirm("Clear all demo data? This removes the profile, saved reflections, wishes, seals, and check-ins.")) return;
  Object.keys(localStorage).filter(key => key.startsWith("mm_demo_en_")).forEach(key => localStorage.removeItem(key));
  closeModal(); location.reload();
}

function openOnboarding() {
  UI.onboardingStep = 0; UI.onboardingDraft = { blood: state.profile.blood, birthday: state.profile.birthday, year: state.profile.year }; renderOnboarding();
}
function renderOnboarding() {
  const draft = UI.onboardingDraft, step = UI.onboardingStep, preview = deriveProfile(draft.blood, draft.birthday, draft.year);
  let body = "";
  if (step === 0) {
    body = `<p class="eyebrow">STEP 1 · YOUR DETAILS</p><h2 id="modalTitle">Let us meet the person here right now</h2><p>Blood type, solar birthday, and birth year are used only to generate playful personality references. They stay on this device and can be edited or deleted.</p><label class="field-label">Blood type</label><div class="chip-row" id="onboardBloodPicker">${["A","B","O","AB"].map(b => `<button class="choice-chip ${draft.blood === b ? "active" : ""}" data-onboard-blood="${b}">${b}</button>`).join("")}</div><label class="field-label" for="onboardBirthday">Solar birthday</label><input class="field-input" id="onboardBirthday" type="date" value="${escapeHTML(draft.birthday)}"><label class="field-label" for="onboardYear">Birth year</label><input class="field-input" id="onboardYear" type="number" min="1940" max="2026" value="${Number(draft.year) || 1995}"><div class="auto-preview" id="onboardPreview">Auto-converted: <b>${preview.sign}</b> · <b>${preview.zodiac}</b><br><span>Used only as a personality and present-moment emotional reference.</span></div><div class="modal-actions"><button class="soft-button" data-close-modal="1">Maybe later</button><button class="primary-button" id="onboardNext">Continue and light the stars</button></div>`;
  } else if (step === 1) {
    const p = personaFor(preview);
    body = `<p class="eyebrow">STEP 2 · CARD REVEAL</p><h2 id="modalTitle">Three cards, one whole you</h2><p>Turn the card and see how these dimensions combine into the person you are today.</p><div class="auto-persona"><div class="mini-persona"><span>Z</span><strong>${preview.zodiac}</strong><small>${p.zodiac.base}</small></div><div class="mini-persona"><span>☾</span><strong>${preview.sign}</strong><small>${p.sign.mode}</small></div></div><div class="flip-card"><div class="flip-inner"><div class="flip-face"><div><p class="eyebrow">TYPE ${preview.blood} · EMOTIONAL AWARENESS</p><h3>${p.blood.sense}</h3><p style="max-width:440px;color:var(--soft-ink);font-size:.76rem">${p.blood.hidden}</p></div></div></div></div><div class="modal-actions"><button class="soft-button" id="onboardBack">Back</button><button class="primary-button" id="onboardNext">Unlock my profile</button></div>`;
  } else {
    const p = personaFor(preview);
    body = `<p class="eyebrow">STEP 3 · READY</p><h2 id="modalTitle">Your personality profile is ready</h2><div class="auto-persona"><div class="mini-persona"><strong>Type ${preview.blood}</strong><small>${p.blood.sense}</small></div><div class="mini-persona"><strong>${preview.sign}</strong><small>${p.sign.mode}</small></div><div class="mini-persona"><strong>${preview.zodiac}</strong><small>${p.zodiac.base}</small></div><div class="mini-persona"><strong>Today's strength</strong><small>${dailyFor(preview).strength}</small></div></div><p>Save this to generate today's personality strength, four personalized self-care notes, and your daily emotional almanac.</p><div class="modal-actions"><button class="soft-button" id="onboardBack">Edit details</button><button class="primary-button" id="onboardSave">Save profile</button></div>`;
  }
  openModal(`<div class="onboard-progress">${[0,1,2].map(i => `<i class="${i <= step ? "done" : ""}"></i>`).join("")}</div><div class="onboard-stage">${body}</div>`);
  $$("[data-onboard-blood]").forEach(btn => btn.addEventListener("click", () => { UI.onboardingDraft.blood = btn.dataset.onboardBlood; renderOnboarding(); }));
  const birthday = $("#onboardBirthday"), year = $("#onboardYear");
  const refresh = () => {
    if (birthday) UI.onboardingDraft.birthday = birthday.value || UI.onboardingDraft.birthday;
    if (year) UI.onboardingDraft.year = Number(year.value) || UI.onboardingDraft.year;
    if (birthday?.value) { const d = new Date(`${birthday.value}T12:00:00`); if (Number.isFinite(d.getFullYear()) && year) { year.value = d.getFullYear(); UI.onboardingDraft.year = d.getFullYear(); } }
    const next = deriveProfile(UI.onboardingDraft.blood, UI.onboardingDraft.birthday, UI.onboardingDraft.year);
    if ($("#onboardPreview")) $("#onboardPreview").innerHTML = `Auto-converted: <b>${next.sign}</b> · <b>${next.zodiac}</b><br><span>Used only as a personality and present-moment emotional reference.</span>`;
  };
  birthday?.addEventListener("change", refresh); year?.addEventListener("input", refresh);
  $("#onboardBack")?.addEventListener("click", () => { UI.onboardingStep = Math.max(0, UI.onboardingStep - 1); renderOnboarding(); });
  $("#onboardNext")?.addEventListener("click", () => {
    refresh(); if (!UI.onboardingDraft.birthday || !UI.onboardingDraft.year) { toast("Choose a birthday and birth year first"); return; }
    UI.onboardingStep += 1; vibrate([10, 24, 10]); renderOnboarding();
  });
  $("#onboardSave")?.addEventListener("click", () => {
    state.profile = deriveProfile(UI.onboardingDraft.blood, UI.onboardingDraft.birthday, UI.onboardingDraft.year);
    save("profile", state.profile); resetTarot(); UI.wishRitual = { blessed: false, shaken: false, result: null }; UI.dissectResult = null;
    closeModal(); renderAll(); vibrate([16, 36, 16]); toast("Profile saved. Be gentle with yourself today."); showPage("home");
  });
}
function updateAutoPreview() {
  const birthday = $("#birthdayInput")?.value, year = Number($("#yearInput")?.value) || new Date().getFullYear();
  const blood = $("#bloodPicker .choice-chip.active")?.dataset.blood || state.profile.blood;
  if (!birthday) return;
  const next = deriveProfile(blood, birthday, year);
  if ($("#autoPreview")) $("#autoPreview").innerHTML = `Auto-converted: <b>${next.sign}</b> · <b>${next.zodiac}</b><br><span>These results are personality and emotional references, never future predictions.</span>`;
}
function toggleTheme() {
  const current = document.documentElement.dataset.theme || (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
  const next = current === "dark" ? "light" : "dark";
  document.documentElement.dataset.theme = next; save("theme", next);
  if ($("#settingsThemeBtn")) $("#settingsThemeBtn").textContent = `Current: ${next === "dark" ? "Dark" : "Light"}`;
  toast(next === "dark" ? "Dark mode enabled" : "Light mode enabled");
}
function toggleMotion(event) {
  const enabled = Boolean(event.target.checked);
  document.documentElement.dataset.motion = enabled ? "on" : "off";
  save("motion", enabled);
  if (!enabled) document.body.classList.remove("pointer-active");
  toast(enabled ? "Gentle motion enabled" : "Gentle motion paused. All content stays available.");
}
function collectTarot() {
  const card = UI.tarot.card; if (!card) return;
  addCollection({ kind: "Reflection Card", title: `${card.name} · ${card.theme}`, body: `${card.emotion} ${card.advice} Today's keyword: ${card.keyword}` });
}
function collectWish() {
  const result = UI.wishRitual.result; if (!result) return;
  const category = WISH_CATEGORIES[result.index];
  addCollection({ kind: "Gentle Wish", title: `${category.name} · ${category.note}`, body: result.line });
}
function collectCalendar() {
  const daily = dailyFor(state.profile);
  addCollection({ kind: "Daily Almanac", title: `${state.profile.sign} · Today's emotional fit`, body: `${daily.strength} ${daily.guide[0]}` });
}

function bindStaticEvents() {
  document.addEventListener("click", event => {
    const pageButton = event.target.closest("[data-page]"); if (pageButton) { showPage(pageButton.dataset.page); return; }
    const goButton = event.target.closest("[data-go]"); if (goButton) { const jump = event.target.closest("[data-wish-jump]")?.dataset.wishJump; if (jump) UI.wishTab = jump; showPage(goButton.dataset.go); return; }
    const wishTab = event.target.closest("[data-wish]"); if (wishTab) { UI.wishTab = wishTab.dataset.wish; renderWish(); return; }
    const healTab = event.target.closest("[data-heal]"); if (healTab) { UI.healTab = healTab.dataset.heal; renderHeal(); return; }
    const collectionTab = event.target.closest("[data-collection]"); if (collectionTab) { UI.collectionTab = collectionTab.dataset.collection; renderCollection(); return; }
    const legal = event.target.closest("[data-legal]"); if (legal) { openLegal(legal.dataset.legal); return; }
    if (event.target.closest("[data-close-modal]") || event.target === $("#modalBackdrop")) { closeModal(); return; }
    if (event.target.closest("[data-collect-tarot]")) { collectTarot(); return; }
    if (event.target.closest("[data-collect-wish]")) { collectWish(); return; }
    if (event.target.closest("[data-collect-calendar]")) { collectCalendar(); return; }
    const blood = event.target.closest("#bloodPicker [data-blood]"); if (blood) { $$("#bloodPicker .choice-chip").forEach(node => node.classList.toggle("active", node === blood)); updateAutoPreview(); return; }
    const tarotCard = event.target.closest("[data-tarot-index]"); if (tarotCard) { chooseTarot(Number(tarotCard.dataset.tarotIndex)); return; }
  });
  $("#themeBtn")?.addEventListener("click", toggleTheme);
  $("#restartBtn")?.addEventListener("click", openOnboarding);
  $("#settingsBtn")?.addEventListener("click", openSettings);
  $("#settingsNavBtn")?.addEventListener("click", openSettings);
  $("#settingsTopBtn")?.addEventListener("click", openSettings);
  $("#modalClose")?.addEventListener("click", closeModal);
  $("#birthdayInput")?.addEventListener("change", updateAutoPreview);
  $("#yearInput")?.addEventListener("input", updateAutoPreview);
  $("#saveProfileBtn")?.addEventListener("click", () => {
    const blood = $("#bloodPicker .choice-chip.active")?.dataset.blood || state.profile.blood;
    const birthday = $("#birthdayInput")?.value, year = Number($("#yearInput")?.value);
    if (!birthday || !year) { toast("Choose a solar birthday and birth year"); return; }
    state.profile = deriveProfile(blood, birthday, year); save("profile", state.profile); resetTarot(); UI.wishRitual = { blessed: false, shaken: false, result: null }; UI.dissectResult = null; renderAll(); vibrate([12, 30, 12]); toast("Profile updated");
  });
  bindTarotGestures(); bindAudioEvents();
}
function bindTarotGestures() {
  const charge = $("#chargeBtn");
  if (charge) {
    let holding = false, startedAt = 0, raf;
    const resetOrb = () => { charge.style.setProperty("--charge", 0); charge.classList.remove("charging", "charged"); if ($("#chargeCaption")) $("#chargeCaption").textContent = "Breathe · soften your shoulders"; };
    const tick = () => {
      if (!holding) return;
      const ratio = Math.min(1, (performance.now() - startedAt) / 1600);
      charge.style.setProperty("--charge", String(ratio));
      $("#chargeCaption").textContent = ratio >= 1 ? "Energy gathered" : `Breathe · ${Math.round(ratio * 100)}%`;
      if (ratio >= 1) { holding = false; charge.classList.add("charged"); finishCharge(); return; }
      raf = requestAnimationFrame(tick);
    };
    charge.addEventListener("pointerdown", event => { event.preventDefault(); holding = true; startedAt = performance.now(); charge.classList.add("charging"); tick(); });
    const stop = () => { if (!holding) return; holding = false; cancelAnimationFrame(raf); resetOrb(); };
    charge.addEventListener("pointerup", stop); charge.addEventListener("pointercancel", stop); charge.addEventListener("pointerleave", stop);
  }
  const stack = $("#shuffleStack");
  if (stack) {
    let dragging = false, lastX = 0, distance = 0;
    const update = () => {
      const ratio = Math.min(1, distance / 320);
      if ($("#shuffleProgress")) $("#shuffleProgress").style.width = `${ratio * 100}%`;
      $$("i", stack).forEach((node, index) => { const base = [-11, -4, 4, 11][index]; node.style.transform = `rotate(${base + Math.sin(distance / 32 + index) * 10}deg) translateX(${[-28,-9,10,30][index] + Math.sin(distance / 24 + index) * 9}px)`; });
      if (ratio >= 1) completeShuffle();
    };
    stack.addEventListener("pointerdown", event => { dragging = true; lastX = event.clientX; distance = 0; stack.setPointerCapture?.(event.pointerId); stack.style.cursor = "grabbing"; });
    stack.addEventListener("pointermove", event => { if (!dragging) return; distance += Math.abs(event.clientX - lastX); lastX = event.clientX; update(); });
    const finish = () => { dragging = false; stack.style.cursor = "grab"; };
    stack.addEventListener("pointerup", finish); stack.addEventListener("pointercancel", finish);
  }
}
function bindAudioEvents() {
  audioEl.addEventListener("timeupdate", () => {
    if ($("#audioProgress") && audioEl.duration) $("#audioProgress").style.width = `${(audioEl.currentTime / audioEl.duration) * 100}%`;
    if ($("#audioCurrent")) $("#audioCurrent").textContent = formatTime(audioEl.currentTime);
  });
  audioEl.addEventListener("play", () => { UI.audio.playing = true; updateAudioUI(); });
  audioEl.addEventListener("pause", () => { UI.audio.playing = false; updateAudioUI(); });
  audioEl.addEventListener("error", () => toast("The local audio could not load. Open the demo through the local server."));
}
function initStars() {
  const canvas = $("#starCanvas"); if (!canvas) return;
  const context = canvas.getContext("2d"); let width = 0, height = 0, stars = [];
  const resize = () => {
    const ratio = Math.min(devicePixelRatio || 1, 2); width = innerWidth; height = innerHeight;
    canvas.width = width * ratio; canvas.height = height * ratio; canvas.style.width = `${width}px`; canvas.style.height = `${height}px`; context.setTransform(ratio, 0, 0, ratio, 0, 0);
    stars = Array.from({ length: 72 }, () => ({ x: Math.random() * width, y: Math.random() * height, r: Math.random() * 1.4 + .3, a: Math.random() * Math.PI * 2, speed: Math.random() * .18 + .04 }));
  };
  const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const draw = () => {
    context.clearRect(0, 0, width, height);
    stars.forEach(star => {
      if (!reduced && motionEnabled()) { star.y -= star.speed; star.a += .008; if (star.y < -4) { star.y = height + 4; star.x = Math.random() * width; } }
      const alpha = .18 + Math.sin(star.a) * .13; context.beginPath(); context.arc(star.x, star.y, star.r, 0, Math.PI * 2); context.fillStyle = `rgba(105,160,184,${alpha})`; context.fill();
    });
    if (!reduced) requestAnimationFrame(draw);
  };
  addEventListener("resize", resize, { passive: true }); resize(); requestAnimationFrame(draw);
}
function initSoftInteractions() {
  if (!$(".pointer-glow")) {
    const glow = document.createElement("div");
    glow.className = "pointer-glow";
    glow.setAttribute("aria-hidden", "true");
    document.body.prepend(glow);
  }
  const reduced = matchMedia("(prefers-reduced-motion: reduce)").matches;
  let lastPointerAt = 0;
  document.addEventListener("pointermove", event => {
    if (reduced || !motionEnabled()) return;
    const now = performance.now();
    if (now - lastPointerAt < 16) return;
    lastPointerAt = now;
    document.documentElement.style.setProperty("--pointer-x", event.clientX + "px");
    document.documentElement.style.setProperty("--pointer-y", event.clientY + "px");
    document.body.classList.add("pointer-active");
    const hero = $(".hero");
    if (hero && UI.page === "home") {
      const rect = hero.getBoundingClientRect();
      if (event.clientX >= rect.left && event.clientX <= rect.right && event.clientY >= rect.top && event.clientY <= rect.bottom) {
        const nx = (event.clientX - rect.left) / rect.width - .5;
        const ny = (event.clientY - rect.top) / rect.height - .5;
        hero.style.setProperty("--orbit-x", nx * 14 + "px");
        hero.style.setProperty("--orbit-y", ny * 10 + "px");
        hero.style.setProperty("--hero-glow-x", (nx + .5) * 100 + "%");
        hero.style.setProperty("--hero-glow-y", (ny + .5) * 100 + "%");
      }
    }
  }, { passive: true });
  window.addEventListener("blur", () => document.body.classList.remove("pointer-active"));
  document.addEventListener("pointerdown", event => {
    if (reduced || !motionEnabled() || !(event.target instanceof Element)) return;
    const button = event.target.closest("button.primary-button, button.soft-button, button.mini-action, button.icon-button, .segmented button, .choice-chip, .nav-item, .audio-play, .chat-compose button");
    if (!button || button.disabled) return;
    const rect = button.getBoundingClientRect();
    if (!rect.width || !rect.height) return;
    if (getComputedStyle(button).position === "static") button.classList.add("ripple-host");
    const ripple = document.createElement("span");
    const size = Math.max(rect.width, rect.height) * 1.8;
    ripple.className = "press-ripple";
    ripple.style.width = size + "px";
    ripple.style.height = size + "px";
    ripple.style.left = event.clientX - rect.left + "px";
    ripple.style.top = event.clientY - rect.top + "px";
    button.appendChild(ripple);
    setTimeout(() => ripple.remove(), 720);
  }, { passive: true });
}
function init() {
  const savedTheme = load("theme", null); if (savedTheme) document.documentElement.dataset.theme = savedTheme;
  const savedMotion = load("motion", null);
  const motionOn = savedMotion === null ? !matchMedia("(prefers-reduced-motion: reduce)").matches : Boolean(savedMotion);
  document.documentElement.dataset.motion = motionOn ? "on" : "off";
  updateToday(); initSoftInteractions(); bindStaticEvents(); initStars(); renderAll(); showPage("home");
  setTimeout(() => toast("English interactive demo is ready · use ↻ to replay onboarding"), 650);
}
document.addEventListener("DOMContentLoaded", init);
