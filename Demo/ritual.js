let ritualMuted = Boolean(load(`ritualMuted`, false));
let ritualNoiseBuffer = null;
const ritualAudio = {
  context: null, master: null, delay: null, wet: null, timer: null, drones: [], mode: null, step: 0, playing: false,
  ensure() {
    if (!this.context) {
      const AudioContextClass = window.AudioContext || window.webkitAudioContext;
      if (!AudioContextClass) return null;
      const context = new AudioContextClass();
      this.context = context;
      this.master = context.createGain();
      this.master.gain.value = .0001;
      this.master.connect(context.destination);
      const delay = context.createDelay(1);
      delay.delayTime.value = .37;
      const feedback = context.createGain();
      feedback.gain.value = .24;
      const damp = context.createBiquadFilter();
      damp.type = `lowpass`;
      damp.frequency.value = 2400;
      this.wet = context.createGain();
      this.wet.gain.value = .16;
      this.master.connect(delay);
      delay.connect(damp);
      damp.connect(feedback);
      feedback.connect(delay);
      damp.connect(this.wet);
      this.wet.connect(context.destination);
      const length = Math.max(1, Math.floor(context.sampleRate * .24));
      ritualNoiseBuffer = context.createBuffer(1, length, context.sampleRate);
      const channel = ritualNoiseBuffer.getChannelData(0);
      for (let i = 0; i < length; i += 1) channel[i] = Math.random() * 2 - 1;
    }
    if (this.context.state === `suspended`) this.context.resume().catch(() => {});
    return this.context;
  },
  start(mode) {
    this.mode = mode;
    if (ritualMuted) { updateRitualSoundUI(); return; }
    if (this.playing && this.mode === mode) {
      this.ensure();
      updateRitualSoundUI();
      return;
    }
    this.begin();
  },
  begin() {
    const context = this.ensure();
    if (!context || !this.mode || ritualMuted) return;
    this.halt(false);
    this.playing = true;
    this.step = 0;
    const now = context.currentTime;
    this.master.gain.cancelScheduledValues(now);
    this.master.gain.setValueAtTime(Math.max(.0001, this.master.gain.value), now);
    this.master.gain.exponentialRampToValueAtTime(.16, now + .65);
    this.startDrones();
    this.tick();
    this.timer = setInterval(() => this.tick(), this.mode === `tarot` ? 1800 : 1100);
    updateRitualSoundUI();
  },
  startDrones() {
    const context = this.context;
    const now = context.currentTime;
    const specs = this.mode === `tarot` ? [[73.42, .024, `sine`], [110, .014, `triangle`], [146.83, .006, `sine`]] : [[73.42, .016, `sine`], [146.83, .008, `triangle`]];
    specs.forEach(([frequency, volume, type], index) => {
      const oscillator = context.createOscillator();
      const gain = context.createGain();
      const filter = context.createBiquadFilter();
      const lfo = context.createOscillator();
      const lfoGain = context.createGain();
      oscillator.type = type;
      oscillator.frequency.value = frequency;
      filter.type = `lowpass`;
      filter.frequency.value = this.mode === `tarot` ? 620 : 760;
      gain.gain.value = volume;
      lfo.frequency.value = .055 + index * .021;
      lfoGain.gain.value = volume * .42;
      lfo.connect(lfoGain);
      lfoGain.connect(gain.gain);
      oscillator.connect(filter);
      filter.connect(gain);
      gain.connect(this.master);
      oscillator.start(now);
      lfo.start(now);
      this.drones.push({ oscillator, lfo });
    });
  },
  tone(frequency, when, duration, volume, type = `sine`, cutoff = 1800) {
    const context = this.context;
    if (!context || !this.master) return;
    const oscillator = context.createOscillator();
    const filter = context.createBiquadFilter();
    const gain = context.createGain();
    oscillator.type = type;
    oscillator.frequency.setValueAtTime(frequency, when);
    filter.type = `lowpass`;
    filter.frequency.setValueAtTime(cutoff, when);
    gain.gain.setValueAtTime(.0001, when);
    gain.gain.exponentialRampToValueAtTime(Math.max(.0002, volume), when + Math.min(.18, duration * .15));
    gain.gain.exponentialRampToValueAtTime(.0001, when + duration);
    oscillator.connect(filter);
    filter.connect(gain);
    gain.connect(this.master);
    oscillator.start(when);
    oscillator.stop(when + duration + .08);
  },
  bell(frequency, when, volume = .022, duration = 3.4) {
    this.tone(frequency, when, duration, volume, `sine`, 2600);
    this.tone(frequency * 2.01, when + .012, duration * .6, volume * .32, `sine`, 3200);
  },
  pluck(frequency, when, volume = .032) {
    this.tone(frequency, when, 1.35, volume, `triangle`, 2100);
    this.tone(frequency * 2, when + .008, .53, volume * .18, `sine`, 2800);
  },
  gong(frequency, when, volume = .026) {
    this.tone(frequency, when, 5.8, volume, `sine`, 460);
    this.tone(frequency * 1.48, when + .03, 4.4, volume * .38, `sine`, 720);
  },
  noise(when, duration, volume, frequency) {
    const context = this.context;
    if (!context || !this.master || !ritualNoiseBuffer) return;
    const source = context.createBufferSource();
    const filter = context.createBiquadFilter();
    const gain = context.createGain();
    source.buffer = ritualNoiseBuffer;
    filter.type = `bandpass`;
    filter.frequency.value = frequency;
    filter.Q.value = .85;
    gain.gain.setValueAtTime(.0001, when);
    gain.gain.exponentialRampToValueAtTime(volume, when + .008);
    gain.gain.exponentialRampToValueAtTime(.0001, when + duration);
    source.connect(filter);
    filter.connect(gain);
    gain.connect(this.master);
    source.start(when);
    source.stop(when + duration + .03);
  },
  tick() {
    const context = this.context;
    if (!context || !this.playing) return;
    const now = context.currentTime + .07;
    if (this.mode === `tarot`) {
      const notes = [293.66, 349.23, 440, 392, 523.25, 440, 349.23, 293.66];
      if (this.step % 2 === 0) this.bell(notes[this.step % notes.length], now, .026, 3.9);
      if (this.step % 4 === 0) this.tone(notes[(this.step + 3) % notes.length] / 2, now, 5.2, .016, `sine`, 900);
      if (this.step % 8 === 6) this.gong(73.42, now, .022);
    } else {
      const notes = [587.33, 440, 493.88, 369.99, 440, 329.63, 369.99, 440];
      this.pluck(notes[this.step % notes.length], now, .034);
      if (this.step % 4 === 0) this.tone(293.66, now, 4.4, .013, `sine`, 720);
      if (this.step % 8 === 7) this.bell(880, now, .018, 2.8);
    }
    this.step += 1;
  },
  shake() {
    if (ritualMuted) return;
    const context = this.ensure();
    if (!context || !this.master) return;
    const now = context.currentTime + .03;
    [0, .09, .18, .3].forEach((offset, index) => {
      this.noise(now + offset, .055, .04 - index * .004, 1250 + index * 90);
      this.tone(220 - index * 11, now + offset, .12, .01, `triangle`, 900);
    });
  },
  chime() {
    if (ritualMuted) return;
    const context = this.ensure();
    if (!context) return;
    const now = context.currentTime + .04;
    [880, 1174.66, 1567.98].forEach((frequency, index) => this.bell(frequency, now + index * .12, .024, 3.1));
  },
  surge() {
    if (ritualMuted) return;
    const context = this.ensure();
    if (!context) return;
    this.gong(this.mode === `wish` ? 82.41 : 73.42, context.currentTime + .03, .028);
    this.bell(587.33, context.currentTime + .18, .022, 3.6);
  },
  pause() {
    this.halt();
  },
  resume() {
    if (this.mode && !ritualMuted) this.begin();
  },
  stop() {
    this.mode = null;
    this.halt();
  },
  halt(fade = true) {
    if (this.timer) { clearInterval(this.timer); this.timer = null; }
    const context = this.context;
    if (context && this.master) {
      const now = context.currentTime;
      this.master.gain.cancelScheduledValues(now);
      this.master.gain.setValueAtTime(Math.max(.0001, this.master.gain.value), now);
      this.master.gain.exponentialRampToValueAtTime(.0001, now + (fade ? .8 : .02));
    }
    this.drones.forEach(({ oscillator, lfo }) => {
      try { oscillator.stop(context.currentTime + (fade ? .85 : .04)); } catch {}
      try { lfo.stop(context.currentTime + (fade ? .85 : .04)); } catch {}
    });
    this.drones = [];
    this.playing = false;
    updateRitualSoundUI();
  }
};
function ritualSoundMarkup() {
  return `<button class='ritual-sound ${ritualMuted ? `is-muted` : ``}' type='button' data-ritual-sound='1' aria-label='Toggle ritual music' aria-pressed='${ritualMuted ? `false` : `true`}'><span class='sound-bars' aria-hidden='true'><i></i><i></i><i></i><i></i></span><span class='sound-copy'>${ritualMuted ? `Sound off` : `Sound on`}</span></button>`;
}
function updateRitualSoundUI() {
  document.querySelectorAll(`[data-ritual-sound]`).forEach(button => {
    button.classList.toggle(`is-muted`, ritualMuted);
    button.classList.toggle(`is-playing`, ritualAudio.playing && !ritualMuted);
    button.setAttribute(`aria-pressed`, ritualMuted ? `false` : `true`);
    const label = button.querySelector(`.sound-copy`);
    if (label) label.textContent = ritualMuted ? `Sound off` : ritualAudio.playing ? `Sound on` : `Sound ready`;
  });
}
function toggleRitualSound() {
  if (!ritualMuted && !ritualAudio.playing) {
    const mode = UI.page === `tarot` ? `tarot` : UI.page === `wish` ? `wish` : null;
    if (mode) {
      ritualAudio.start(mode);
      updateRitualSoundUI();
      return;
    }
  }
  ritualMuted = !ritualMuted;
  save(`ritualMuted`, ritualMuted);
  if (ritualMuted) ritualAudio.pause();
  else ritualAudio.resume();
  updateRitualSoundUI();
}
function enhanceTarotDom() {
  const copy = document.querySelector(`#page-tarot .ritual-copy`);
  const step = $(`#tarotStepLabel`);
  if (copy && step && !copy.querySelector(`.ritual-kicker`)) {
    const kicker = document.createElement(`div`);
    kicker.className = `ritual-kicker`;
    step.parentNode.insertBefore(kicker, step);
    kicker.appendChild(step);
    const holder = document.createElement(`span`);
    holder.innerHTML = ritualSoundMarkup();
    kicker.appendChild(holder.firstElementChild);
  }
  const wrap = $(`#chargeWrap`);
  if (wrap && !wrap.querySelector(`.tarot-night`)) {
    wrap.insertAdjacentHTML(`afterbegin`, `<div class='tarot-night' aria-hidden='true'></div><span class='charge-halo' aria-hidden='true'></span><span class='charge-rings' aria-hidden='true'><i></i><i></i><i></i><i></i></span>`);
  }
  const orb = $(`#chargeBtn`);
  if (orb && !orb.querySelector(`.orb-progress`)) orb.insertAdjacentHTML(`afterbegin`, `<span class='orb-progress' aria-hidden='true'></span><span class='orb-moon' aria-hidden='true'></span>`);
  const stack = $(`#shuffleStack`);
  if (stack) while (stack.children.length < 7) stack.appendChild(document.createElement(`i`));
  updateRitualSoundUI();
}
const ritualBaseShowPage = showPage;
showPage = function(page) {
  const previousPage = UI.page;
  ritualBaseShowPage(page);
  if (![`tarot`, `wish`].includes(page)) ritualAudio.stop();
  else if (page !== previousPage && ritualAudio.mode && ritualAudio.mode !== page) ritualAudio.stop();
};
resetTarot = function() {
  ritualAudio.stop();
  UI.tarot = { stage: `charge`, shuffle: 0, cards: [], chosen: null, card: null, cleansed: false };
  renderTarotScene();
};
renderTarotScene = function() {
  enhanceTarotDom();
  const tarot = UI.tarot;
  const chargeWrap = $(`#chargeWrap`), shuffleZone = $(`#shuffleZone`), stage = $(`#cardStage`);
  if (!chargeWrap || !shuffleZone || !stage) return;
  const panel = document.querySelector(`#page-tarot .ritual-panel`);
  if (panel) panel.dataset.stage = tarot.stage;
  chargeWrap.classList.toggle(`hidden`, tarot.stage !== `charge`);
  shuffleZone.classList.toggle(`hidden`, tarot.stage !== `shuffle`);
  stage.classList.toggle(`hidden`, ![`choose`, `reading`].includes(tarot.stage));
  $(`#tarotStepLabel`).textContent = tarot.stage === `charge` ? `Step 1 / Hold to gather energy` : tarot.stage === `shuffle` ? `Step 2 / Shuffle by hand` : tarot.stage === `choose` ? `Step 3 / You choose the card` : `Step 4 / A gentle reflection`;
  $(`#tarotPrompt`).textContent = tarot.stage === `charge` ? `Bring your attention back to now` : tarot.stage === `shuffle` ? `Let the deck move with your breath` : tarot.stage === `choose` ? `Choose by intuition, not by explanation` : `This is not a prediction; it is a mirror for this moment`;
  $(`#tarotHint`).textContent = tarot.stage === `charge` ? `Hold the moon orb for 1.6 seconds and take one quiet breath.` : tarot.stage === `shuffle` ? `Press the deck and drag left or right until the shuffle is complete.` : tarot.stage === `choose` ? `Swipe the row or look closely, then tap the card that draws you. You choose freely.` : `After reading, swipe to soften the card and reveal the emotional keyword.`;
  if (tarot.stage === `choose` || tarot.stage === `reading`) {
    stage.innerHTML = tarot.cards.map((card, index) => `<button class='tarot-card ${currentSkinClass(`tarot`)} ${tarot.chosen === index ? `flipped` : ``} ${tarot.chosen !== null && tarot.chosen !== index ? `is-dimmed` : ``}' data-tarot-index='${index}' aria-label='Reveal ${card.name}' style='--deal:${index}'><span class='tarot-inner'><span class='card-face card-back'><span class='card-back-frame'>${tarotBackMarkup()}</span><span class='card-number'>${ritualRoman(index)}</span><span class='card-back-title'>MELLOW MIND</span></span><span class='card-face card-front'><span class='card-corner'>${ritualRoman(index)}</span>${tarotArtMarkup(card)}<span class='card-caption'><strong>${card.name}</strong><small>${card.theme}</small></span></span></span></button>`).join(``);
  }
  updateRitualSoundUI();
  renderTarotReading();
};
finishCharge = function() {
  if (UI.tarot.stage !== `charge`) return;
  ritualAudio.start(`tarot`);
  ritualAudio.surge();
  UI.tarot.stage = `shuffle`;
  vibrate([18, 40, 22]);
  toast(`Energy gathered. Let the illustrated deck loosen.`);
  renderTarotScene();
};
completeShuffle = function() {
  if (UI.tarot.stage !== `shuffle`) return;
  UI.tarot.cards = [...TAROT_CARDS].sort(() => Math.random() - .5).slice(0, 3);
  UI.tarot.stage = `choose`;
  ritualAudio.chime();
  vibrate([12, 30, 12, 30, 12]);
  renderTarotScene();
};
chooseTarot = function(index) {
  if (UI.tarot.stage !== `choose`) return;
  UI.tarot.chosen = index;
  UI.tarot.card = UI.tarot.cards[index];
  UI.tarot.stage = `reading`;
  ritualAudio.surge();
  vibrate([20, 35, 24]);
  renderTarotScene();
  setTimeout(() => $(`#tarotReading`)?.scrollIntoView({ behavior: `smooth`, block: `nearest` }), 520);
};
renderTarotReading = function() {
  const box = $(`#tarotReading`), card = UI.tarot.card;
  if (!box) return;
  if (!card) { box.innerHTML = ``; return; }
  const p = personaFor(state.profile);
  const roman = ritualRoman(TAROT_CARDS.findIndex(item => item.name === card.name));
  box.innerHTML = `<article class='glass reading-card tarot-reading-card'><div class='reading-showcase'><div class='reading-art-frame'><span class='reading-art-glow'></span>${tarotArtMarkup(card)}<span class='reading-art-seal'>${roman}</span></div><div class='reading-hero'><div class='reading-sigil'>${card.glyph}</div><div><p class='eyebrow'>CURRENT INNER WEATHER</p><h3>${card.name} / ${card.theme}</h3><p>A reflection shaped by ${state.profile.sign} / ${state.profile.zodiac} / Type ${state.profile.blood}</p></div></div></div><div class='reading-sections'><div class='reading-section'><small>Your present emotional state</small><p>${card.emotion}</p></div><div class='reading-section'><small>A thought you may be overlooking</small><p>${card.ignored}</p></div><div class='reading-section'><small>A gentle way to soothe yourself</small><p>${card.advice}</p></div></div><div class='keyword-bar'><div><small>Emotional keyword for today</small><strong id='tarotKeyword'>${UI.tarot.cleansed ? card.keyword : `Swipe to let the word emerge`}</strong></div><button class='mini-action' data-collect-tarot='1'>Save this reflection</button></div><div class='cleanse-wrap'><p style='margin:0 0 10px;color:var(--soft-ink);font-size:.75rem'>Swipe right to soften the card. This is a small body-based gesture of self-soothing, not a magical effect.</p><div class='cleanse-track' id='cleanseTrack'><i class='cleanse-fill' id='cleanseFill'></i><span id='cleanseLabel'>Press and swipe right</span></div></div><div class='button-row' style='margin-top:14px'><button class='soft-button' id='resetTarotBtn'>Draw again</button><span class='tag'>${p.sign.relief.split(`.`)[0]}</span></div></article>`;
  box.querySelector(`.reading-showcase`)?.insertAdjacentHTML(`beforebegin`, `<div class='reading-tools'>${ritualSoundMarkup()}</div>`);
  bindCleanse();
  $(`#resetTarotBtn`)?.addEventListener(`click`, resetTarot);
};
bindTarotGestures = function() {
  const charge = $(`#chargeBtn`);
  const chargeWrap = $(`#chargeWrap`);
  if (charge) {
    let holding = false, startedAt = 0, raf;
    const resetOrb = () => {
      charge.style.setProperty(`--charge`, 0);
      charge.classList.remove(`charging`, `charged`);
      chargeWrap?.classList.remove(`is-charging`, `is-charged`);
      if ($(`#chargeCaption`)) $(`#chargeCaption`).textContent = `Breathe / soften your shoulders`;
    };
    const tick = () => {
      if (!holding) return;
      const ratio = Math.min(1, (performance.now() - startedAt) / 1600);
      charge.style.setProperty(`--charge`, String(ratio));
      chargeWrap?.style.setProperty(`--charge`, String(ratio));
      if ($(`#chargeCaption`)) $(`#chargeCaption`).textContent = ratio >= 1 ? `The deck is listening` : `Breathe / ${Math.round(ratio * 100)}%`;
      if (ratio >= 1) {
        holding = false;
        charge.classList.add(`charged`);
        chargeWrap?.classList.add(`is-charged`);
        finishCharge();
        return;
      }
      raf = requestAnimationFrame(tick);
    };
    charge.addEventListener(`pointerdown`, event => {
      event.preventDefault();
      ritualAudio.start(`tarot`);
      holding = true;
      startedAt = performance.now();
      charge.classList.add(`charging`);
      chargeWrap?.classList.add(`is-charging`);
      tick();
    });
    const stop = () => {
      if (!holding) return;
      holding = false;
      cancelAnimationFrame(raf);
      resetOrb();
      if (UI.tarot.stage === `charge`) ritualAudio.pause();
    };
    charge.addEventListener(`pointerup`, stop);
    charge.addEventListener(`pointercancel`, stop);
    charge.addEventListener(`pointerleave`, stop);
  }
  const stack = $(`#shuffleStack`);
  if (stack) {
    let cards = $$(`i`, stack);
    let dragging = false, lastX = 0, distance = 0, lastSound = 0;
    const update = () => {
      const ratio = Math.min(1, distance / 320);
      if ($(`#shuffleProgress`)) $(`#shuffleProgress`).style.width = `${ratio * 100}%`;
      cards.forEach((node, index) => {
        const center = (index - (cards.length - 1) / 2) * 4;
        node.style.transform = `rotate(${center + Math.sin(distance / 31 + index) * 12}deg) translate(${(index - (cards.length - 1) / 2) * 16 + Math.sin(distance / 24 + index) * 10}px, ${Math.abs(Math.sin(distance / 35 + index)) * -7}px)`;
      });
      if (distance - lastSound > 78) { lastSound = distance; ritualAudio.shake(); }
      if (ratio >= 1) completeShuffle();
    };
    stack.addEventListener(`pointerdown`, event => {
      ritualAudio.start(`tarot`);
      cards = $$(`i`, stack);
      dragging = true;
      lastX = event.clientX;
      distance = 0;
      lastSound = 0;
      stack.classList.add(`is-shuffling`);
      try { stack.setPointerCapture?.(event.pointerId); } catch {}
    });
    stack.addEventListener(`pointermove`, event => {
      if (!dragging) return;
      distance += Math.abs(event.clientX - lastX);
      lastX = event.clientX;
      update();
    });
    const finish = () => { dragging = false; stack.classList.remove(`is-shuffling`); };
    stack.addEventListener(`pointerup`, finish);
    stack.addEventListener(`pointercancel`, finish);
  }
};
document.addEventListener(`click`, event => {
  if (event.target.closest(`[data-ritual-sound]`)) {
    toggleRitualSound();
    return;
  }
  const wishTab = event.target.closest(`[data-wish]`);
  if (wishTab && wishTab.dataset.wish !== `draw`) ritualAudio.stop();
});
document.addEventListener(`pointerdown`, event => {
  if (ritualMuted || ritualAudio.playing) return;
  if (event.target.closest(`[data-ritual-sound], [data-page], [data-go], [data-wish], a`)) return;
  if (UI.page === `tarot`) ritualAudio.start(`tarot`);
  else if (UI.page === `wish` && UI.wishTab === `draw`) ritualAudio.start(`wish`);
}, { passive: true });
document.addEventListener(`DOMContentLoaded`, () => {
  updateRitualSoundUI();
});
renderWishDraw = function() {
  const ritual = UI.wishRitual, box = $(`#wishContent`);
  if (!box) return;
  if (ritual.result) {
    const category = WISH_CATEGORIES[ritual.result.index];
    box.innerHTML = `<article class='glass wish-oracle'><span class='wish-oracle-halo'></span><div class='wish-fortune-slip'><span class='wish-slip-thread'></span><span class='wish-slip-stamp ${currentSkinClass(`tube`)}'>${category.glyph}</span><div class='wish-oracle-art'>${wishArtMarkup(category.name)}</div><small>LOT ${ritualRoman(ritual.result.index)}</small><h3>${category.name}</h3><p>${category.note}</p><span class='wish-oracle-sign'>A note for this moment</span></div><div class='wish-oracle-copy'><p class='eyebrow'>A GENTLE NOTE FOR NOW</p><h3>${category.name} / ${category.note}</h3><p class='wish-oracle-line'>${ritual.result.line}</p><div class='button-row'><button class='primary-button' data-collect-wish='1'>Save this wish note</button><button class='soft-button' id='resetWishRitual'>Draw again</button></div><p class='wish-fineprint'>This note offers a gentle everyday prompt. It does not judge good or bad fortune and does not predict the future.</p></div></article>`;
    box.querySelector(`.wish-oracle-copy`)?.insertAdjacentHTML(`afterbegin`, `<div class='wish-oracle-tools'>${ritualSoundMarkup()}</div>`);
    $(`#resetWishRitual`)?.addEventListener(`click`, () => {
      ritualAudio.stop();
      UI.wishRitual = { blessed: false, shaken: false, result: null, drawing: false };
      renderWishDraw();
    });
    updateRitualSoundUI();
    return;
  }
  const stageText = !ritual.blessed ? `Step 1 / Make a wish in the moonlight` : !ritual.shaken ? `Step 2 / Shake the bamboo tube` : `Step 3 / Pull one wish stick`;
  const actions = !ritual.blessed ? `<button class='primary-button wish-primary' id='prayBtn'><span class='wish-button-orb' aria-hidden='true'></span><span class='wish-button-copy'>Palms together / hold to make a wish</span></button><p class='wish-whisper'>Hold for 1.6 seconds. Let the incense smoke and the soft bell carry the moment.</p>` : !ritual.shaken ? `<button class='primary-button wish-primary' id='shakeBtn'>Shake the bamboo wish tube</button><button class='text-button' id='enableMotionBtn'>Enable real device shake</button>` : `<p class='wish-whisper'>The sticks have settled. Follow your instinct and pull one by hand.</p>`;
  const sticks = ritual.shaken ? `<div class='draw-sticks'>${WISH_CATEGORIES.map((category, index) => `<button class='stick-choice' data-stick-index='${index}' aria-label='Pull wish stick ${index + 1}, ${category.name}'><span class='stick-choice-number'>${ritualRoman(index)}</span><span class='stick-choice-art'>${wishArtMarkup(category.name)}</span><span class='stick-choice-name'>${category.name}</span><span class='stick-choice-seal'>${category.glyph}</span></button>`).join(``)}</div>` : ``;
  box.innerHTML = `<div class='ritual-grid wish-ritual-grid'><article class='glass wish-altar ${ritual.blessed ? `is-blessed` : ``} ${ritual.shaken ? `is-ready` : ``}'><div class='wish-ritual-head'><div class='step-pill'>${stageText}</div>${ritualSoundMarkup()}</div><div class='wish-ceremony'>${wishShrineMarkup(ritual)}</div><div class='wish-controls'>${actions}</div>${sticks}</article><article class='glass wish-card wish-guide'><p class='eyebrow'>RITUAL GUIDE</p><h3>Turn a wish into a small act of care</h3><div class='wish-guide-badges'><span>Original music</span><span>Hand-drawn art</span><span>Haptics</span></div><div class='clean-list'><div class='clean-item'><span>01</span><div><b>Make a wish</b><br>Keep one feeling you want to hold close. The ritual does not promise an outcome.</div></div><div class='clean-item'><span>02</span><div><b>Shake the tube</b><br>The bamboo sticks, incense, and sound respond to your gesture.</div></div><div class='clean-item'><span>03</span><div><b>Pull by hand</b><br>You choose the stick yourself. The note is a gentle prompt for the present.</div></div></div><div class='keyword-bar'><div><small>Five wish themes</small><strong>Peace / Healing / Ease / Flow / Tenderness</strong></div></div></article></div>`;
  bindWishDraw();
  updateRitualSoundUI();
};
bindWishDraw = function() {
  const pray = $(`#prayBtn`);
  if (pray) {
    let holding = false, startedAt = 0, raf;
    const altar = pray.closest(`.wish-altar`);
    const resetPray = () => {
      holding = false;
      cancelAnimationFrame(raf);
      altar?.classList.remove(`is-praying`);
      altar?.style.setProperty(`--pray`, 0);
      pray.style.setProperty(`--pray`, 0);
      pray.innerHTML = `<span class='wish-button-orb' aria-hidden='true'></span><span class='wish-button-copy'>Palms together / hold to make a wish</span>`;
      if (!UI.wishRitual.blessed) ritualAudio.pause();
    };
    const tick = () => {
      if (!holding) return;
      const ratio = Math.min(1, (performance.now() - startedAt) / 1600);
      altar?.style.setProperty(`--pray`, String(ratio));
      pray.style.setProperty(`--pray`, String(ratio));
      const copy = pray.querySelector(`.wish-button-copy`);
      if (copy) copy.textContent = ratio >= 1 ? `The wish has been received` : `Palms together / ${Math.round(ratio * 100)}%`;
      if (ratio >= 1) {
        holding = false;
        UI.wishRitual.blessed = true;
        ritualAudio.surge();
        vibrate([15, 35, 18]);
        toast(`Wish received. The bamboo tube is listening.`);
        renderWishDraw();
        return;
      }
      raf = requestAnimationFrame(tick);
    };
    pray.addEventListener(`pointerdown`, event => {
      event.preventDefault();
      ritualAudio.start(`wish`);
      holding = true;
      startedAt = performance.now();
      altar?.classList.add(`is-praying`);
      tick();
    });
    pray.addEventListener(`pointerup`, resetPray);
    pray.addEventListener(`pointercancel`, resetPray);
    pray.addEventListener(`pointerleave`, () => { if (holding) resetPray(); });
  }
  $(`#shakeBtn`)?.addEventListener(`click`, triggerWishShake);
  $(`#enableMotionBtn`)?.addEventListener(`click`, enableRealMotion);
  document.querySelectorAll(`[data-stick-index]`).forEach(button => button.addEventListener(`click`, () => drawWishStick(Number(button.dataset.stickIndex), button)));
};
triggerWishShake = function() {
  if (!UI.wishRitual.blessed || UI.wishRitual.shaken) return;
  const scene = $(`#wishTubeScene`);
  const altar = document.querySelector(`.wish-altar`);
  const shrine = document.querySelector(`.wish-shrine`);
  scene?.classList.add(`is-shaking`);
  altar?.classList.add(`is-shaking`);
  shrine?.classList.add(`is-shaking`);
  ritualAudio.start(`wish`);
  ritualAudio.shake();
  vibrate([20, 28, 20, 28, 20, 28, 24]);
  setTimeout(() => {
    UI.wishRitual.shaken = true;
    ritualAudio.chime();
    renderWishDraw();
  }, 1050);
};
drawWishStick = function(index, sourceButton) {
  if (!UI.wishRitual.shaken || UI.wishRitual.result || UI.wishRitual.drawing) return;
  const category = WISH_CATEGORIES[index];
  if (!category) return;
  UI.wishRitual.drawing = true;
  sourceButton?.classList.add(`is-chosen`);
  document.querySelectorAll(`.stick-choice`).forEach(button => { if (button !== sourceButton) button.classList.add(`is-fading`); });
  document.querySelector(`.wish-shrine`)?.classList.add(`is-drawing`);
  ritualAudio.start(`wish`);
  const now = ritualAudio.ensure()?.currentTime || 0;
  ritualAudio.pluck(659.25, now + .02, .05);
  ritualAudio.noise(now + .02, .08, .035, 1800);
  vibrate([15, 30, 15]);
  setTimeout(() => {
    UI.wishRitual.result = { index, line: pick(category.lines, hash(`${dateKey()}-${state.profile.blood}-${index}`)) };
    UI.wishRitual.drawing = false;
    ritualAudio.surge();
    renderWishDraw();
  }, 820);
};
