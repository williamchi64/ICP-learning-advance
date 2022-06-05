import Deque "mo:base/Deque";
import List "mo:base/List";

import IC "ic";

module {

    type Deque<T> = Deque.Deque<T>;
    type List<T> = List.List<T>;

    public type IC = IC.Self;
    public type CanisterStatus = {
        status : { #stopped; #stopping; #running; };
        freezing_threshold : Nat;
        memory_size : Nat;
        cycles : Nat;
        settings : IC.definite_canister_settings;
        module_hash : ?[Nat8];
        // idle_cycles_burned_per_second : Float;
    };
    public type Canister = {
        id : CanisterId;
        var lock : { #lock : LockParam; #unlock; };
        var proposals : Deque<Proposal<CanisterProposalType>>;
        var resolutions : Deque<Proposal<CanisterProposalType>>;
    };
    public type CanisterId = IC.canister_id;
    public type LockParam = {
        var install : Permission;
        var start : Permission;
        var stop : Permission;
        var delete : Permission;
    };
    public type Permission = { #allowed; #disallowed; };
    public type Proposal <T> = {
        proposal_type : T;
        var proposal_status : ProposalStatus;
        msg : ?Text;
        voter_threshold : Nat;
        agree_threshold : Nat;
        var agree_voters : List<Principal>;
        var total_voters : List<Principal>;
    };
    public type ProposalType = {
        #public_proposal : PublicProposalType; 
        #canister_proposal : CanisterProposalType;
    };
    public type PublicProposalType = {
        #register : { identity : Principal };
        #unregister : { identity : Principal };
        #create : { cycles : ?Nat; };
        #lock : { n : Nat; };
        #unlock : { n : Nat; };
    };
    public type CanisterProposalType = {
        #install : {
            wasm_code : Blob;
            wasm_code_sha256 : ?[Nat8];
            mode : InstallMode;
        };
        #start; #stop; #delete;
    };
    public type InstallMode = { #install; #upgrade; #reinstall; };
    public type ProposalStatus = { #idle; #voting; #pass; #fail; };

    public type Error = {
        #index_out_of_bound_error : { msg : Text; };
        #async_call_error : { msg : Text; };
        #not_enough_cycle_exception : { msg : Text; cycle_limit : Nat; };
        #register_exception : { msg : Text; };
        #proposal_exception : { msg : Text; };
        #resolution_exception : { msg : Text; };
        #vote_exception : { msg : Text };
        #unknown_error : { msg : Text };
    };

}