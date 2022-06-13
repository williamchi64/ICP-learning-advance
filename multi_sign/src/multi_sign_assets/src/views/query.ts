import { ActorSubclass } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { html, render } from "lit-html";
import { renderIndex } from ".";
import { CanisterOutput, _SERVICE } from "../../../declarations/multi_sign/multi_sign.did";
import md from "../func/modifyDom";
import f from "../func/func";
import c from "../func/constant";
import { renderCanisterSubData } from "./query/canisterSubData";
import { renderPublicProposalSubData } from "./query/publicProposalSubData";
import { renderPublicResolutionSubData } from "./query/publicResolutionSubData";
import { init } from "..";

const content = () => html
	`<div class="container">
		<style>
			.text-center {
				text-align: center;
			}
			#whoami {
				border: 1px solid #1a1a1a;
				margin-bottom: 1rem;
			}
			table {
				width: 100%;
				text-align: center;
			}
		</style>
		<h1 class="text-center">Internet Identity Client</h1>
		<h2 class="text-center">You are authenticated!</h2>
		<p>Your identity:</p>
		<input type="text" readonly id="whoami" placeholder="your Identity" />

		<button type="button" id="btnGetCycles" class="primary">Get Cycles</button>
		<div id="blkCycles"></div>

		<button type="button" id="btnGetControllers" class="primary">Get Controllers</button>
		<div id="blkControllers"></div>

		<button type="button" id="btnGetCanisters" class="primary">Get Canisters</button>
		<div id="blkCanisters"></div>
		<div id="blkCanisterSubData"></div>

		<button type="button" id="btnGetPublicProposals" class="primary">Get Public Proposals</button>
		<div id="blkPublicProposals"></div>
		<div id="blkPublicProposalSubData"></div>

		<button type="button" id="btnGetPublicResolutions" class="primary">Get Public Resolutions</button>
		<div id="blkPublicResolutions"></div>
		<div id="blkPublicResolutionSubData"></div>

		<button id="logout">log out</button>
	</div>`;

export const renderQuery = async (
	actor: ActorSubclass<_SERVICE>,
	authClient: AuthClient
) => {

	render(content(), document.getElementById("pageContentQuery") as HTMLElement);

	const response = await f.try_catch(actor.whoami);
	console.log(response);
	(document.getElementById("whoami") as HTMLInputElement).value = response.toString();

	(document.getElementById("btnGetCycles") as HTMLButtonElement)
		.onclick = async () => {
			const response = await f.try_catch(actor.get_cycles);
			console.log(response);
			(document.getElementById("blkCycles") as HTMLDivElement).innerText = "";
			(document.getElementById("blkCycles") as HTMLDivElement).innerText = response.toString();
		};

	(document.getElementById("btnGetControllers") as HTMLButtonElement)
		.onclick = async () => {
			const response = await f.try_catch(actor.get_controllers);
			console.log(response);
			(document.getElementById("blkControllers") as HTMLDivElement).innerHTML = "";
			(document.getElementById("blkControllers") as HTMLDivElement).appendChild(
				(response.length !== 0) ? md.toList(response) : md.strToSpan("There is no controller.")
			);
		};

	(document.getElementById("btnGetCanisters") as HTMLButtonElement)
		.onclick = async () => {
			const response : Array<CanisterOutput> = await f.try_catch(actor.get_canisters);
			console.log(response);
			let flag = response.length !== 0;
			(document.getElementById("blkCanisters") as HTMLDivElement).innerHTML = "";
			(document.getElementById("blkCanisters") as HTMLDivElement).appendChild(
				(flag) ? md.arrToTable(md.toTableHeadRow(c.CANISTER_COLUMNS) ,response, md.canisterToTableRow, c.BTN_CANISTER, [""]) 
					: md.strToSpan("There is no canister under control.")
			);
			if (flag) renderCanisterSubData(response);
		};

	(document.getElementById("btnGetPublicProposals") as HTMLButtonElement)
		.onclick = async () => {
			const response = await f.try_catch(actor.get_public_proposals);
			console.log(response);
			let flag = response.length !== 0;
			(document.getElementById("blkPublicProposals") as HTMLDivElement).innerHTML = "";
			(document.getElementById("blkPublicProposals") as HTMLDivElement).appendChild(
				(flag) ? md.arrToTable(
					md.toTableHeadRow(c.PROPOSAL_COLUMNS), response, md.proposalToTableRow, c.BTN_PROPOSAL, c.PUBLIC_PROPOSAL_TYPE_BRANCH
				) : md.strToSpan("There is no public proposal.")
			);
			if (flag) renderPublicProposalSubData(response);
		};

	(document.getElementById("btnGetPublicResolutions") as HTMLButtonElement)
		.onclick = async () => {
			const response = await f.try_catch(actor.get_public_resolutions);
			console.log(response);
			let flag = response.length !== 0;
			(document.getElementById("blkPublicResolutions") as HTMLDivElement).innerHTML = "";
			(document.getElementById("blkPublicResolutions") as HTMLDivElement).appendChild(
				(flag) ? md.arrToTable(
					md.toTableHeadRow(c.PROPOSAL_COLUMNS), response, md.proposalToTableRow, c.BTN_RESOLUTION, c.PUBLIC_PROPOSAL_TYPE_BRANCH
				) : md.strToSpan("There is no public resolution.")
			);
			if (flag) renderPublicResolutionSubData(response);
		};

	(document.getElementById("logout") as HTMLButtonElement).onclick =
		async () => {
			await authClient.logout();
			const pageContentQuery = document.getElementById("pageContentQuery") as HTMLElement;
			const pageContentUpdate = document.getElementById("pageContentUpdate") as HTMLElement;
			pageContentQuery.remove();
			pageContentUpdate.remove();
			const pageContent = document.createElement("main");
			document.getElementsByTagName("body")[0].append(pageContent);
			pageContent.id = "pageContent";
			init();
		};

};
