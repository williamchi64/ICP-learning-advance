import { ActorSubclass } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { html, render } from "lit-html";
import { renderIndex } from ".";
import { _SERVICE, CanisterOutput, ProposalOutput } from "../../../declarations/multi_sign/multi_sign.did";

const content = () => html`<div class="container">
  <style>
    #whoami {
      border: 1px solid #1a1a1a;
      margin-bottom: 1rem;
    }
  </style>
  <h1>Internet Identity Client</h1>
  <h2>You are authenticated!</h2>
  <p>Your identity:</p>
  <input type="text" readonly id="whoami" placeholder="your Identity" />

  <button type="button" id="btnGetCycles" class="primary">Get Cycles</button>
  <div id="blkCycles"></div>

  <button type="button" id="btnGetControllers" class="primary">Get Controllers</button>
  <div id="blkControllers"></div>

  <button type="button" id="btnGetCanisters" class="primary">Get Canisters</button>
  <div id="blkCanisters"></div>

  <button type="button" id="btnGetPublicProposals" class="primary">Get Public Proposals</button>
  <div id="blkPublicProposals"></div>

  <button type="button" id="btnGetPublicResolutions" class="primary">Get Public Resolutions</button>
  <div id="blkPublicResolutions"></div>

  <button id="logout">log out</button>
</div>`;

const putInList = function (arr) {
  let list = document.createElement("li");
  arr.forEach(e => {
    let unorderedList = document.createElement("ul");
    unorderedList.innerText = e.toString();
    list.appendChild(unorderedList);
  });
  return list;
};
const putInSpan = function (e) {
  let span = document.createElement("span");
  span.innerText = e.toString();
  return span;
};
const createTableDataWithTag = function (e) {
  let tableData = document.createElement("td");
  tableData.appendChild(e)
  return tableData;
};
const putArrInTable = function (arr, map) {
  let table = document.createElement("table");
  arr.forEach(e => {
    let tableRow = map(e);
    table.appendChild(tableRow);
  });
  return table;
};
const mapCanisterInTableRow = function (canister : CanisterOutput) {
  let tableRow = document.createElement("tr");
  tableRow.appendChild(createTableDataWithTag(putInSpan(canister.id)));
  tableRow.appendChild(createTableDataWithTag(putInSpan(canister.lock)));
  tableRow.appendChild(createTableDataWithTag(putInList(canister.proposals)));
  tableRow.appendChild(createTableDataWithTag(putInList(canister.resolutions)));
  return tableRow;
};
const mapProposalInTableRow = function (proposal : ProposalOutput) {
  let tableRow = document.createElement("tr");
  tableRow.appendChild(createTableDataWithTag(putInSpan(proposal.proposal_type)));
  tableRow.appendChild(createTableDataWithTag(putInSpan(proposal.proposal_status)));
  tableRow.appendChild(createTableDataWithTag(putInSpan(proposal.agree_threshold)));
  tableRow.appendChild(createTableDataWithTag(putInSpan(proposal.voter_threshold)));
  tableRow.appendChild(createTableDataWithTag(putInList(proposal.agree_voters)));
  tableRow.appendChild(createTableDataWithTag(putInList(proposal.total_voters)));
  return tableRow;
};


export const  renderLoggedIn = async (
  actor: ActorSubclass<_SERVICE>,
  authClient: AuthClient
) => {
  render(content(), (document.getElementById("pageContent") as HTMLElement));
  try {
    const response = await actor.whoami();
    console.log(response);
    (document.getElementById("whoami") as HTMLInputElement).value =
      response.toString();
  } catch (error) {
    console.error(error);
  };
  (document.getElementById("btnGetCycles") as HTMLButtonElement).onclick =
    async () => {
      try {
        const response = await actor.get_cycles();
        console.log(response);
        (document.getElementById("blkCycles") as HTMLInputElement).innerText =
          response.toString();
      } catch (error) {
        console.error(error);
      };
    };
  (document.getElementById("btnGetControllers") as HTMLButtonElement).onclick =
    async () => {
      try {
        const response = await actor.get_controllers();
        console.log(response);
        (document.getElementById("blkControllers") as HTMLInputElement).appendChild(
          (response.length != 0)? putInList(response): putInSpan("There is no controller.")
        );
      } catch (error) {
        console.error(error);
      };
    };
  (document.getElementById("btnGetCanisters") as HTMLButtonElement).onclick =
    async () => {
      try {
        const response = await actor.get_canisters();
        console.log(response);
        (document.getElementById("blkCanisters") as HTMLInputElement).appendChild(
          (response.length != 0)? putArrInTable(response, mapCanisterInTableRow): putInSpan("There is no canister under control.")
        );
      } catch (error) {
        console.error(error);
      };
    };
  (document.getElementById("btnGetPublicProposals") as HTMLButtonElement).onclick =
    async () => {
      try {
        const response = await actor.get_public_proposals();
        console.log(response);
        (document.getElementById("blkPublicProposals") as HTMLInputElement).appendChild(
          (response.length != 0)? putArrInTable(response, mapProposalInTableRow): putInSpan("There is no public proposal.")
        );
      } catch (error) {
        console.error(error);
      };
    };
  (document.getElementById("btnGetPublicResolutions") as HTMLButtonElement).onclick =
    async () => {
      try {
        const response = await actor.get_public_resolutions();
        console.log(response);
        (document.getElementById("blkPublicResolutions") as HTMLInputElement).appendChild(
          (response.length != 0)? putArrInTable(response, mapProposalInTableRow): putInSpan("There is no public resolution.")
        );
      } catch (error) {
        console.error(error);
      };
    };

  (document.getElementById("logout") as HTMLButtonElement).onclick =
    async () => {
      await authClient.logout();
      renderIndex();
    };
};
