#!/usr/bin/env node
/**
 * List FGUI v* fields for a package (parity with ui-extensions「拷贝生成代码」).
 * Usage:
 *   node list-fgui-fields.js --root <cqoneRoot> --pkg <PkgName> [--com ComponentName] [--json]
 */
"use strict";

const fs = require("fs");
const path = require("path");

const DEFAULT_IGNORES = new Set(["vFrame", "vClose"]);

const TAG_TYPE = {
    image: "GImage",
    graph: "GGraph",
    list: "GList",
    loader: "GLoader",
    text: "GTextField",
    richtext: "GRichTextField",
    inputtext: "GTextInput",
    group: "GGroup",
    movieclip: "GMovieClip",
    component: "GComponent",
    loader3D: "GLoader3D",
};

const EXT_TYPE = {
    Button: "GButton",
    Label: "GLabel",
    ComboBox: "GComboBox",
    ProgressBar: "GProgressBar",
    Slider: "GSlider",
    ScrollBar: "GScrollBar",
};

function parseArgs(argv) {
    const out = { root: "", pkg: "", com: "", json: false };
    for (let i = 2; i < argv.length; i++) {
        const a = argv[i];
        if (a === "--root") out.root = argv[++i];
        else if (a === "--pkg") out.pkg = argv[++i];
        else if (a === "--com") out.com = argv[++i];
        else if (a === "--json") out.json = true;
        else if (a === "--help" || a === "-h") out.help = true;
    }
    return out;
}

function readText(p) {
    return fs.readFileSync(p, "utf8");
}

function loadBasicViewsMap(projectRoot) {
    const p = path.join(projectRoot, "src/script/conf/view/BasicViews.ts");
    const map = Object.create(null);
    if (!fs.existsSync(p)) return map;
    const content = readText(p);
    const re = /BasicViews\.setCustomClass\(\s*"([^"]+)"\s*,\s*([A-Za-z0-9_]+)\s*\)/g;
    let m;
    while ((m = re.exec(content))) {
        map[m[1]] = m[2];
    }
    return map;
}

function listComponentFiles(pkgDir, packageXml) {
    const names = [];
    const re = /<component\b[^>]*\bname="([^"]+\.xml)"/g;
    let m;
    while ((m = re.exec(packageXml))) {
        names.push(m[1]);
    }
    return names.filter((n) => fs.existsSync(path.join(pkgDir, n)));
}

function attr(tag, name) {
    const m = tag.match(new RegExp(`\\b${name}="([^"]*)"`));
    return m ? m[1] : "";
}

function baseResName(fileName) {
    if (!fileName) return "";
    const base = path.basename(fileName.replace(/\\/g, "/"));
    return base.replace(/\.xml$/i, "");
}

function resolveExtentionType(pkgDir, fileName, pkgAttr, projectRoot) {
    if (!fileName) return "";
    const candidates = [];
    if (!pkgAttr || pkgAttr === "") {
        candidates.push(path.join(pkgDir, fileName));
    }
    // Same-folder relative path as stored in XML
    candidates.push(path.join(pkgDir, fileName));
    // Search all assets packages for matching fileName basename (best-effort for cross-pkg)
    const assetsRoot = path.join(projectRoot, "fgui/assets");
    if (fs.existsSync(assetsRoot)) {
        const base = path.basename(fileName);
        for (const dir of fs.readdirSync(assetsRoot)) {
            const full = path.join(assetsRoot, dir, base);
            if (fs.existsSync(full)) candidates.push(full);
            const nested = path.join(assetsRoot, dir, fileName);
            if (fs.existsSync(nested)) candidates.push(nested);
        }
    }
    for (const c of candidates) {
        if (!fs.existsSync(c)) continue;
        const head = readText(c).slice(0, 500);
        const em = head.match(/\bextention="([^"]+)"/);
        if (em && EXT_TYPE[em[1]]) return EXT_TYPE[em[1]];
    }
    return "";
}

