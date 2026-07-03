#!/usr/bin/env node
/**
 * cqone / Laya 业务模块脚手架
 *
 * 用法:
 *   node scripts/scaffold-module.js <moduleName> --biz|--acts [mode] [options]
 *
 * 选项:
 *   --project <path>   目标项目根目录（默认 cwd）
 *   --lite|--standard|--full
 *   --dry-run          预览
 *   --force            覆盖已存在文件
 */

const fs = require("fs");
const path = require("path");

const MARKERS = {
    modulesImport: "// @scaffold:modules-import",
    modulesData: "// @scaffold:modules-data",
    fnsImport: "// @scaffold:fns-import",
    fnsReg: "// @scaffold:fns-reg",
};

function usage() {
    console.log(`用法: node scripts/scaffold-module.js <moduleName> --biz|--acts [mode] [options]

模式 (默认 standard):
  --lite       仅生成 data/view 骨架
  --standard   + 自动补 Modules.ts / Fns.ts（FnId 占位）
  --full       + Pop / Mo + 手动清单

选项:
  --project <path>  目标项目根（含 src/script）
  --dry-run         预览
  --force           覆盖已存在模块文件
`);
}

function parseArgs(argv) {
    const positional = [];
    let scope = null;
    let mode = "standard";
    let dryRun = false;
    let force = false;
    let projectRoot = process.cwd();

    for (let i = 0; i < argv.length; i++) {
        const arg = argv[i];
        if (arg === "--biz") scope = "biz";
        else if (arg === "--acts") scope = "acts";
        else if (arg === "--lite") mode = "lite";
        else if (arg === "--standard") mode = "standard";
        else if (arg === "--full") mode = "full";
        else if (arg === "--dry-run") dryRun = true;
        else if (arg === "--force") force = true;
        else if (arg === "--project") {
            projectRoot = path.resolve(argv[++i] || "");
            if (!projectRoot) {
                console.error("--project 需要路径");
                process.exit(1);
            }
        } else if (arg.startsWith("-")) {
            console.error(`未知参数: ${arg}`);
            usage();
            process.exit(1);
        } else positional.push(arg);
    }

    if (positional.length !== 1 || !scope) {
        usage();
        process.exit(1);
    }

    return { moduleName: positional[0], scope, mode, dryRun, force, projectRoot };
}

function toPascalCase(name) {
    return name
        .replace(/[-_\s]+(.)?/g, (_, c) => (c ? c.toUpperCase() : ""))
        .replace(/^(.)/, (c) => c.toUpperCase());
}

function buildNames(moduleName, scope) {
    const folder = moduleName.replace(/\\/g, "/").split("/").pop();
    let pascal = toPascalCase(folder);
    if (scope === "acts" && !pascal.startsWith("Act")) {
        pascal = "Act" + pascal;
    }
    return {
        folder,
        pascal,
        dataClass: `${pascal}Data`,
        eventClass: `${pascal}Event`,
        constClass: `${pascal}Const`,
        winClass: `${pascal}Win`,
        popClass: `${pascal}Pop`,
        moClass: `${pascal}Mo`,
        fguiPkg: pascal,
    };
}

function relImport(fromFile, targetFile) {
    const fromDir = path.dirname(fromFile);
    let rel = path.relative(fromDir, targetFile).replace(/\\/g, "/");
    if (!rel.startsWith(".")) rel = "./" + rel;
    return rel.replace(/\.ts$/, "");
}

