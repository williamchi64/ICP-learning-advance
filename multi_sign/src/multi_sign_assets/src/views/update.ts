import { ActorSubclass } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { html, render } from "lit-html";
import { _SERVICE } from "../../../declarations/multi_sign/multi_sign.did";
import { renderPostProposal } from "./update/postProposal";

const content = () => html
	`<div class="container">
        <div id="blkPostProposal"></div>
	</div>`;

export const renderUpdate = async (
    actor: ActorSubclass<_SERVICE>,
    authClient: AuthClient
) => {

    render(content(), document.getElementById("pageContentUpdate") as HTMLElement);

    renderPostProposal();

};