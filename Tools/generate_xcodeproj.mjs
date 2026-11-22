import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";

const root = path.resolve(process.cwd());
const projectName = "MellowMind";
const projectDir = path.join(root, `${projectName}.xcodeproj`);
fs.mkdirSync(path.join(projectDir, "xcshareddata", "xcschemes"), { recursive: true });
fs.mkdirSync(path.join(projectDir, "project.xcworkspace"), { recursive: true });

function objectId(key) {
  return crypto.createHash("sha1").update(key).digest("hex").slice(0, 24).toUpperCase();
}

function walk(dir) {
  const result = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) result.push(...walk(full));
    else result.push(full);
  }
  return result;
}

const swiftFiles = walk(path.join(root, "MellowMind"))
  .filter((file) => file.endsWith(".swift"))
  .map((file) => path.relative(path.join(root, "MellowMind"), file).split(path.sep).join("/"))
  .sort();

const resourcePaths = [
  "Resources/Assets.xcassets",
  "Resources/Audio/cloud_rain.wav",
  "Resources/Audio/moon_breath.wav",
  "Resources/Audio/quiet_stream.wav",
  "Resources/Audio/soft_hearth.wav",
  "PrivacyInfo.xcprivacy"
];

const groups = new Map();
const fileRefs = new Map();
const buildFiles = [];
const sourceBuildIds = [];
const resourceBuildIds = [];

function addGroup(key, name, groupPath, parentKey) {
  const id = objectId(`group:${key}`);
  groups.set(key, { id, name, path: groupPath, children: [] });
  if (parentKey) groups.get(parentKey).children.push({ kind: "group", key });
  return id;
}

function addFile(key, parentKey, filePath, fileType) {
  const id = objectId(`file:${key}`);
  const buildId = objectId(`build:${key}`);
  const name = path.posix.basename(filePath);
  fileRefs.set(key, { id, name, path: name, fileType });
  groups.get(parentKey).children.push({ kind: "file", key });
  return { id, buildId };
}

const rootGroup = addGroup("root", null, null, null);
const appGroup = addGroup("app", projectName, projectName, "root");
const productsGroup = addGroup("products", "Products", null, "root");
const resourcesGroup = addGroup("resources", "Resources", "Resources", "app");
const configurationGroup = addGroup("configuration", "Configuration", "Configuration", "app");
const audioGroup = addGroup("audio", "Audio", "Audio", "resources");

for (const rel of swiftFiles) {
  const segments = rel.split("/");
  const fileName = segments.pop();
  let parent = "app";
  let groupKey = "";
  for (const segment of segments) {
    groupKey += `/${segment}`;
    if (!groups.has(groupKey)) addGroup(groupKey, segment, segment, parent);
    parent = groupKey;
  }
  const ref = addFile(rel, parent, fileName, "sourcecode.swift");
  sourceBuildIds.push(ref.buildId);
  buildFiles.push({ id: ref.buildId, fileId: ref.id, comment: `${fileName} in Sources` });
}

const infoRef = addFile("Info.plist", "app", "Info.plist", "text.plist.xml");
const storeKitRef = addFile("Configuration/Products.storekit", "configuration", "Products.storekit", "text.json");
const privacyRef = addFile("PrivacyInfo.xcprivacy", "app", "PrivacyInfo.xcprivacy", "text.xml");
resourceBuildIds.push(privacyRef.buildId);
buildFiles.push({ id: privacyRef.buildId, fileId: privacyRef.id, comment: "PrivacyInfo.xcprivacy in Resources" });

const assetsRef = addFile("Resources/Assets.xcassets", "resources", "Assets.xcassets", "folder.assetcatalog");
resourceBuildIds.push(assetsRef.buildId);
buildFiles.push({ id: assetsRef.buildId, fileId: assetsRef.id, comment: "Assets.xcassets in Resources" });

for (const audioName of ["cloud_rain.wav", "moon_breath.wav", "quiet_stream.wav", "soft_hearth.wav"]) {
  const key = `Resources/Audio/${audioName}`;
  const ref = addFile(key, "audio", audioName, "audio.wav");
  resourceBuildIds.push(ref.buildId);
  buildFiles.push({ id: ref.buildId, fileId: ref.id, comment: `${audioName} in Resources` });
}

const productId = objectId("product:app");
groups.get("products").children.push({ kind: "product" });
const targetId = objectId("target:app");
const projectId = objectId("project:app");
const sourcesPhaseId = objectId("phase:sources");
const frameworksPhaseId = objectId("phase:frameworks");
const resourcesPhaseId = objectId("phase:resources");
const projectConfigListId = objectId("configlist:project");
const targetConfigListId = objectId("configlist:target");
const projectDebugId = objectId("config:project:debug");
const projectReleaseId = objectId("config:project:release");
const targetDebugId = objectId("config:target:debug");
const targetReleaseId = objectId("config:target:release");

function quote(value) {
  return `"${value}"`;
}

