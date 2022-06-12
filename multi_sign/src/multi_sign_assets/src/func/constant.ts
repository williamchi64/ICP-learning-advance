import { BtnCanister, BtnProposal } from "./type";


const PUBLIC_PROPOSAL_TYPE_BRANCH = ["register", "unregister", "lock", "unlock", "create"];
const CANISTER_PROPOSAL_TYPE_BRANCH = ["start", "install", "stop", "delete"];
const PROPOSAL_STATUS_BRANCH = ["idle", "voting", "pass", "fail"];
const PERMISSION_BRANCH = ["allowed", "disallowed"];

const CANISTER_COLUMNS = ["Id", "Principal Id", "Lock", "Proposal", "Resolution"];
const PROPOSAL_COLUMNS = ["Id", "Proposal Type", "Proposal Status", "Agree Threshold", "Voter Threshold", "Agree Voter", "Total Voter", "Message"];
const CANISTER_LOCK_COLUMNS = ["Id", "Start", "Install", "Stop", "Delete"];

let BTN_CANISTER : BtnCanister = {
    lock : "btnCanisterLock_",
    proposals : "btnCanisterProposals_",
    resolutions : "btnCanisterResolutions_"
};

let BTN_PROPOSAL : BtnProposal = {
    proposal_type : "btnPublicProposalType_",
    proposal_status : "btnPublicProposalStatus_",
    agree_voters : "btnPublicProposalAgreeVoters_",
    total_voters : "btnPublicProposalTotalVoters_"
};

let BTN_RESOLUTION : BtnProposal = {
    proposal_type : "btnPublicResolutionType_",
    proposal_status : "btnPublicResolutionStatus_",
    agree_voters : "btnPublicResolutionAgreeVoters_",
    total_voters : "btnPublicResolutionTotalVoters_"
};

let BTN_CANISTER_PROPOSAL : BtnProposal = {
    proposal_type : "btnCanisterProposalType_",
    proposal_status : "btnCanisterProposalStatus_",
    agree_voters : "btnCanisterProposalAgreeVoters_",
    total_voters : "btnCanisterProposalTotalVoters_"
};

let BTN_CANISTER_RESOLUTION : BtnProposal = {
    proposal_type : "btnCanisterResolutionType_",
    proposal_status : "btnCanisterResolutionStatus_",
    agree_voters : "btnCanisterResolutionAgreeVoters_",
    total_voters : "btnCanisterResolutionTotalVoters_"
};

export default {
    PUBLIC_PROPOSAL_TYPE_BRANCH,
    CANISTER_PROPOSAL_TYPE_BRANCH,
    PROPOSAL_STATUS_BRANCH,
    PERMISSION_BRANCH,

    CANISTER_COLUMNS,
    PROPOSAL_COLUMNS,
    CANISTER_LOCK_COLUMNS,

    BTN_CANISTER,
    BTN_PROPOSAL,
    BTN_RESOLUTION,
    BTN_CANISTER_PROPOSAL,
    BTN_CANISTER_RESOLUTION
};