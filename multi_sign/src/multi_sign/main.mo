import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import F "func";
import Float "mo:base/Float";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import T "type";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import TrieSet "mo:base/TrieSet";

actor class () = self {

    stable var canister_ids : List.List<T.CanisterId> = List.nil();
    stable var controllers : TrieSet.Set<Principal> = TrieSet.fromArray([Principal.fromText("ebffk-bwfav-ug43x-oxpjj-aqko7-e7n5l-2xrpg-twq5s-sjlib-pa6b4-sqe"), Principal.fromText("to4yd-p3ipb-q2tlu-irxoc-f3gge-7losz-4mqnk-3kmd3-otdhw-nrjlp-aae"), Principal.fromText("wlutc-kzlpm-qchz4-ucxeo-ktswb-jpea6-ocngv-di4oz-heqh4-qtwo7-vqe")], Principal.hash, Principal.equal);
    // Paul's suggest using TrieMap instead of Hashmap
    var proposals = TrieMap.TrieMap<T.CanisterId, T.Proposal>(Principal.equal, Principal.hash);
    var waiting_processes = TrieMap.TrieMap<T.CanisterId, T.ProposalTypes>(Principal.equal, Principal.hash);

    // for upgrade data transfer
    stable var proposal_entries : [(T.CanisterId, T.Proposal)] = [];
    stable var waiting_processes_entries : [(T.CanisterId, T.ProposalTypes)] = [];
    system func preupgrade() {
        proposal_entries := Iter.toArray(proposals.entries());
        waiting_processes_entries := Iter.toArray(waiting_processes.entries());
    };
    system func postupgrade() {
        proposals := TrieMap.fromEntries<T.CanisterId, T.Proposal>(proposal_entries.vals(), Principal.equal, Principal.hash);
        waiting_processes := TrieMap.fromEntries<T.CanisterId, T.ProposalTypes>(waiting_processes_entries.vals(), Principal.equal, Principal.hash);
        proposal_entries := [];
        waiting_processes_entries := [];
    };

    let ic : T.IC = actor("aaaaa-aa");
    let DEFAULT_CANISTER_ID : T.CanisterId = Principal.fromActor(ic);
    let DEFAULT_CREATE_CANISTER_CYCLES = 100_000_000_000;
    let DEFAULT_AGREE_PROPORTION = 1.0;

    private func get_cid (n : Nat) : T.CanisterId {
        F.get<T.CanisterId>(n, canister_ids, DEFAULT_CANISTER_ID)
    };
    private func remove_cid (n : Nat) {
        canister_ids := F.remove(n, canister_ids);
    };
    // invoke function<Principal -> ()>, return bool determining success
    private func invoke (
        function : shared T.CanisterIdParam -> async (),
        n : Nat,
        proposal_type : T.ProposalType
    ) : async Bool {
        if (not check_waiting_process(?n, proposal_type))
            return false;
        try {
            await function({canister_id = get_cid(n)});
        } catch (e) {
            Debug.print("Caught error: " # Error.message(e));
            refund_waiting_process(?n, proposal_type);
            return false;
        };
        true
    };
    /* 
     * check if a proposal type is in the waiting process list, and consume(delete) the proposal type, 
     *   return true if existing
     */
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
    // only used in try catch when the process catch an error
    private func refund_waiting_process(n : ?Nat, refund_proposal_type : T.ProposalType) {
        let canister_id = switch (n) {
            case (?n) get_cid(n);
            case null DEFAULT_CANISTER_ID;
        };
        switch (waiting_processes.get(canister_id)) {
            case null {};
            case (?waiting_process) {
                var mut_waiting_process = waiting_process;
                mut_waiting_process := List.push(refund_proposal_type, mut_waiting_process);
                waiting_processes.put(canister_id, mut_waiting_process);
            };
        };
    };
    private func remove_wp(n : ?Nat) {
        let canister_id = switch (n) {
            case (?n) get_cid(n);
            case null DEFAULT_CANISTER_ID;
        };
        waiting_processes.delete(canister_id);
    };
    public query func get_canisters () : async List.List<T.CanisterId> {
        canister_ids
    };
    public query func get_controllers () : async TrieSet.Set<Principal> {
        controllers
    };
    public query func get_proposals () : async [(T.CanisterId, T.ProposalOutput)] {
        // Array.map<(T.CanisterId, T.Proposal),(T.CanisterId, T.ProposalOutput)>(Iter.toArray(proposals.entries()), F.map_proposal)
        let hm = TrieMap.map<T.CanisterId, T.Proposal, T.ProposalOutput>(proposals, Principal.equal, Principal.hash, F.map_proposal);
        Iter.toArray(hm.entries())
    };
    public query func get_waiting_processes () : async [(T.CanisterId, T.ProposalTypes)] {
        Iter.toArray(waiting_processes.entries())
    };
    public query func get_cycles () : async Nat {
        Cycles.balance()
    };
    // register self or other as a controller
    public shared (msg) func register(registerer : ?Principal) : async Principal {
        let add_controller = switch (registerer) {
            case null msg.caller;
            case (?controller) controller;
        };
        if (TrieSet.mem(controllers, add_controller, Principal.hash(add_controller), Principal.equal)) {
            Debug.print(debug_show(add_controller) # " has already registered");
            return DEFAULT_CANISTER_ID;
        };
        controllers := TrieSet.put(controllers, add_controller, Principal.hash(add_controller), Principal.equal);
        add_controller
    };
    // unregister self or other as a controller
    public shared (msg) func unregister(unregisterer : ?Principal) : async Principal {
        let delete_controller = switch (unregisterer) {
            case null msg.caller;
            case (?controller) controller;
        };
        if (not TrieSet.mem(controllers, delete_controller, Principal.hash(delete_controller), Principal.equal)) {
            Debug.print(debug_show(delete_controller) # " has already unregistered or never registered");
            return DEFAULT_CANISTER_ID;
        };
        controllers := TrieSet.delete(controllers, delete_controller, Principal.hash(delete_controller), Principal.equal);
        delete_controller
    };
    /* 
     * post a proposal with affected canister number, proposal type, voter threshold(num of total voter)
     *   and agree proportion. 
     * If affected canister number is null, only #create process is allowed.
     * Otherwise, only #create process is not allowed.
     * For each canister(or null), only a proposal is allowed at the same time.
     */
    public shared (msg) func post_proposal (
        n : ?Nat, 
        proposal_type : T.ProposalType, 
        voter_threshold : ?Nat, 
        agree_proportion : ?Float
    ) : async Bool {
        assert(TrieSet.mem(controllers, msg.caller, Principal.hash(msg.caller), Principal.equal));
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
        let proposal = F.construct_proposal(proposal_type, voter_threshold, agree_proportion, TrieSet.size(controllers), DEFAULT_AGREE_PROPORTION);
        proposals.put(canister_id, proposal);
        true
    };
    /* 
     * vote a proposal with cnaister number and agree(or not), use pseudo-caller to simulate real-life voting process
     */
    public shared (msg) func vote_proposal (n : ?Nat, agree : Bool, pseudo_caller : ?Principal) : async Bool {
        let msg_caller = switch (pseudo_caller) {
            case null msg.caller;
            case (?pseudo) pseudo;
        };
        assert(TrieSet.mem(controllers, msg_caller, Principal.hash(msg_caller), Principal.equal));
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
                switch(List.find(proposal.voter_total, func (caller : Principal) : Bool { Principal.equal(msg_caller, caller) })) {
                    case (?caller) {
                        Debug.print(debug_show(msg.caller) # "has already voted");
                        return false;
                    };
                    case null {};
                };
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
    // five types of canister process in total. Each invocation will consume a resolution.
    // create_canister
    public shared (msg) func create_canister (cycles : ?Nat) : async Bool {
        assert(TrieSet.mem(controllers, msg.caller, Principal.hash(msg.caller), Principal.equal));
        let amount = switch (cycles) {
            case (?amount) {
                if (amount > Cycles.balance()) {
                    Debug.print("Amount cycles over balance. Please input with the amount less than " # debug_show(Cycles.balance()));
                    return false;
                };
                amount
            };
            case null DEFAULT_CREATE_CANISTER_CYCLES;
        };
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
            Cycles.add(amount);
            let result = await ic.create_canister(canister_settings);
            let refund = Cycles.refunded();
            Debug.print("Refund " # debug_show(refund));
            Debug.print("Current balance " # debug_show(Cycles.balance()));
            canister_ids := List.push(result.canister_id, canister_ids);
        } catch (e) {
            Debug.print("Caught error: " # Error.message(e));
            refund_waiting_process(null, #create);
            return false;
        };
        remove_wp(null);
        true
    };
    // install_code
    public shared (msg) func install_code (n : Nat, code : Blob, mode : T.InstallMode) : async Bool {
        assert(TrieSet.mem(controllers, msg.caller, Principal.hash(msg.caller), Principal.equal));
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
            refund_waiting_process(?n, #install);
            return false;
        };
        true
    };
    // start_canister
    public shared (msg) func start_canister (n : Nat) : async Bool {
        assert(TrieSet.mem(controllers, msg.caller, Principal.hash(msg.caller), Principal.equal));
        await invoke(ic.start_canister, n, #start)
    };
    // stop_canister
    public shared (msg) func stop_canister (n : Nat) : async Bool {
        assert(TrieSet.mem(controllers, msg.caller, Principal.hash(msg.caller), Principal.equal));
        await invoke(ic.stop_canister, n, #stop)
    };
    // delete_canister
    public shared (msg) func delete_canister (n : Nat) : async Bool {
        assert(TrieSet.mem(controllers, msg.caller, Principal.hash(msg.caller), Principal.equal));
        let flag = await invoke(ic.delete_canister, n, #delete);
        if (flag) {
            remove_wp(?n);
            remove_cid(n);
        };
        flag
    };
    /* 
     * show canister status. A field - idle_cycles_burned_per_second : Float is ignored, 
     *   probably caused by the different environment with the main net
     */
    public func canister_status (n : Nat) : async T.CanisterStatus {
        await ic.canister_status({ canister_id = get_cid(n) })
    };
};