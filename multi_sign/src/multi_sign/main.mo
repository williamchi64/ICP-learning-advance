import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import List "mo:base/List";
import HashMap "mo:base/HashMap";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

import T "type";
import F "func";

actor class () = self {

    stable var canister_ids : List.List<T.CanisterId> = List.nil();
    var proposals = HashMap.HashMap<T.CanisterId, T.Proposal>(10, Principal.equal, Principal.hash);
    var waiting_processes = HashMap.HashMap<T.CanisterId, T.ProposalTypes>(10, Principal.equal, Principal.hash);

    // for upgrade data transfer
    stable var proposal_entries : [(T.CanisterId, T.Proposal)] = [];
    stable var waiting_processes_entries : [(T.CanisterId, T.ProposalTypes)] = [];
    system func preupgrade() {
        proposal_entries := Iter.toArray(proposals.entries());
        waiting_processes_entries := Iter.toArray(waiting_processes.entries());
    };
    system func postupgrade() {
        proposals := HashMap.fromIter<Principal, T.Proposal>(proposal_entries.vals(), 10, Principal.equal, Principal.hash);
        waiting_processes := HashMap.fromIter<Principal, T.ProposalTypes>(waiting_processes_entries.vals(), 10, Principal.equal, Principal.hash);
        proposal_entries := [];
        waiting_processes_entries := [];
    };

    let ic : T.IC = actor("aaaaa-aa");
    let DEFAULT_CANISTER_ID : T.CanisterId = Principal.fromActor(ic);

    private func get_cid (n : Nat) : T.CanisterId {
        F.get<T.CanisterId>(n, canister_ids, DEFAULT_CANISTER_ID)
    };
    private func remove_cid (n : Nat) {
        canister_ids := F.remove(n, canister_ids);
    };
    // envoke function<Principal -> ()>, return bool determining success
    private func envoke (
        function : shared T.CanisterIdParam -> async (),
        n : Nat
    ) : async Bool {
        try {
            await function({canister_id = get_cid(n)});
        } catch (e) {
            Debug.print("Caught error: " # Error.message(e));
            return false;
        };
        true
    };
    private func check_waiting_process (n : ?Nat, check_proposal_type : T.ProposalType) : Bool {
        let canister_id = switch (n) {
            case (?n) get_cid(n);
            case null DEFAULT_CANISTER_ID;
        };
        switch (waiting_processes.get(canister_id)) {
            case null {
                Debug.print("Caught exception: please post and vote a proposal first");
                return false;
            };
            case (?waiting_process) {
                var mut_waiting_process = waiting_process;
                if (List.size(waiting_process) <= 0) {
                    Debug.print("Caught exception: you have run out of resolution. Please pass a resolution first");
                    return false;
                };
                var flag = false;
                var index = 0;
                label L for (proposal_type in Iter.fromList(waiting_process)) {
                    if (proposal_type == check_proposal_type) {
                        mut_waiting_process := F.remove<T.ProposalType>(index, mut_waiting_process);
                        waiting_processes.put(canister_id, mut_waiting_process);
                        flag := true;
                        break L;
                    };
                    index += 1;
                };
                if (not flag) {
                    Debug.print("Caught exception: you have run out of resolution. Please pass a resolution first");
                    return false;
                };
            };
        };
        Debug.print("Consume a resolution");
        true
    };
    public query func get_canisters () : async List.List<T.CanisterId> {
        canister_ids
    };
    public query func get_proposals () : async [(T.CanisterId, T.ProposalOutput)] {
        // Array.map<(T.CanisterId, T.Proposal),(T.CanisterId, T.ProposalOutput)>(Iter.toArray(proposals.entries()), F.map_proposal)
        let hm = HashMap.map<T.CanisterId, T.Proposal, T.ProposalOutput>(proposals, Principal.equal, Principal.hash, F.map_proposal);
        Iter.toArray(hm.entries())
    };
    public query func get_waiting_processes () : async [(T.CanisterId, T.ProposalTypes)] {
        Iter.toArray(waiting_processes.entries())
    };
    public func post_proposal (
        n : ?Nat, 
        proposal_type : T.ProposalType, 
        voter_threshold : ?Nat, 
        agree_proportion : ?Float
    ) : async Bool {
        let canister_id = switch (n) {
            case (?n) {
                let canister_id = get_cid(n);
                if (proposal_type == #create) {
                    Debug.print("Caught exception: the canister process of #create is not appropriate for a existing canister");
                    return false;
                };
                if (canister_id == DEFAULT_CANISTER_ID) {
                    Debug.print("Caught exception: the number is out of bound of canister list");
                    return false;
                };
                canister_id
            };
            case null {
                if (proposal_type != #create) {
                    Debug.print("Caught exception: missing canister number for the canister process of #install, #start, #stop or #delete");
                    return false;
                };
                DEFAULT_CANISTER_ID
            };
        };
        switch (proposals.get(canister_id)) {
            case (?proposal) {
                Debug.print("Caught exception: please finish existing proposal first");
                return false;
            };
            case null (); 
        };
        let proposal = F.construct_proposal(proposal_type, voter_threshold, agree_proportion);
        proposals.put(canister_id, proposal);
        true
    };
    public shared (msg) func vote_proposal (n : ?Nat, agree : Bool) : async Bool {
        let canister_id = switch (n) {
            case (?x) get_cid(x);
            case null DEFAULT_CANISTER_ID;
        };
        switch (proposals.get(canister_id)) {
            case null {
                Debug.print("Caught exception: please post a proposal first");
                return false;
            };
            case (?proposal) {
                switch (F.vote(proposal, agree, msg.caller)) {
                    case (#voting) {
                        Debug.print("The canister process of " # debug_show(proposal.proposal_type) # " is voting");
                        return false;
                    };  
                    case (#fail) {
                        Debug.print("The canister process of " # debug_show(proposal.proposal_type) # " failed");
                        proposals.delete(canister_id);
                        return false;
                    };
                    case (#pass) {
                        Debug.print("The voting pass the resolution of canister process of " # debug_show(proposal.proposal_type));
                        var waiting_process = switch (waiting_processes.get(canister_id)) {
                            case (?x) {x};
                            case null {List.nil<T.ProposalType>()};
                        };
                        waiting_process := List.push(proposal.proposal_type, waiting_process);
                        waiting_processes.put(canister_id, waiting_process);
                        proposals.delete(canister_id);
                    };
                };
            };  
        };
        true
    };
    // create_canister
    public func create_canister () : async Bool {
        if (not check_waiting_process(null, #create))
            return false;
        let canister_settings = {
            settings = ?{
                controllers = ?[Principal.fromActor(self)];
                freezing_threshold = null;
                memory_allocation = null;
                compute_allocation = null;
            };
        };
        try {
            let result = await ic.create_canister(canister_settings);
            canister_ids := List.push(result.canister_id, canister_ids);
        } catch (e) {
            Debug.print("Caught error: " # Error.message(e));
            return false;
        };
        true
    };
    // install_code
    public func install_code (n : Nat, code : Blob, mode : T.InstallMode) : async Bool {
        if (not check_waiting_process(?n, #install))
            return false;
        let code_settings = {
            canister_id = get_cid(n);
            wasm_module = Blob.toArray(code);
            mode = #install;
            arg = [];
        };
        try {
            await ic.install_code(code_settings);
        } catch (e) {
            Debug.print("Caught error: " # Error.message(e));
            return false;
        };
        true
    };
    // start_canister
    public func start_canister (n : Nat) : async Bool {
        if (not check_waiting_process(?n, #start))
            return false;
        await envoke(ic.start_canister, n)
    };
    // stop_canister
    public func stop_canister (n : Nat) : async Bool {
        if (not check_waiting_process(?n, #stop))
            return false;
        await envoke(ic.stop_canister, n)
    };
    // delete_canister
    public func delete_canister (n : Nat) : async Bool {
        if (not check_waiting_process(?n, #delete))
            return false;
        let flag = await envoke(ic.delete_canister, n);
        if (flag) remove_cid(n);
        flag
    };
    /* show canister status. A field - idle_cycles_burned_per_second : Float is ignored, 
     *   probably caused by the different environment with the main net
     */
    public func canister_status (n : Nat) : async T.CanisterStatus {
        await ic.canister_status({ canister_id = get_cid(n) })
    };
};