function resolveChildType(tagName, openTag, pkgDir, projectRoot, commonMap) {
    const fileName = attr(openTag, "fileName");
    const pkgAttr = attr(openTag, "pkg");
    const res = baseResName(fileName);
    if (res && commonMap[res]) return commonMap[res];
    const extType = resolveExtentionType(pkgDir, fileName, pkgAttr, projectRoot);
    if (extType) return extType;
    return TAG_TYPE[tagName] || "GComponent";
}

function parseComponentXml(xml, pkgDir, projectRoot, commonMap, ignores) {
    const fields = [];
    const delayArr = Object.create(null);

    // children in displayList: <tag ... name="vXxx" ...>
    const childRe = /<(image|graph|list|loader|text|richtext|inputtext|group|movieclip|component|loader3D)\b([^>]*?)(\/>|>)/g;
    let m;
    while ((m = childRe.exec(xml))) {
        const tagName = m[1];
        const openTag = m[0];
        const name = attr(openTag, "name");
        if (!name || !name.startsWith("v") || ignores.has(name)) continue;
        const typeName = resolveChildType(tagName, openTag, pkgDir, projectRoot, commonMap);
        const sepPos = name.lastIndexOf("_");
        if (sepPos >= 0 && !isNaN(parseInt(name.substring(sepPos + 1), 10))) {
            delayArr[name.substring(0, sepPos)] = typeName;
            continue;
        }
        fields.push({ name, type: typeName, kind: "child" });
    }

    for (const arrName of Object.keys(delayArr)) {
        fields.push({ name: arrName, type: delayArr[arrName] + "[]", kind: "childArr" });
    }

    const ctrlRe = /<controller\b([^>]*)\/?>/g;
    while ((m = ctrlRe.exec(xml))) {
        const name = attr(m[1], "name");
        if (!name || !name.startsWith("v") || ignores.has(name)) continue;
        fields.push({ name, type: "Controller", kind: "controller" });
    }

    const trRe = /<transition\b([^>]*)\/?>/g;
    while ((m = trRe.exec(xml))) {
        const name = attr(m[1], "name");
        if (!name || !name.startsWith("v") || ignores.has(name)) continue;
        fields.push({ name, type: "Transition", kind: "transition" });
    }

    return fields;
}

function main() {
    const args = parseArgs(process.argv);
    if (args.help || !args.root || !args.pkg) {
        console.error(
            "Usage: node list-fgui-fields.js --root <cqoneRoot> --pkg <PkgName> [--com ComponentName] [--json]"
        );
        process.exit(args.help ? 0 : 1);
    }

    const pkgDir = path.join(args.root, "fgui/assets", args.pkg);
    const packageXmlPath = path.join(pkgDir, "package.xml");
    if (!fs.existsSync(packageXmlPath)) {
        console.error("Package not found:", packageXmlPath);
        process.exit(2);
    }

    const commonMap = loadBasicViewsMap(args.root);
    const packageXml = readText(packageXmlPath);
    let comps = listComponentFiles(pkgDir, packageXml);
    if (args.com) {
        const want = args.com.endsWith(".xml") ? args.com : args.com + ".xml";
        comps = comps.filter((c) => c === want || path.basename(c) === want);
        if (!comps.length) {
            console.error("Component not in package:", args.com);
            process.exit(3);
        }
    }

    const result = {};
    for (const file of comps) {
        const xmlPath = path.join(pkgDir, file);
        const xml = readText(xmlPath);
        const comName = file.replace(/\.xml$/i, "");
        result[comName] = parseComponentXml(xml, pkgDir, args.root, commonMap, DEFAULT_IGNORES);
    }

    if (args.json) {
        console.log(JSON.stringify(result, null, 2));
        return;
    }

    for (const comName of Object.keys(result)) {
        console.log(`## ${comName}`);
        const fields = result[comName];
        if (!fields.length) {
            console.log("(no v* fields)\n");
            continue;
        }
        for (const f of fields) {
            console.log(`${f.name}: ${f.type};`);
        }
        console.log("");
    }
}

main();
