import { html, render } from "lit-html";
import { ProposalOutput_1, _SERVICE } from "../../../../../declarations/multi_sign/multi_sign.did";
import c from "../../../func/constant";
import md from "../../../func/modifyDom";

const content = () => html`<div id="canisterResolutionSubData"></div>`;

export const renderCanisterResolutionSubData = async (
    resolutions : Array<ProposalOutput_1>
) => {

    render(content(), document.getElementById("blkCanisterResolutionSubData") as HTMLDivElement);

    resolutions.forEach((resolution, index, array) => {
        let btn_canister_resolution_type = c.BTN_CANISTER_RESOLUTION.proposal_type + index;
        if (document.getElementById(btn_canister_resolution_type) !== null)
            (document.getElementById(btn_canister_resolution_type) as HTMLButtonElement)
                .onclick = () => {
                    let param = ("start" in resolution.proposal_type) ? md.strToSpan("start")
                        : ("install" in resolution.proposal_type) ? md.installParamToTable(resolution.proposal_type.install)
                        : ("stop" in resolution.proposal_type) ? md.strToSpan("stop")
                        : ("delete" in resolution.proposal_type) ? md.strToSpan("delete")
                        : md.appendToNewNode("td", md.strToSpan("no branch"));
                    (document.getElementById("canisterResolutionSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("canisterResolutionSubData") as HTMLDivElement).appendChild(param);
                };

        let btn_canister_resolution_agree_voters = c.BTN_CANISTER_RESOLUTION.agree_voters + index;
        if (document.getElementById(btn_canister_resolution_agree_voters) !== null)
            (document.getElementById(btn_canister_resolution_agree_voters) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("canisterResolutionSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("canisterResolutionSubData") as HTMLDivElement).appendChild(md.strToSpan("agree voter: "));
                    (document.getElementById("canisterResolutionSubData") as HTMLDivElement).appendChild(
                        md.toList(resolution.agree_voters)
                    );
                };

        let btn_canister_resolution_total_voters = c.BTN_CANISTER_RESOLUTION.total_voters + index;
        if (document.getElementById(btn_canister_resolution_total_voters) !== null)
            (document.getElementById(btn_canister_resolution_total_voters) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("canisterResolutionSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("canisterResolutionSubData") as HTMLDivElement).appendChild(md.strToSpan("total voter: "));
                    (document.getElementById("canisterResolutionSubData") as HTMLDivElement).appendChild(
                        md.toList(resolution.total_voters)
                    );
                };

    });

};