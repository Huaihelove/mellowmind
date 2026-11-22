const base = "http://127.0.0.1:9224";
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
let list = [];
for (let i = 0; i < 30; i += 1) { try { list = await fetch(`${base}/json`).then(r => r.json()); if (list.length) break; } catch {} await delay(200); }
if (!list.length) throw new Error("CDP target unavailable");
const page = list.find(item => item.type === "page") || list[0];
const ws = new WebSocket(page.webSocketDebuggerUrl);
await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });
let nextId = 0;
const pending = new Map();
const exceptions = [];
ws.onmessage = event => {
  const message = JSON.parse(event.data);
  if (message.id && pending.has(message.id)) {
    const { resolve, reject } = pending.get(message.id); pending.delete(message.id);
    if (message.error) reject(new Error(message.error.message)); else resolve(message.result);
  }
  if (message.method === "Runtime.exceptionThrown") exceptions.push(message.params?.exceptionDetails?.text || "runtime exception");
};
const send = (method, params = {}) => new Promise((resolve, reject) => { const id = ++nextId; pending.set(id, { resolve, reject }); ws.send(JSON.stringify({ id, method, params })); });
const evaluate = async expression => {
  const result = await send("Runtime.evaluate", { expression, awaitPromise: true, returnByValue: true, userGesture: true });
  if (result.exceptionDetails) throw new Error(result.exceptionDetails.text || "evaluation failed");
  return result.result?.value;
};
await send("Runtime.enable"); await send("Page.enable");
await send("Emulation.setDeviceMetricsOverride", { width: 390, height: 844, deviceScaleFactor: 1, mobile: true });
await delay(900);
const language = await evaluate(`(() => {
  const han = /[\\u3400-\\u9fff]/;
  const scan = () => (document.body.innerText.match(han) || []).length;
  let cjk = scan();
  const pages = ['home','profile','tarot','wish','calendar','heal','collection'];
  for (const p of pages) { showPage(p); cjk += scan(); }
  showPage('wish'); UI.wishTab = 'wall'; renderWish(); cjk += scan(); UI.wishTab = 'seal'; renderWish(); cjk += scan(); UI.wishTab = 'checkin'; renderWish(); cjk += scan();
  showPage('heal'); UI.healTab = 'dissect'; renderHeal(); cjk += scan(); UI.healTab = 'audio'; renderHeal(); cjk += scan();
  showPage('collection'); UI.collectionTab = 'store'; renderCollection(); cjk += scan();
  openOnboarding(); cjk += scan(); closeModal(); openSettings(); cjk += scan(); closeModal(); openLegal('privacy'); cjk += scan(); closeModal();
  showPage('home');
  return { htmlLang: document.documentElement.lang, cjkVisible: cjk, title: document.title, viewport: innerWidth, scrollWidth: document.documentElement.scrollWidth, nav: getComputedStyle(document.querySelector('.mobile-nav')).display, footer: document.querySelector('.compliance-footer').innerText.includes('not a fortune-telling service') };
})()`);
const tarot = await evaluate(`(async () => { showPage('tarot'); finishCharge(); completeShuffle(); const stage = UI.tarot.stage; chooseTarot(0); await new Promise(r => setTimeout(r, 1000)); const sections = document.querySelectorAll('#tarotReading .reading-section').length; document.querySelector('[data-collect-tarot]')?.click(); return { stage, sections, keyword: Boolean(document.querySelector('#tarotKeyword')), saved: state.collections.length, card: UI.tarot.card?.name }; })()`);
const wish = await evaluate(`(async () => { showPage('wish'); UI.wishTab='draw'; UI.wishRitual={blessed:true,shaken:true,result:null}; renderWishDraw(); document.querySelector('[data-stick-index="0"]')?.click(); await new Promise(r => setTimeout(r, 1000)); const result = Boolean(UI.wishRitual.result); const note = document.querySelector('#wishContent')?.innerText.includes('does not predict the future') || false; document.querySelector('[data-collect-wish]')?.click(); return { result, note, themes: WISH_CATEGORIES.length, saved: state.collections.length }; })()`);
const healing = await evaluate(`(async () => { showPage('heal'); UI.healTab='dissect'; renderHeal(); document.querySelector('#dissectInput').value='I feel anxious about work and keep thinking I am not doing enough.'; document.querySelector('#dissectBtn').click(); await new Promise(r => setTimeout(r, 80)); const analysis = Boolean(document.querySelector('.analysis-result')); UI.healTab='tree'; renderHeal(); document.querySelector('#chatInput').value='I am tired and a little anxious.'; document.querySelector('#chatForm').dispatchEvent(new Event('submit',{bubbles:true,cancelable:true})); await new Promise(r => setTimeout(r, 800)); const replies = document.querySelectorAll('#chatMessages .chat-bubble').length; const audio = await fetch('../../MellowMind/Resources/Audio/cloud_rain.wav').then(r=>r.status).catch(()=>0); return { analysis, replies, audioStatus: audio }; })()`);
const onboarding = await evaluate(`(() => { openOnboarding(); const step0 = !document.querySelector('#modalBackdrop').classList.contains('hidden'); UI.onboardingStep=2; renderOnboarding(); const save = Boolean(document.querySelector('#onboardSave')); closeModal(); return { step0, save }; })()`);
console.log(JSON.stringify({ language, tarot, wish, healing, onboarding, exceptions }, null, 2));
ws.close();
