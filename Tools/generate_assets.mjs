import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";

const root = path.resolve(process.cwd());
const assets = path.join(root, "MellowMind", "Resources", "Assets.xcassets");
const audioDir = path.join(root, "MellowMind", "Resources", "Audio");
fs.mkdirSync(path.join(assets, "AppIcon.appiconset"), { recursive: true });
fs.mkdirSync(path.join(assets, "AccentColor.colorset"), { recursive: true });
fs.mkdirSync(path.join(assets, "LaunchBackground.colorset"), { recursive: true });
fs.mkdirSync(audioDir, { recursive: true });

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) {
    crc ^= byte;
    for (let i = 0; i < 8; i++) {
      crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
    }
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const typeBuffer = Buffer.from(type, "ascii");
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length, 0);
  const crcInput = Buffer.concat([typeBuffer, data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(crcInput), 0);
  return Buffer.concat([length, typeBuffer, data, crc]);
}

function writePng(file, width, height, pixels) {
  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 2;
  const raw = Buffer.alloc((width * 3 + 1) * height);
  for (let y = 0; y < height; y++) {
    const sourceRow = y * width * 4;
    const targetRow = y * (width * 3 + 1);
    raw[targetRow] = 0;
    for (let x = 0; x < width; x++) {
      const sourceIndex = sourceRow + x * 4;
      const targetIndex = targetRow + 1 + x * 3;
      const alpha = pixels[sourceIndex + 3] / 255;
      raw[targetIndex] = Math.round(pixels[sourceIndex] * alpha + 255 * (1 - alpha));
      raw[targetIndex + 1] = Math.round(pixels[sourceIndex + 1] * alpha + 255 * (1 - alpha));
      raw[targetIndex + 2] = Math.round(pixels[sourceIndex + 2] * alpha + 255 * (1 - alpha));
    }
  }
  const compressed = zlib.deflateSync(raw, { level: 9 });
  fs.writeFileSync(file, Buffer.concat([signature, chunk("IHDR", ihdr), chunk("IDAT", compressed), chunk("IEND", Buffer.alloc(0))]));
}

function mix(a, b, t) {
  return a + (b - a) * t;
}

function makeIcon() {
  const size = 1024;
  const pixels = Buffer.alloc(size * size * 4);
  const top = [168, 147, 196];
  const bottom = [137, 169, 195];
  const moonCenter = [508, 430];
  const moonRadius = 252;
  const moonOffset = [112, -38];
  const stars = [
    [260, 250, 9, 0.9], [778, 300, 6, 0.8], [252, 720, 5, 0.7],
    [815, 695, 8, 0.72], [640, 210, 4, 0.6], [368, 824, 4, 0.58]
  ];
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const i = (y * size + x) * 4;
      const t = y / (size - 1);
      let r = mix(top[0], bottom[0], t);
      let g = mix(top[1], bottom[1], t);
      let b = mix(top[2], bottom[2], t);

      const glow1 = Math.max(0, 1 - Math.hypot(x - 285, y - 270) / 560);
      const glow2 = Math.max(0, 1 - Math.hypot(x - 760, y - 760) / 520);
      r = Math.min(255, r + glow1 * 14 + glow2 * 2);
      g = Math.min(255, g + glow1 * 4 + glow2 * 12);
      b = Math.min(255, b + glow1 * 15 + glow2 * 7);

      const dx = x - moonCenter[0];
      const dy = y - moonCenter[1];
      const insideMoon = dx * dx + dy * dy < moonRadius * moonRadius;
      const cutX = x - (moonCenter[0] + moonOffset[0]);
      const cutY = y - (moonCenter[1] + moonOffset[1]);
      const insideCut = cutX * cutX + cutY * cutY < (moonRadius * 0.91) ** 2;
      const edge = Math.max(0, 1 - Math.abs(Math.hypot(dx, dy) - moonRadius) / 18);

      if (insideMoon && !insideCut) {
        const radial = Math.max(0, 1 - Math.hypot(dx + 28, dy + 30) / (moonRadius * 1.45));
        r = mix(251, 229, 1 - radial);
        g = mix(248, 223, 1 - radial);
        b = mix(255, 247, 1 - radial);
      }
      if (edge > 0) {
        r = Math.min(255, r + edge * 18);
        g = Math.min(255, g + edge * 20);
        b = Math.min(255, b + edge * 18);
      }

      for (const [sx, sy, radius, alpha] of stars) {
        const d = Math.hypot(x - sx, y - sy);
        if (d < radius) {
          const a = (1 - d / radius) * alpha;
          r = mix(r, 255, a);
          g = mix(g, 255, a);
          b = mix(b, 255, a);
        } else if (d < radius * 4) {
          const a = (1 - (d - radius) / (radius * 3)) * alpha * 0.18;
          r = mix(r, 255, a);
          g = mix(g, 255, a);
          b = mix(b, 255, a);
        }
      }

      pixels[i] = Math.round(r);
      pixels[i + 1] = Math.round(g);
      pixels[i + 2] = Math.round(b);
      pixels[i + 3] = 255;
    }
  }
  writePng(path.join(assets, "AppIcon.appiconset", "AppIcon-1024.png"), size, size, pixels);
}

