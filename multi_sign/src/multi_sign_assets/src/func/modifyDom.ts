import { UnionType } from "typescript";
import { CanisterOutput, ProposalOutput, LockParamOutput, PublicProposalType, ProposalStatus, ProposalOutput_1 } from "../../../declarations/multi_sign/multi_sign.did";
import c from "../func/constant";
import { BtnCanister, BtnProposal } from "./type";


const strToSpan = function (e : string) {
    let span = document.createElement("span");
    span.innerText = e;
    return span;
};
const toList = function <T extends Object> (arr : Array<T>) {
    let list = document.createElement("li");
    arr.forEach(e => {
        let unorderedList = document.createElement("ul");
        unorderedList.innerText = e.toString();
        list.appendChild(unorderedList);
    });
    return list;
};
const toBtn = function <T extends Object> (e : T, id : string) {
    let btn = document.createElement("button");
    btn.id = id;
    btn.type = "button";
    btn.className = "primary";
    btn.innerText = e.toString();
    return btn;
};
const appendToNewNode = function <T extends Node> (tag : string, node : T) {
    let new_node = document.createElement(tag);
    new_node.appendChild(node);
    return new_node;
};
const unionToStr = function <T extends Object> (union : T, branch : Array<string>) {
    for (const str of branch) {
        if (str in union) return str;
    };
    return "no branch";
};
const toTableHeadRow = function (columns : Array<string>) {
    let tableRow = document.createElement("tr");
    for (const str of columns) {
        tableRow.appendChild(appendToNewNode("th", strToSpan(str)));
    };
    return tableRow;
};
const canisterToTableRow = function (canister : CanisterOutput, index : number, btn_canister : BtnCanister, canister_branch : Array<string>) {
    let tableRow = document.createElement("tr");
    let lock : Node = ("lock" in canister.lock) ? toBtn("lock", btn_canister.lock + index) : strToSpan("unlock");
    let proposals : Node = (canister.proposals.length !== 0) ? toBtn("proposals", btn_canister.proposals + index) : strToSpan("empty");
    let resolutions : Node = (canister.resolutions.length !== 0) ? toBtn("resolutions", btn_canister.resolutions + index) : strToSpan("empty");
    tableRow.appendChild(appendToNewNode("td", strToSpan(index.toString())));
    tableRow.appendChild(appendToNewNode("td", strToSpan(canister.id.toString())));
    tableRow.appendChild(appendToNewNode("td", lock));
    tableRow.appendChild(appendToNewNode("td", proposals));
    tableRow.appendChild(appendToNewNode("td", resolutions));
    return tableRow;
};
const proposalToTableRow = function (proposal : ProposalOutput | ProposalOutput_1, index : number, btn_proposal : BtnProposal, proposal_type_branch : Array<string>) {
    let tableRow = document.createElement("tr");
    let proposal_type = toBtn(unionToStr(proposal.proposal_type, proposal_type_branch), btn_proposal.proposal_type + index);
    let proposal_status = toBtn(unionToStr(proposal.proposal_status, c.PROPOSAL_STATUS_BRANCH), btn_proposal.proposal_status + index);
    let agree_voters : Node = (proposal.agree_voters.length !== 0) ? toBtn("agree voters", btn_proposal.agree_voters + index) : strToSpan("empty");
    let total_voters : Node = (proposal.total_voters.length !== 0) ? toBtn("total voters", btn_proposal.total_voters + index) : strToSpan("empty");
    let msg = (proposal.msg.length !== 0) ? proposal.msg.join(";") : "empty";
    tableRow.appendChild(appendToNewNode("td", strToSpan(index.toString())));
    tableRow.appendChild(appendToNewNode("td", proposal_type));
    tableRow.appendChild(appendToNewNode("td", proposal_status));
    tableRow.appendChild(appendToNewNode("td", strToSpan(proposal.agree_threshold.toString())));
    tableRow.appendChild(appendToNewNode("td", strToSpan(proposal.voter_threshold.toString())));
    tableRow.appendChild(appendToNewNode("td", agree_voters));
    tableRow.appendChild(appendToNewNode("td", total_voters));
    tableRow.appendChild(appendToNewNode("td", strToSpan(msg)));
    return tableRow;
};
const lockToTableRow = function (Lock_param : LockParamOutput, index : number, btn_canister : BtnCanister, permission_branch : Array<string>) {
    let tableRow = document.createElement("tr");
    tableRow.appendChild(appendToNewNode("td", strToSpan(index.toString())));
    tableRow.appendChild(appendToNewNode("td", strToSpan(unionToStr(Lock_param.start, permission_branch))));
    tableRow.appendChild(appendToNewNode("td", strToSpan(unionToStr(Lock_param.install, permission_branch))));
    tableRow.appendChild(appendToNewNode("td", strToSpan(unionToStr(Lock_param.stop, permission_branch))));
    tableRow.appendChild(appendToNewNode("td", strToSpan(unionToStr(Lock_param.delete, permission_branch))));
    return tableRow;
};
const arrToTable = function <T extends Object, F extends Function, B = BtnCanister | BtnProposal> (
    tableHeadRow : Node, arr : Array<T>, toRow : F, btn : B, branch : Array<string>
) {
    let table = document.createElement("table");
    table.appendChild(tableHeadRow);
    arr.forEach((value, index, array) => {
        let tableRow = toRow(value, index, btn, branch);
        table.appendChild(tableRow);
    });
    return table;
};
export default {
    strToSpan,
    toList,
    toBtn,
    appendToNewNode,
    unionToStr,
    toTableHeadRow,
    canisterToTableRow,
    proposalToTableRow,
    lockToTableRow,
    arrToTable
};