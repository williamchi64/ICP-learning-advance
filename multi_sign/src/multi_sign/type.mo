import Deque "mo:base/Deque";
import List "mo:base/List";

import IC "ic";

module {
    public type IC = IC.Self;
    public type CanisterId = IC.canister_id;
    public type LockParam = {
        var install : Bool;
        var start : Bool;
        var stop : Bool;
        var delete : Bool;
    };
    public type Canister = {
        id : CanisterId;
        var lock : { #lock : LockParam; #unlock; };
        var proposals : Deque.Deque<ProposalUpdate>;
    };
    public type CanisterStatus = {
        status : { #stopped; #stopping; #running; };
        freezing_threshold : Nat;
        memory_size : Nat;
        cycles : Nat;
        settings : IC.definite_canister_settings;
        module_hash : ?[Nat8];
        // idle_cycles_burned_per_second : Float;
    };
    public type InstallMode = { #install; #upgrade; #reinstall; };
    public type CreateParam = { cycles : Nat; };
    public type InstallParam = { wasm_code : Blob; wasm_code_sha256 : [Nat8]; mode : InstallMode; };
    public type ProposalType = {
        // #create : CreateParam;
        #create;
        // #install : InstallParam;
        #install;
        #start; #stop; #delete;
    };
    public type ProposalTypeUpdate = {
        #create : CreateParam;
        // #create;
        #install : InstallParam;
        // #install;
        #start; #stop; #delete;
    };
    public type ProposalTypes = List.List<ProposalType>;
    public type Proposal = {
        proposal_type : ProposalType;
        voter_threshold : Nat;
        agree_proportion : Float;
        var voter_agree : List.List<Principal>;
        var voter_total : List.List<Principal>;
    };
    public type ProposalUpdate = {
        proposal_type : ProposalTypeUpdate;
        voter_threshold : Nat;
        agree_proportion : { numerator : Nat; denominator : Nat; };
        var agree_voters : List.List<Principal>;
        var total_voters : List.List<Principal>;
    };
    public type ProposalOutput = {
        proposal_type : ProposalType;
        voter_threshold : Nat;
        agree_proportion : Float;
        voter_agree : List.List<Principal>;
        voter_total : List.List<Principal>;
        total_voter_agree : Nat;
        total_voter_num : Nat;
    };
    public type CanisterOuputUpdate = {
        id : CanisterId;
        lock : { #lock : {
            install : Bool;
            start : Bool;
            stop : Bool;
            delete : Bool;
        }; #unlock; };
        proposals : Deque.Deque<ProposalOutputUpdate>;
    };
    public type ProposalOutputUpdate = {
        proposal_type : ProposalTypeUpdate;
        voter_threshold : Nat;
        agree_proportion : { numerator : Nat; denominator : Nat; };
        agree_voters : List.List<Principal>;
        total_voters : List.List<Principal>;
        total_agree_num : Nat;
        total_voter_num : Nat;
    };
    public type ProposalStatus = { #voting; #pass; #fail; };
}