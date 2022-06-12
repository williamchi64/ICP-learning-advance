import { html, render } from "lit-html";
import { CanisterOutput, ProposalOutput, _SERVICE } from "../../../../declarations/multi_sign/multi_sign.did";
import c from "../../func/constant";
import md from "../../func/modifyDom";

const content = () => html`<div id="publicProposalSubData"></div>`;

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
                    (document.getElementById("publicProposalSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("publicProposalSubData") as HTMLDivElement).appendChild(md.strToSpan(param));
                };

        let btn_public_proposal_agree_voters = c.BTN_PROPOSAL.agree_voters + index;
        if (document.getElementById(btn_public_proposal_agree_voters) !== null)
            (document.getElementById(btn_public_proposal_agree_voters) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("publicProposalSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).appendChild(md.strToSpan("agree voter: "));
                    (document.getElementById("publicProposalSubData") as HTMLDivElement).appendChild(
                        md.toList(proposal.agree_voters)
                    );
                };

        let btn_public_proposal_total_voters = c.BTN_PROPOSAL.total_voters + index;
        if (document.getElementById(btn_public_proposal_total_voters) !== null)
            (document.getElementById(btn_public_proposal_total_voters) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("publicProposalSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).appendChild(md.strToSpan("total voter: "));
                    (document.getElementById("publicProposalSubData") as HTMLDivElement).appendChild(
                        md.toList(proposal.total_voters)
                    );
                };

    });

};