function today() {
    const d = new Date();
    const pad = (n) => String(n).padStart(2, "0");
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

function ensureDir(dir, dryRun) {
    if (dryRun) return;
    fs.mkdirSync(dir, { recursive: true });
}

function writeFile(filePath, content, { dryRun, force }) {
    if (fs.existsSync(filePath) && !force) {
        console.log(`  跳过(已存在): ${filePath}`);
        return false;
    }
    console.log(`  创建: ${filePath}`);
    if (!dryRun) fs.writeFileSync(filePath, content, "utf8");
    return true;
}

function dataTemplate(names, desc) {
    return `import ModuleData from "../../../core/module/ModuleData";

/**
 * ${desc}
 * @author zhangyongkang
 * @since ${today()}
 */
export default class ${names.dataClass} extends ModuleData {

    static readonly I = new ${names.dataClass}();

    init(): void {

    }

}
`;
}

function eventTemplate(names, desc) {
    return `/**
 * ${desc}
 * @author zhangyongkang
 * @since ${today()}
 */
export default class ${names.eventClass} {

    static readonly CHANGE = "CHANGE";

}
`;
}

function constTemplate(names, desc) {
    return `/**
 * ${desc}
 * @author zhangyongkang
 * @since ${today()}
 */
export default class ${names.constClass} {

}
`;
}

function winTemplate(names, desc, scope, srcRoot) {
    const viewFile = path.join(srcRoot, scope, names.folder, "view", `${names.winClass}.ts`);
    const dataImport = relImport(viewFile, path.join(srcRoot, scope, names.folder, "data", `${names.dataClass}.ts`));
    const eventImport = relImport(viewFile, path.join(srcRoot, scope, names.folder, "data", `${names.eventClass}.ts`));
    const baseWin = scope === "acts"
        ? `import ActWin from "../../../biz/act/view/ActWin";`
        : `import Win from "../../fn/view/Win";`;
    const extendsWin = scope === "acts" ? "ActWin" : "Win";
    const superCall = scope === "acts"
        ? `        super("${names.fguiPkg}", "${names.winClass}");\n        // TODO: 设置 actFnId`
        : `        super("${names.fguiPkg}", "${names.winClass}");`;

    return `${baseWin}
import ${names.dataClass} from "${dataImport}";
import ${names.eventClass} from "${eventImport}";

/**
 * ${desc}
 * @author zhangyongkang
 * @since ${today()}
 */
export default class ${names.winClass} extends ${extendsWin} {

    constructor() {
${superCall}
    }

    initUi(): void {
        super.initUi();
    }

    onAddedToStage(): void {
        super.onAddedToStage();
        this.listenMgr.on(${names.dataClass}.I, ${names.eventClass}.CHANGE, this, this.onDataChange);
    }

    initData(): void {
        super.initData();
    }

    private onDataChange(): void {

    }

}
`;
}

function popTemplate(names, desc, scope, srcRoot) {
    const viewFile = path.join(srcRoot, scope, names.folder, "view", `${names.popClass}.ts`);
    const dataImport = relImport(viewFile, path.join(srcRoot, scope, names.folder, "data", `${names.dataClass}.ts`));

    return `import Win from "../../fn/view/Win";
import WinShowStrategy from "../../fn/data/WinShowStrategy";
import ${names.dataClass} from "${dataImport}";

/**
 * ${desc}
 * @author zhangyongkang
 * @since ${today()}
 */
export default class ${names.popClass} extends Win {

    constructor() {
        super("${names.fguiPkg}", "${names.popClass}", WinShowStrategy.POP);
    }

    initUi(): void {

    }

    initData(): void {

    }

}
`;
}

function moTemplate(names, desc) {
    return `/**
 * ${desc}
 * @author zhangyongkang
 * @since ${today()}
 */
export default class ${names.moClass} {

}
`;
}

function insertBeforeMarker(content, marker, insertion) {
    const line = insertion.trimEnd() + "\n";
    if (content.includes(line.trim())) {
        return { content, changed: false };
    }
    const idx = content.indexOf(marker);
    if (idx === -1) {
        throw new Error(`未找到标记: ${marker}`);
    }
    return { content: content.slice(0, idx) + line + content.slice(idx), changed: true };
}

function ensureScaffoldMarkers(modules, fns) {
    let changed = false;

    if (!modules.includes(MARKERS.modulesImport)) {
        const next = modules.replace(
            /(import ActTreasureVaultData[^\n]+\n)(\s*\n\/\*\*)/,
            `$1${MARKERS.modulesImport}\n$2`
        );
        if (next !== modules) {
            modules = next;
            changed = true;
        } else {
            const fallback = modules.replace(
                /(\n)(\/\*\*\n \* 业务模块注册)/,
                `\n${MARKERS.modulesImport}\n$2`
            );
            if (fallback !== modules) {
                modules = fallback;
                changed = true;
            }
        }
    }
    if (!modules.includes(MARKERS.modulesData)) {
        const next = modules.replace(
            /(ActTreasureVaultData\.I,\r?\n)(            \/\/ 这个保持在最后初始化)/,
            `$1            ${MARKERS.modulesData}\r\n$2`
        );
        if (next !== modules) {
            modules = next;
            changed = true;
        }
    }
    if (!fns.includes(MARKERS.fnsImport)) {
        const next = fns.replace(
            /(import DemonTowerRefineWin[^\n]+\n)(\s*\n\/\*\*)/,
            `$1${MARKERS.fnsImport}\n$2`
        );
        if (next !== fns) {
            fns = next;
            changed = true;
        } else {
            const fallback = fns.replace(
                /(\n)(\/\*\*\n \* 功能注册)/,
                `\n${MARKERS.fnsImport}\n$2`
            );
            if (fallback !== fns) {
                fns = fallback;
                changed = true;
            }
        }
    }
    if (!fns.includes(MARKERS.fnsReg)) {
        const next = fns.replace(
            /(FnMo\.reg\(FnId\.ACT_TREASURE_VAULT, ActTreasureVaultWin\);\r?\n)(\r?\n    \})/,
            `$1        ${MARKERS.fnsReg}\r\n$2`
        );
        if (next !== fns) {
            fns = next;
            changed = true;
        }
    }

    return { modules, fns, changed };
}

