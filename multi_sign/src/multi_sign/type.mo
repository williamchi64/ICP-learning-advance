import List "mo:base/List";

import IC "ic";

module {
    public type IC = IC.Self;
    public type CanisterId = IC.canister_id;
    public type CanisterIdParam = {canister_id : CanisterId};
    public type CanisterStatus = {
        status : { #stopped; #stopping; #running };
        freezing_threshold : Nat;
        memory_size : Nat;
        cycles : Nat;
        settings : IC.definite_canister_settings;
        module_hash : ?[Nat8];
        // idle_cycles_burned_per_second : Float;
    };
    public type InstallMode = { #reinstall; #upgrade; #install };
    public type ProposalType = { #create; #install; #start; #stop; #delete };
    public type ProposalTypes = List.List<ProposalType>;
    public type Proposal = {
        proposal_type : ProposalType;
        voter_threshold : Nat;
        agree_proportion : Float;
        var voter_agree : List.List<Principal>;
        var voter_total : List.List<Principal>;
    };
    public type ProposalOutput = {
        proposal_type : ProposalType;
        voter_threshold : Nat;
        agree_proportion : Float;
        total_voter_agree : Nat;
        total_voter_total : Nat;
    };
    public type ProposalStatus = { #voting; #pass; #fail };
}