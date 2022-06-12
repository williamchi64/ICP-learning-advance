import { html, render } from "lit-html";
import { CanisterOutput, _SERVICE } from "../../../../declarations/multi_sign/multi_sign.did";
import c from "../../func/constant";
import md from "../../func/modifyDom";
import { renderCanisterProposalSubData } from "./canisterSubData/canisterProposalSubData";
import { renderCanisterResolutionSubData } from "./canisterSubData/canisterResolutionSubData";

const content = () => html
    `<div id="canisterSubData"></div>
    <div id="blkCanisterProposalSubData"></div>
    <div id="blkCanisterResolutionSubData"></div>`;

export const renderCanisterSubData = async (
    canisters : Array<CanisterOutput>
) => {

    render(content(), document.getElementById("blkCanisterSubData") as HTMLDivElement);

    canisters.forEach((canister, index, array) => {
        let btn_canister_lock = c.BTN_CANISTER.lock + index;
        if (document.getElementById(btn_canister_lock) !== null)
            (document.getElementById(btn_canister_lock) as HTMLButtonElement)
                .onclick = () => {
                    if ("lock" in canister.lock) {
                        (document.getElementById("canisterSubData") as HTMLDivElement).innerHTML = "";
                        (document.getElementById("canisterSubData") as HTMLDivElement).appendChild(
                            md.arrToTable(
                                md.toTableHeadRow(c.CANISTER_LOCK_COLUMNS), [canister.lock.lock], md.lockToTableRow, c.BTN_CANISTER, c.PERMISSION_BRANCH
                            )
                        );
                    };
                };

        let btn_canister_proposals = c.BTN_CANISTER.proposals + index;
        if (document.getElementById(btn_canister_proposals) !== null)
            (document.getElementById(btn_canister_proposals) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("canisterSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("canisterSubData") as HTMLDivElement).appendChild(
                        md.arrToTable(
                            md.toTableHeadRow(c.PROPOSAL_COLUMNS), canister.proposals, md.proposalToTableRow, c.BTN_CANISTER_PROPOSAL, c.CANISTER_PROPOSAL_TYPE_BRANCH
                        )
                    );
                    renderCanisterProposalSubData(canister.proposals);
                };

        let btn_canister_resolutions = c.BTN_CANISTER.resolutions + index;
        if (document.getElementById(btn_canister_resolutions) !== null)
            (document.getElementById(btn_canister_resolutions) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("canisterSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("canisterSubData") as HTMLDivElement).appendChild(
                        md.arrToTable(
                            md.toTableHeadRow(c.PROPOSAL_COLUMNS), canister.resolutions, md.proposalToTableRow, c.BTN_CANISTER_RESOLUTION, c.CANISTER_PROPOSAL_TYPE_BRANCH
                        )
                    );
                    renderCanisterResolutionSubData(canister.resolutions);
                };

    });

};