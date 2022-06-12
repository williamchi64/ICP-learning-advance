import { html, render } from "lit-html";
import { CanisterOutput, ProposalOutput, _SERVICE } from "../../../../declarations/multi_sign/multi_sign.did";
import c from "../../func/constant";
import md from "../../func/modifyDom";

const content = () => html`<div id="blkPublicProposalSubData"></div>`;

export const renderPublicProposalSubData = async (
    proposals : Array<ProposalOutput>
) => {

    render(content(), document.getElementById("blkPublicProposalSubData") as HTMLDivElement);

    proposals.forEach((proposal, index, array) => {
        let btn_public_proposal_type = c.BTN_PROPOSAL.proposal_type + index;
        if (document.getElementById(btn_public_proposal_type) !== null)
            (document.getElementById(btn_public_proposal_type) as HTMLButtonElement)
                .onclick = () => {
                    let param = ("register" in proposal.proposal_type) ? "register: " + proposal.proposal_type.register.identity.toString()
                        : ("unregister" in proposal.proposal_type) ? "unregister: " + proposal.proposal_type.unregister.identity.toString()
                        : ("lock" in proposal.proposal_type) ? "lock id: " + proposal.proposal_type.lock.n.toString()
                        : ("unlock" in proposal.proposal_type) ? "unlock id: " + proposal.proposal_type.unlock.n.toString()
                        : ("create" in proposal.proposal_type) ? "create cycles: " + proposal.proposal_type.create.cycles.toString()
                        : "no branch";
                    (document.getElementById("blkPublicProposalSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("blkPublicProposalSubData") as HTMLDivElement).appendChild(md.strToSpan(param));
                };

        // let btn_canister_proposals = c.BTN_CANISTER.proposals + index;
        // if (document.getElementById(btn_canister_proposals) !== null)
        //     (document.getElementById(btn_canister_proposals) as HTMLButtonElement)
        //         .onclick = () => {
        //             (document.getElementById("blkPublicProposalSubData") as HTMLDivElement).innerHTML = "";
        //             (document.getElementById("blkPublicProposalSubData") as HTMLDivElement).appendChild(
        //                 md.arrToTable(
        //                     md.toTableHeadRow(c.PROPOSAL_COLUMNS), canister.proposals, md.proposalToTableRow, c.BTN_CANISTER_PROPOSAL, c.CANISTER_PROPOSAL_TYPE_BRANCH
        //                 )
        //             );
        //         };

        // let btn_canister_resolutions = c.BTN_CANISTER.resolutions + index;
        // if (document.getElementById(btn_canister_resolutions) !== null)
        //     (document.getElementById(btn_canister_resolutions) as HTMLButtonElement)
        //         .onclick = () => {
        //             (document.getElementById("blkPublicProposalSubData") as HTMLDivElement).innerHTML = "";
        //             (document.getElementById("blkPublicProposalSubData") as HTMLDivElement).appendChild(
        //                 md.arrToTable(
        //                     md.toTableHeadRow(c.PROPOSAL_COLUMNS), canister.resolutions, md.proposalToTableRow, c.BTN_CANISTER_RESOLUTION, c.CANISTER_PROPOSAL_TYPE_BRANCH
        //                 )
        //             );
        //         };

    });

};