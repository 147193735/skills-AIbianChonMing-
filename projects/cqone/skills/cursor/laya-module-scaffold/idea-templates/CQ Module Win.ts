import Win from "../../fn/view/Win";

#parse("CQ File Header.ts")
export default class ${NAME} extends Win {

    constructor() {
        super("${NAME.replaceAll("Win$", "")}", "${NAME}");
    }

    initUi(): void {
        super.initUi();
    }

    onAddedToStage(): void {
        super.onAddedToStage();
    }

    initData(): void {
        super.initData();
    }

}