function writeWav(file, samples, sampleRate = 22050) {
  const data = Buffer.alloc(samples.length * 2);
  for (let i = 0; i < samples.length; i++) {
    const clamped = Math.max(-1, Math.min(1, samples[i]));
    data.writeInt16LE(Math.round(clamped * 32767), i * 2);
  }
  const header = Buffer.alloc(44);
  header.write("RIFF", 0);
  header.writeUInt32LE(36 + data.length, 4);
  header.write("WAVE", 8);
  header.write("fmt ", 12);
  header.writeUInt32LE(16, 16);
  header.writeUInt16LE(1, 20);
  header.writeUInt16LE(1, 22);
  header.writeUInt32LE(sampleRate, 24);
  header.writeUInt32LE(sampleRate * 2, 28);
  header.writeUInt16LE(2, 32);
  header.writeUInt16LE(16, 34);
  header.write("data", 36);
  header.writeUInt32LE(data.length, 40);
  fs.writeFileSync(file, Buffer.concat([header, data]));
}

function rng(seed) {
  let state = seed >>> 0;
  return () => {
    state = (1664525 * state + 1013904223) >>> 0;
    return state / 4294967296;
  };
}

function smoothstep(value) {
  const x = Math.max(0, Math.min(1, value));
  return x * x * (3 - 2 * x);
}

function noteHz(midi) {
  return 440 * Math.pow(2, (midi - 69) / 12);
}

function chordVoice(chord, t) {
  let voice = 0;
  for (let i = 0; i < chord.length; i++) {
    const frequency = noteHz(chord[i]);
    const breathe = 0.82 + 0.18 * Math.sin(2 * Math.PI * 0.055 * t + i * 0.7);
    const tone = Math.sin(2 * Math.PI * frequency * t + i * 0.35);
    const overtone = Math.sin(2 * Math.PI * frequency * 2.003 * t + i * 0.9) * 0.34;
    voice += (tone + overtone) * breathe;
  }
  return voice / chord.length;
}

function addBell(samples, sampleRate, startSeconds, midi, durationSeconds, gain) {
  const start = Math.floor(startSeconds * sampleRate);
  const length = Math.min(samples.length - start, Math.floor(durationSeconds * sampleRate));
  if (start < 0 || length <= 0) return;
  const frequency = noteHz(midi);
  for (let i = 0; i < length; i++) {
    const t = i / sampleRate;
    const attack = 1 - Math.exp(-t / 0.025);
    const decay = Math.exp(-t / 1.15);
    const release = smoothstep(Math.min(1, (length - i) / (sampleRate * 0.3)));
    const wave = Math.sin(2 * Math.PI * frequency * t)
      + Math.sin(2 * Math.PI * frequency * 2.002 * t + 0.3) * 0.24
      + Math.sin(2 * Math.PI * frequency * 3.99 * t + 0.6) * 0.10;
    samples[start + i] += wave * attack * decay * release * gain;
  }
}