function renderGroup(key) {
  const group = groups.get(key);
  const lines = [];
  lines.push(`\t\t${group.id} /* ${group.name ?? "Main Group"} */ = {`);
  lines.push("\t\t\tisa = PBXGroup;");
  lines.push("\t\t\tchildren = (");
  for (const child of group.children) {
    if (child.kind === "group") {
      const childGroup = groups.get(child.key);
      lines.push(`\t\t\t\t${childGroup.id} /* ${childGroup.name ?? "Group"} */,`);
    } else if (child.kind === "product") {
      lines.push(`\t\t\t\t${productId} /* ${projectName}.app */,`);
    } else {
      const ref = fileRefs.get(child.key);
      lines.push(`\t\t\t\t${ref.id} /* ${ref.name} */,`);
    }
  }
  lines.push("\t\t\t);");
  if (group.name) lines.push(`\t\t\tname = ${quote(group.name)};`);
  if (group.path) lines.push(`\t\t\tpath = ${quote(group.path)};`);
  lines.push('\t\t\tsourceTree = "<group>";');
  lines.push("\t\t};");
  return lines.join("\n");
}

const groupsSection = [...groups.keys()].map(renderGroup).join("\n");

const fileRefLines = [];
for (const ref of fileRefs.values()) {
  fileRefLines.push(`\t\t${ref.id} /* ${ref.name} */ = {isa = PBXFileReference; lastKnownFileType = ${ref.fileType}; path = ${quote(ref.path)}; sourceTree = "<group>"; };`);
}
fileRefLines.push(`\t\t${productId} /* ${projectName}.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ${projectName}.app; sourceTree = BUILT_PRODUCTS_DIR; };`);

const buildFileLines = buildFiles.map((bf) => `\t\t${bf.id} /* ${bf.comment} */ = {isa = PBXBuildFile; fileRef = ${bf.fileId} /* ${bf.comment.replace(" in Sources", "").replace(" in Resources", "")} */; };`);

const pbx = `// !$*UTF8*$!
{
\tarchiveVersion = 1;
\tclasses = {
\t};
\tobjectVersion = 56;
\tobjects = {

/* Begin PBXBuildFile section */
${buildFileLines.join("\n")}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
${fileRefLines.join("\n")}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t${frameworksPhaseId} /* Frameworks */ = {
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
${groupsSection}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t${targetId} /* ${projectName} */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = ${targetConfigListId} /* Build configuration list for PBXNativeTarget "${projectName}" */;
\t\t\tbuildPhases = (
\t\t\t\t${sourcesPhaseId} /* Sources */,
\t\t\t\t${frameworksPhaseId} /* Frameworks */,
\t\t\t\t${resourcesPhaseId} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = ${projectName};
\t\t\tproductName = ${projectName};
\t\t\tproductReference = ${productId} /* ${projectName}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t${projectId} /* Project object */ = {
\t\t\tisa = PBXProject;
\t\t\tattributes = {
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1500;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tTargetAttributes = {
\t\t\t\t\t${targetId} = {
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;
\t\t\t\t\t};
\t\t\t\t};
\t\t\t};
\t\t\tbuildConfigurationList = ${projectConfigListId} /* Build configuration list for PBXProject "${projectName}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = ${rootGroup};
\t\t\tproductRefGroup = ${groups.get("products").id} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t${targetId} /* ${projectName} */,
\t\t\t);
\t\t};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t${resourcesPhaseId} /* Resources */ = {
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
${resourceBuildIds.map((id) => `\t\t\t\t${id},`).join("\n")}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t${sourcesPhaseId} /* Sources */ = {
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
${sourceBuildIds.map((id) => `\t\t\t\t${id},`).join("\n")}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t${projectDebugId} /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\t${projectReleaseId} /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t};
\t\t\tname = Release;
\t\t};
\t\t${targetDebugId} /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = "MellowMind/Info.plist";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mellowmind.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSUPPORTS_MACCATALYST = NO;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_STRICT_CONCURRENCY = minimal;
\t\t\t\tSWIFT_VERSION = 5.9;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\t${targetReleaseId} /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = "";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = "MellowMind/Info.plist";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mellowmind.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
\t\t\t\tSUPPORTS_MACCATALYST = NO;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_STRICT_CONCURRENCY = minimal;
\t\t\t\tSWIFT_VERSION = 5.9;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t};
\t\t\tname = Release;
\t\t};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t${projectConfigListId} /* Build configuration list for PBXProject "${projectName}" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t${projectDebugId} /* Debug */,
\t\t\t\t${projectReleaseId} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t};
\t\t${targetConfigListId} /* Build configuration list for PBXNativeTarget "${projectName}" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t${targetDebugId} /* Debug */,
\t\t\t\t${targetReleaseId} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t};
/* End XCConfigurationList section */
\t};
\trootObject = ${projectId} /* Project object */;
}
`;

fs.writeFileSync(path.join(projectDir, "project.pbxproj"), pbx, "utf8");

const workspace = `<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
`;
fs.writeFileSync(path.join(projectDir, "project.xcworkspace", "contents.xcworkspacedata"), workspace, "utf8");

const scheme = `<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "${targetId}"
               BuildableName = "${projectName}.app"
               BlueprintName = "${projectName}"
               ReferencedContainer = "container:${projectName}.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <StoreKitConfigurationFileReference
         identifier = "../MellowMind/Configuration/Products.storekit">
      </StoreKitConfigurationFileReference>
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "${targetId}"
            BuildableName = "${projectName}.app"
            BlueprintName = "${projectName}"
            ReferencedContainer = "container:${projectName}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "${targetId}"
            BuildableName = "${projectName}.app"
            BlueprintName = "${projectName}"
            ReferencedContainer = "container:${projectName}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
`;
fs.writeFileSync(path.join(projectDir, "xcshareddata", "xcschemes", `${projectName}.xcscheme`), scheme, "utf8");

console.log(`Generated ${projectName}.xcodeproj with ${swiftFiles.length} Swift files and ${resourceBuildIds.length} resources.`);