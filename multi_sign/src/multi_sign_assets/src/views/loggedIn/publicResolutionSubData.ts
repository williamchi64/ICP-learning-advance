import { html, render } from "lit-html";
import { CanisterOutput, ProposalOutput, _SERVICE } from "../../../../declarations/multi_sign/multi_sign.did";
import c from "../../func/constant";
import md from "../../func/modifyDom";

const content = () => html`<div id="publicResolutionSubData"></div>`;

export const renderPublicResolutionSubData = async (
    resolutions : Array<ProposalOutput>
) => {

    render(content(), document.getElementById("blkPublicResolutionSubData") as HTMLDivElement);

    resolutions.forEach((resolution, index, array) => {
        let btn_public_resolution_type = c.BTN_RESOLUTION.proposal_type + index;
        if (document.getElementById(btn_public_resolution_type) !== null)
            (document.getElementById(btn_public_resolution_type) as HTMLButtonElement)
                .onclick = () => {
                    let param = ("register" in resolution.proposal_type) ? "register: " + resolution.proposal_type.register.identity.toString()
                        : ("unregister" in resolution.proposal_type) ? "unregister: " + resolution.proposal_type.unregister.identity.toString()
                        : ("lock" in resolution.proposal_type) ? "lock id: " + resolution.proposal_type.lock.n.toString()
                        : ("unlock" in resolution.proposal_type) ? "unlock id: " + resolution.proposal_type.unlock.n.toString()
                        : ("create" in resolution.proposal_type) ? "create cycles: " + resolution.proposal_type.create.cycles.toString()
                        : "no branch";
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).appendChild(md.strToSpan(param));
                };

        let btn_public_resolution_agree_voters = c.BTN_RESOLUTION.agree_voters + index;
        if (document.getElementById(btn_public_resolution_agree_voters) !== null)
            (document.getElementById(btn_public_resolution_agree_voters) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).appendChild(md.strToSpan("agree voter: "));
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).appendChild(
                        md.toList(resolution.agree_voters)
                    );
                };

        let btn_public_resolution_total_voters = c.BTN_RESOLUTION.total_voters + index;
        if (document.getElementById(btn_public_resolution_total_voters) !== null)
            (document.getElementById(btn_public_resolution_total_voters) as HTMLButtonElement)
                .onclick = () => {
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).innerHTML = "";
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).appendChild(md.strToSpan("total voter: "));
                    (document.getElementById("publicResolutionSubData") as HTMLDivElement).appendChild(
                        md.toList(resolution.total_voters)
                    );
                };

    });

};