import Win from "../../fn/view/Win";
import WinShowStrategy from "../../fn/data/WinShowStrategy";

#parse("CQ File Header.ts")
export default class ${NAME} extends Win {

    constructor() {
        super("${NAME.replaceAll("Pop$", "")}", "${NAME}", WinShowStrategy.POP);
    }

    initUi(): void {

    }

    initData(): void {

    }

}