function makeMusicTrack(spec) {
  const sampleRate = 22050;
  const count = Math.floor(spec.duration * sampleRate);
  const samples = new Float32Array(count);
  const random = rng(spec.name.split("").reduce((acc, c) => acc * 31 + c.charCodeAt(0), 17));
  let smoothNoise = 0;

  for (let i = 0; i < count; i++) {
    const t = i / sampleRate;
    const bar = Math.floor(t / spec.bar) % spec.chords.length;
    const nextBar = (bar + 1) % spec.chords.length;
    const withinBar = (t % spec.bar) / spec.bar;
    const blend = withinBar > 0.86 ? smoothstep((withinBar - 0.86) / 0.14) : 0;
    const chord = spec.chords[bar];
    const nextChord = spec.chords[nextBar];
    const pad = chordVoice(chord, t) * (1 - blend) + chordVoice(nextChord, t) * blend;
    const bassFrequency = noteHz(chord[0] - 12) * (1 - blend) + noteHz(nextChord[0] - 12) * blend;
    const bass = Math.sin(2 * Math.PI * bassFrequency * t) + Math.sin(2 * Math.PI * bassFrequency * 2 * t) * 0.22;

    const noise = random() * 2 - 1;
    smoothNoise = smoothNoise * (1 - spec.noiseSmooth) + noise * spec.noiseSmooth;
    samples[i] = pad * spec.padGain + bass * spec.bassGain + smoothNoise * spec.noiseGain;
  }

  let eventTime = 0;
  let step = 0;
  while (eventTime < spec.duration - 1.2) {
    const chord = spec.chords[Math.floor(eventTime / spec.bar) % spec.chords.length];
    const chordPool = [chord[0] + 24, chord[1] + 24, chord[2] + 24, chord[0] + 36];
    const midi = spec.notes ? spec.notes[step % spec.notes.length] : chordPool[step % chordPool.length];
    addBell(samples, sampleRate, eventTime, midi, 3.6, spec.bellGain);
    eventTime += spec.noteEvery;
    step += 1;
  }

  let peak = 0;
  for (let i = 0; i < count; i++) peak = Math.max(peak, Math.abs(samples[i]));
  const scale = peak > 0 ? 0.36 / peak : 1;
  const fade = Math.floor(sampleRate * 1.8);
  for (let i = 0; i < count; i++) {
    const inFade = smoothstep(i / fade);
    const outFade = smoothstep((count - 1 - i) / fade);
    samples[i] *= scale * Math.min(inFade, outFade);
  }

  writeWav(path.join(audioDir, `${spec.name}.wav`), samples, sampleRate);
}

makeIcon();

const assetContents = { info: { author: "xcode", version: 1 } };
fs.writeFileSync(path.join(assets, "Contents.json"), JSON.stringify(assetContents, null, 2) + "\n");
fs.writeFileSync(path.join(assets, "AppIcon.appiconset", "Contents.json"), JSON.stringify({
  images: [{ filename: "AppIcon-1024.png", idiom: "universal", platform: "ios", size: "1024x1024" }],
  info: { author: "xcode", version: 1 }
}, null, 2) + "\n");

function colorSet(light, dark, name) {
  const contents = {
    colors: [
      { color: { "color-space": "srgb", components: { alpha: "1.000", blue: light[2], green: light[1], red: light[0] } }, idiom: "universal" },
      { appearances: [{ appearance: "luminosity", value: "dark" }], color: { "color-space": "srgb", components: { alpha: "1.000", blue: dark[2], green: dark[1], red: dark[0] } }, idiom: "universal" }
    ],
    info: { author: "xcode", version: 1 }
  };
  fs.writeFileSync(path.join(assets, name, "Contents.json"), JSON.stringify(contents, null, 2) + "\n");
}
colorSet(["0.718", "0.651", "0.831"], ["0.647", "0.541", "0.776"], "AccentColor.colorset");
colorSet(["0.969", "0.957", "0.984"], ["0.075", "0.067", "0.105"], "LaunchBackground.colorset");

makeMusicTrack({
  name: "cloud_rain", duration: 40, bar: 8,
  chords: [[50,54,57,61],[47,50,54,57],[43,47,50,54],[45,50,52,55]],
  notes: [74,78,81,78,76,74,69,66,74,69,66,62],
  noteEvery: 2.8, padGain: 0.11, bassGain: 0.05, bellGain: 0.075, noiseGain: 0.0045, noiseSmooth: 0.04
});
makeMusicTrack({
  name: "moon_breath", duration: 40, bar: 10,
  chords: [[45,48,52,59],[41,45,48,52],[48,52,55,59],[43,47,50,52]],
  notes: [72,76,79,76,74,72,67,69,72,76],
  noteEvery: 3.6, padGain: 0.10, bassGain: 0.045, bellGain: 0.06, noiseGain: 0.002, noiseSmooth: 0.02
});
makeMusicTrack({
  name: "quiet_stream", duration: 40, bar: 8,
  chords: [[43,47,50,55],[40,43,47,50],[36,40,43,47],[38,45,50,52]],
  notes: [79,83,86,83,81,79,74,71,79,74],
  noteEvery: 2.4, padGain: 0.09, bassGain: 0.045, bellGain: 0.06, noiseGain: 0.005, noiseSmooth: 0.08
});
makeMusicTrack({
  name: "soft_hearth", duration: 40, bar: 8,
  chords: [[50,54,57,64],[47,50,54,57],[43,47,50,54],[45,50,52,55]],
  notes: [74,78,81,86,83,78,81,74,78,81],
  noteEvery: 3.1, padGain: 0.105, bassGain: 0.05, bellGain: 0.07, noiseGain: 0.0025, noiseSmooth: 0.02
});
