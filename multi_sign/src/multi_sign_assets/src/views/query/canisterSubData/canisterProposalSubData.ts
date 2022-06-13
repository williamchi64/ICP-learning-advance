import { html, render } from "lit-html";
import { ProposalOutput_1, _SERVICE } from "../../../../../declarations/multi_sign/multi_sign.did";
import c from "../../../func/constant";
import md from "../../../func/modifyDom";

const content = () => html`<div id="canisterProposalSubData"></div>`;

export const renderCanisterProposalSubData = async (
    proposals : Array<ProposalOutput_1>
) => {

    render(content(), document.getElementById("blkCanisterProposalSubData") as HTMLDivElement);

    proposals.forEach((proposal, index, array) => {
        let btn_canister_proposal_type = c.BTN_CANISTER_PROPOSAL.proposal_type + index;
        if (document.getElementById(btn_canister_proposal_type) !== null)
            (document.getElementById(btn_canister_proposal_type) as HTMLButtonElement)
                .onclick = () => {
                    let param = ("start" in proposal.proposal_type) ? md.strToSpan("start")
                        : ("install" in proposal.proposal_type) ? md.installParamToTable(proposal.proposal_type.install)
                        : ("stop" in proposal.proposal_type) ? md.strToSpan("stop")
                        : ("delete" in proposal.proposal_type) ? md.strToSpan("delete")
                        : md.appendToNewNode("td", md.strToSpan("no branch"));
                    (document.getElementById("canisterProposalSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("canisterProposalSubData") as HTMLDivElement).appendChild(param);
                };

        let btn_canister_proposal_agree_voters = c.BTN_CANISTER_PROPOSAL.agree_voters + index;
        if (document.getElementById(btn_canister_proposal_agree_voters) !== null)
            (document.getElementById(btn_canister_proposal_agree_voters) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("canisterProposalSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("canisterProposalSubData") as HTMLDivElement).appendChild(md.strToSpan("agree voter: "));
                    (document.getElementById("canisterProposalSubData") as HTMLDivElement).appendChild(
                        md.toList(proposal.agree_voters)
                    );
                };

        let btn_canister_proposal_total_voters = c.BTN_CANISTER_PROPOSAL.total_voters + index;
        if (document.getElementById(btn_canister_proposal_total_voters) !== null)
            (document.getElementById(btn_canister_proposal_total_voters) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("canisterProposalSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("canisterProposalSubData") as HTMLDivElement).appendChild(md.strToSpan("total voter: "));
                    (document.getElementById("canisterProposalSubData") as HTMLDivElement).appendChild(
                        md.toList(proposal.total_voters)
                    );
                };

    });

};