function patchConf(names, scope, confView, { dryRun }) {
    const modulesPath = path.join(confView, "Modules.ts");
    const fnsPath = path.join(confView, "Fns.ts");

    let modules = fs.readFileSync(modulesPath, "utf8");
    let fns = fs.readFileSync(fnsPath, "utf8");

    const ensured = ensureScaffoldMarkers(modules, fns);
    modules = ensured.modules;
    fns = ensured.fns;
    if (ensured.changed) {
        console.log("  写入 scaffold 标记到 conf/view");
        if (!dryRun) {
            fs.writeFileSync(modulesPath, modules, "utf8");
            fs.writeFileSync(fnsPath, fns, "utf8");
        }
    }

    const importPath = `../../${scope}/${names.folder}/data/${names.dataClass}`;
    const winImportPath = `../../${scope}/${names.folder}/view/${names.winClass}`;

    const r1 = insertBeforeMarker(modules, MARKERS.modulesImport, `import ${names.dataClass} from "${importPath}";\n`);
    const r2 = insertBeforeMarker(r1.content, MARKERS.modulesData, `            ${names.dataClass}.I,\n`);
    if (r1.changed || r2.changed) {
        console.log(`  更新: ${modulesPath}`);
        if (!dryRun) fs.writeFileSync(modulesPath, r2.content, "utf8");
    } else {
        console.log(`  跳过(Modules 已注册): ${names.dataClass}`);
    }

    const r3 = insertBeforeMarker(fns, MARKERS.fnsImport, `import ${names.winClass} from "${winImportPath}";\n`);
    const r4 = insertBeforeMarker(r3.content, MARKERS.fnsReg, `        FnMo.reg(FnId.TODO, ${names.winClass}); // TODO: FnId\n`);
    if (r3.changed || r4.changed) {
        console.log(`  更新: ${fnsPath}`);
        if (!dryRun) fs.writeFileSync(fnsPath, r4.content, "utf8");
    } else {
        console.log(`  跳过(Fns 已注册): ${names.winClass}`);
    }
}

function writeChecklist(moduleDir, names) {
    return `# ${names.pascal} 模块 — 手动注册清单
# 生成时间: ${today()}
# Protos / RedDots 不自动改 conf，请手工完成。

## 1. FnId
# 在 src/script/conf/data/FnId.ts 增加枚举值
# 将 Fns.ts 中 FnId.TODO 替换为实际 FnId

## 2. Protos.ts
# import { SC???Po } from "../../proto/netProto";
# NetMsgHandler.reg(SC???.cmd, ${names.dataClass}.I, ${names.dataClass}.I.onSC???);

## 3. RedDots.ts（可选）
# static readonly ${names.pascal.toUpperCase()} = RedDotMo.createChildOfFn(FnId.TODO);

## 4. Wins.ts（非 Fn 弹窗）
# WinMo.reg(WinId.TODO, ${names.popClass});

## 5. BasicViews.ts（FGUI 自定义类）
# fgui.UIObjectFactory.setExtension(...)

## 6. IDEA 格式化
# 选中模块目录 → Ctrl+Alt+L（scheme: tuoqi）
`;
}

function main() {
    const args = parseArgs(process.argv.slice(2));
    const srcRoot = path.join(args.projectRoot, "src", "script");
    if (!fs.existsSync(srcRoot)) {
        console.error(`未找到 src/script: ${srcRoot}`);
        process.exit(1);
    }

    const names = buildNames(args.moduleName, args.scope);
    const moduleDir = path.join(srcRoot, args.scope, names.folder);
    const dataDir = path.join(moduleDir, "data");
    const viewDir = path.join(moduleDir, "view");
    const desc = `${names.pascal}模块`;
    const opts = { dryRun: args.dryRun, force: args.force };

    console.log(`\n脚手架: ${args.scope}/${names.folder} (${args.mode})`);
    console.log(`项目: ${args.projectRoot}${args.dryRun ? " [dry-run]" : ""}\n`);

    ensureDir(dataDir, args.dryRun);
    ensureDir(viewDir, args.dryRun);

    writeFile(path.join(dataDir, `${names.dataClass}.ts`), dataTemplate(names, desc), opts);
    writeFile(path.join(dataDir, `${names.eventClass}.ts`), eventTemplate(names, desc), opts);
    writeFile(path.join(dataDir, `${names.constClass}.ts`), constTemplate(names, desc), opts);
    writeFile(path.join(viewDir, `${names.winClass}.ts`), winTemplate(names, desc, args.scope, srcRoot), opts);

    if (args.mode === "full") {
        writeFile(path.join(viewDir, `${names.popClass}.ts`), popTemplate(names, `${names.pascal}弹窗`, args.scope, srcRoot), opts);
        writeFile(path.join(dataDir, `${names.moClass}.ts`), moTemplate(names, `${names.pascal}模型`), opts);
        writeFile(path.join(moduleDir, `${names.folder}.scaffold-checklist.txt`), writeChecklist(moduleDir, names), { ...opts, force: true });
    }

    if (args.mode === "standard" || args.mode === "full") {
        patchConf(names, args.scope, path.join(srcRoot, "conf", "view"), args);
    }

    console.log("\n完成。请在 IDEA 中对新建文件 Ctrl+Alt+L 格式化。\n");
}

try {
    main();
} catch (err) {
    console.error("错误:", err.message);
    process.exit(1);
}
