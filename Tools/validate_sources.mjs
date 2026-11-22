import fs from "node:fs";
import path from "node:path";

const root = path.resolve(process.cwd());
const sourceRoot = path.join(root, "MellowMind");
const failures = [];

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    return entry.isDirectory() ? walk(full) : [full];
  });
}

function stripSwift(text) {
  let output = "";
  let index = 0;
  let blockDepth = 0;
  let inLineComment = false;
  let inString = false;
  let inMultilineString = false;

  while (index < text.length) {
    const current = text[index];
    const next = text[index + 1];
    if (inLineComment) {
      if (current === "\n") {
        inLineComment = false;
        output += "\n";
      }
      index += 1;
      continue;
    }
    if (blockDepth > 0) {
      if (current === "/" && next === "*") {
        blockDepth += 1;
        index += 2;
        continue;
      }
      if (current === "*" && next === "/") {
        blockDepth -= 1;
        index += 2;
        continue;
      }
      if (current === "\n") output += "\n";
      index += 1;
      continue;
    }
    if (inMultilineString) {
      if (current === "\\") {
        index += 2;
        continue;
      }
      if (current === '"' && text.slice(index, index + 3) === '"""') {
        inMultilineString = false;
        output += "   ";
        index += 3;
        continue;
      }
      if (current === "\n") output += "\n";
      index += 1;
      continue;
    }
    if (inString) {
      if (current === "\\") {
        index += 2;
        continue;
      }
      if (current === '"') {
        inString = false;
        output += " ";
      }
      index += 1;
      continue;
    }
    if (current === "/" && next === "/") {
      inLineComment = true;
      index += 2;
      continue;
    }
    if (current === "/" && next === "*") {
      blockDepth = 1;
      index += 2;
      continue;
    }
    if (text.slice(index, index + 3) === '"""') {
      inMultilineString = true;
      output += "   ";
      index += 3;
      continue;
    }
    if (current === '"') {
      inString = true;
      output += " ";
      index += 1;
      continue;
    }
    output += current;
    index += 1;
  }
  return output;
}

const pairs = { "(": ")", "[": "]", "{": "}" };
for (const file of walk(sourceRoot).filter((file) => file.endsWith(".swift"))) {
  const cleaned = stripSwift(fs.readFileSync(file, "utf8"));
  const stack = [];
  let line = 1;
  for (const char of cleaned) {
    if (char === "\n") line += 1;
    if (Object.hasOwn(pairs, char)) stack.push({ char, line });
    if ([")", "]", "}"].includes(char)) {
      const opening = stack.pop();
      if (!opening || pairs[opening.char] !== char) {
        failures.push(`${path.relative(root, file)}:${line} mismatched ${char}`);
        break;
      }
    }
  }
  if (stack.length) {
    const opening = stack.at(-1);
    failures.push(`${path.relative(root, file)}:${opening.line} unclosed ${opening.char}`);
  }
}

const storeKit = JSON.parse(fs.readFileSync(path.join(sourceRoot, "Configuration/Products.storekit"), "utf8"));
const configured = new Set([
  ...storeKit.products.map((item) => item.productID),
  ...storeKit.subscriptionGroups.flatMap((group) => group.subscriptions.map((item) => item.productID))
]);
const expected = [
  "com.mellowmind.iap.tarot.skinpack",
  "com.mellowmind.iap.tube.skinpack",
  "com.mellowmind.iap.unlimited.wishseals",
  "com.mellowmind.iap.dailyreport.monthly"
];
for (const id of expected) {
  if (!configured.has(id)) failures.push(`StoreKit missing ${id}`);
}

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const storeKitIdentifiers = [
  storeKit.identifier,
  ...storeKit.products.map((item) => item.internalID),
  ...storeKit.subscriptionGroups.flatMap((group) => [group.id, ...group.subscriptions.map((item) => item.internalID)])
];
for (const identifier of storeKitIdentifiers) {
  if (!uuidPattern.test(identifier)) failures.push(`StoreKit identifier is not a valid UUID: ${identifier}`);
}
for (const group of storeKit.subscriptionGroups) {
  for (const subscription of group.subscriptions) {
    if (subscription.subscriptionGroupID !== group.id) failures.push(`StoreKit subscription group mismatch: ${subscription.productID}`);
  }
}

const pbx = fs.readFileSync(path.join(root, "MellowMind.xcodeproj/project.pbxproj"), "utf8");
const infoRefs = (pbx.match(/\/\* Info\.plist \*\/ = \{isa = PBXFileReference/g) ?? []).length;
if (infoRefs !== 1) failures.push(`PBX Info.plist file references: ${infoRefs}`);
if (!pbx.includes("/* Products */ = {") || !pbx.includes("MellowMind.app */,")) failures.push("PBX Products group missing app product");
if (!pbx.includes("Products.storekit")) failures.push("PBX missing StoreKit configuration reference");

const swiftFiles = walk(sourceRoot).filter((file) => file.endsWith(".swift"));
const allText = swiftFiles.map((file) => fs.readFileSync(file, "utf8")).join("\n");
for (const token of ["AppTheme.complianceFooter", "safeAreaInset(edge: .bottom", "CMMotionManager", "UIImpactFeedbackGenerator", "AES.GCM", "Transaction.updates"]) {
  if (!allText.includes(token)) failures.push(`Missing required implementation token: ${token}`);
}

for (const phrase of ["will bring you luck", "predicts your future", "predict your future", "guaranteed wealth", "soulmate is waiting", "destiny says", "fated to be", "good fortune awaits"]) {
  if (allText.toLowerCase().includes(phrase)) failures.push(`Forbidden predictive phrase: ${phrase}`);
}
const infoPlist = fs.readFileSync(path.join(sourceRoot, "Info.plist"), "utf8");
if (!infoPlist.includes("<string>en_US</string>")) failures.push("Info.plist development region is not en_US");
if (infoPlist.includes("zh_CN") || infoPlist.includes("zh-Hans")) failures.push("Info.plist still contains a Chinese localization");
const storeConfigText = fs.readFileSync(path.join(sourceRoot, "Configuration/Products.storekit"), "utf8");
if (storeConfigText.includes("zh_CN") || storeConfigText.includes("zh-Hans")) failures.push("StoreKit configuration still contains Chinese localizations");
const textExtensions = new Set([".swift", ".mjs", ".js", ".json", ".md", ".plist", ".storekit", ".html", ".css", ".txt", ".yml", ".yaml", ".xcprivacy"]);
const excluded = [`${path.sep}.git${path.sep}`, `${path.sep}node_modules${path.sep}`, `${path.sep}build${path.sep}`, `${path.sep}DerivedData${path.sep}`];
for (const filePath of walk(root)) {
  if (!textExtensions.has(path.extname(filePath).toLowerCase())) continue;
  if (excluded.some((part) => filePath.includes(part))) continue;
  const fileText = fs.readFileSync(filePath, "utf8");
  if (/[\u3400-\u9fff]/.test(fileText)) failures.push(`Chinese text remains: ${path.relative(root, filePath)}`);
}
const footerUses = (allText.match(/ComplianceFooter\(\)/g) ?? []).length;
if (footerUses < 7) failures.push(`ComplianceFooter usage count too low: ${footerUses}`);
if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}
console.log(`Validated ${swiftFiles.length} Swift files, balanced delimiters, StoreKit products, PBX references, and required interaction tokens.`);