import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Deque "mo:base/Deque";
import Error "mo:base/Error";
import Float "mo:base/Float";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import TrieSet "mo:base/TrieSet";
import Option "mo:base/Option";
import SHA256 "mo:sha256/SHA256";

import ArrayList "ArrayList";
import F "func";
import T "type";
import M "map";
import U "update";

actor class () = self {

    type ArrayList<T> = ArrayList.ArrayList<T>;
    type List<T> = List.List<T>;
    type Result<T, E> = Result.Result<T, E>;
    type TrieSet<T> = TrieSet.Set<T>;
    type Deque<T> = Deque.Deque<T>;

    let ic : T.IC = actor("aaaaa-aa");
    let DEFAULT_CANISTER_ID : T.CanisterId = Principal.fromActor(ic);
    let MIN_CANISTER_CREATE_CYCLES = 100_000_000_000;
    let DEFAULT_CANISTER_CREATE_CYCLES = 200_000_000_000;
    let DEFAULT_VOTER_THRESHOLD = 5;
    let DEFAULT_AGREE_THRESHOLD = 3;

    stable var canister_ids : List<T.CanisterId> = List.nil(); // old
    stable var controllers : TrieSet<Principal> = TrieSet.fromArray(
        [
            Principal.fromText("2vxsx-fae"),
            Principal.fromText("ebffk-bwfav-ug43x-oxpjj-aqko7-e7n5l-2xrpg-twq5s-sjlib-pa6b4-sqe"), 
            Principal.fromText("to4yd-p3ipb-q2tlu-irxoc-f3gge-7losz-4mqnk-3kmd3-otdhw-nrjlp-aae"), 
            Principal.fromText("wlutc-kzlpm-qchz4-ucxeo-ktswb-jpea6-ocngv-di4oz-heqh4-qtwo7-vqe")
        ], 
        Principal.hash, Principal.equal
    );
    var canisters : ArrayList<T.Canister> = ArrayList.ArrayList(null); // new
    stable var public_proposals : Deque<T.Proposal<T.PublicProposalType>> = Deque.empty();
    stable var public_resolutions : Deque<T.Proposal<T.PublicProposalType>> = Deque.empty();

    // for upgrade data transfer
    stable var canister_entries : [T.Canister] = [];
    system func preupgrade() {
        canister_entries := canisters.freeze();
    };
    system func postupgrade() {
        canisters := ArrayList.ArrayList<T.Canister>(?canister_entries);
        canister_entries := []; 
    };

    public query func get_old_canisters () : async [T.CanisterId] {
        List.toArray(canister_ids)
    };

    public shared query (msg) func whoami () : async Principal {
        msg.caller
    };

    /* 
     * show canister status. A field - idle_cycles_burned_per_second : Float is ignored, 
     *   probably caused by the different environment with the main net
     */
    public shared func canister_status (n : Nat) : async Result<T.CanisterStatus, T.Error> {
        switch (F.get_canister_id(n, canisters)) {
            case (#ok(val)) {
                try {
                    #ok(await ic.canister_status({ canister_id = val }))
                } catch (e) {
                    #err(#async_call_error({ msg = "Caught error: " # Error.message(e) }))
                }
            };
            case (#err(err)) #err(err);
        }
    };
    public query func get_cycles () : async Nat {
        Cycles.balance()
    };
    public query func get_controllers () : async [Principal] {
        TrieSet.toArray(controllers)
    };
    public query func get_canisters () : async [M.CanisterOutput] {
        ArrayList.map<T.Canister, M.CanisterOutput>(canisters, M.canister_output).freeze()
    };
    public query func get_canister (n : Nat) : async Result<M.CanisterOutput, T.Error> {
        switch (F.get_of_array_list(n, canisters)) {
            case (#err(err)) #err(err);
            case (#ok(val)) #ok(M.canister_output(val));
        }
    };
    public query func get_public_proposals () : async [M.ProposalOutput<T.PublicProposalType>] {
        M.array_of_proposal(public_proposals)
    };
    public query func get_public_resolutions () : async [M.ProposalOutput<T.PublicProposalType>] {
        M.array_of_proposal(public_resolutions)
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
        message : ?Text,
        voter_threshold : ?Nat,
        agree_threshold : ?Nat
    ) : async Result<{ msg : Text; }, T.Error> {
        if(not F.is_identity_registered(msg.caller, controllers))
            return #err(#register_exception({ msg = "Caught exception: You have not registered"; }));
        let vt = Option.get(voter_threshold, DEFAULT_VOTER_THRESHOLD);
        let at = Option.get(agree_threshold, DEFAULT_AGREE_THRESHOLD);
        if (vt < at or vt == 0 or at == 0) return #err(#proposal_exception({ 
            msg = "Caught exception: your are trapped because of one of two reasons: " 
                # "Voter threshold is less than agree threshold; " 
                # "Either Voter threshold or agree threshold is equal to zero. "; 
        }));
        switch (proposal_type) {
            case (#public_proposal(public_proposal_type)) {
                switch (n) {
                    case null {};
                    case (?n) return #err(#proposal_exception({ 
                        msg = "Caught exception: for public proposal type, index of a canister is not allowed"; 
                    }));
                };
                switch (post_public_proposal(public_proposal_type, message, vt, at)) {
                    case (#ok(val)) #ok(val);
                    case (#err(err)) return #err(err);
                };
            };
            case (#canister_proposal(canister_proposal_type)) {
                let index = switch (n) {
                    case null return #err(#proposal_exception({ 
                        msg = "Caught exception: for canister proposal type, null is not allowed"; 
                    }));
                    case (?n) n;
                };
                switch (post_canister_proposal(index, canister_proposal_type, message, vt, at)) {
                    case (#ok(val)) #ok(val);
                    case (#err(err)) return #err(err);
                };
            };
        };
    };

    /* 
     * vote a proposal with cnaister number and agree(or not), use pseudo-caller to simulate real-life voting process
     */
    public shared (msg) func vote (
        n : ?Nat,
        agree : Bool,
        pseudo_caller : ?Principal
    ) : async Result<T.ProposalStatus, T.Error> {
        let msg_caller = switch (pseudo_caller) {
            case null msg.caller;
            case (?pseudo) pseudo;
        };
        if(not F.is_identity_registered(msg_caller, controllers))
            return #err(#register_exception({ msg = "Caught exception: You have not registered"; }));
        switch (n) {
            case null {
                let proposal = switch (F.pop_proposal<T.PublicProposalType>(public_proposals)) {
                    case (#ok(val, deque)) { public_proposals := deque; val };
                    case (#err(err)) return #err(err);
                };
                if (F.check_voter<T.PublicProposalType>(msg_caller, proposal))
                    return #err(#vote_exception({ msg = "Caught exception: you have already voted"; }));
                switch (F.vote_proposal<T.PublicProposalType>(msg_caller, agree, proposal)) {
                    case (#voting) {
                        public_proposals := Deque.pushFront(public_proposals, proposal); 
                        return #ok(#voting);
                    };
                    case (#pass) {
                        public_resolutions := Deque.pushBack(public_resolutions, proposal);
                        return #ok(#pass);
                    }; 
                    case (#fail) {
                        return #ok(#fail);
                    };
                    case (_) {
                        return #err(#unknown_error({
                            msg = "Caught error: it is not allowed to get idle status of a proposal after voting process"; 
                        }));
                    };
                };
            };
            case (?n) {
                let canister = switch (F.get_of_array_list<T.Canister>(n, canisters)) {
                    case (#ok(val)) val;
                    case (#err(err)) return #err(err);
                };
                let proposal = switch (F.pop_proposal<T.CanisterProposalType>(canister.proposals)) {
                    case (#ok(val, deque)) { canister.proposals := deque; val };
                    case (#err(err)) return #err(err);
                };
                if (F.check_voter<T.CanisterProposalType>(msg_caller, proposal))
                    return #err(#vote_exception({ msg = "Caught exception: you have already voted"; }));
                switch (F.vote_proposal<T.CanisterProposalType>(msg_caller, agree, proposal)) {
                    case (#voting) {
                        canister.proposals := Deque.pushFront(canister.proposals, proposal); 
                        return #ok(#voting);
                    };
                    case (#pass) {
                        canister.resolutions := Deque.pushBack(canister.resolutions, proposal);
                        return #ok(#pass);
                    }; 
                    case (#fail) {
                        return #ok(#fail);
                    };
                    case (_) {
                        return #err(#unknown_error({
                            msg = "Caught error: it is not allowed to get idle status of a proposal after voting process"; 
                        }));
                    };
                };
            };
        };
        
    };
    // create_canister
    public shared (msg) func execute_resolution (n : ?Nat) : async Result<{ msg : Text; }, T.Error> {
        if(not F.is_identity_registered(msg.caller, controllers))
            return #err(#register_exception({ msg = "Caught exception: You have not registered"; }));
        switch (n) {
            case null {
                let resolution = switch (F.pop_proposal<T.PublicProposalType>(public_resolutions)) {
                    case (#ok(val, deque)) { public_resolutions := deque; val };
                    case (#err(err)) return #err(err);
                };
                switch (await execute_public_resolution_by_type(resolution.proposal_type)) {
                    case (#ok(val)) #ok(val);
                    case (#err(err)) return #err(err);
                };
            };
            case (?n) {
                let canister = switch (F.get_of_array_list<T.Canister>(n, canisters)) {
                    case (#ok(val)) val;
                    case (#err(err)) return #err(err);
                };
                let resolution = switch (F.pop_proposal<T.CanisterProposalType>(canister.resolutions)) {
                    case (#ok(val, deque)) { canister.resolutions := deque; val };
                    case (#err(err)) return #err(err);
                };
                switch (await execute_canister_resolution_by_type(n, resolution.proposal_type)) {
                    case (#ok(val)) #ok(val);
                    case (#err(err)) return #err(err);
                };
            };
        };
    };
    public shared (msg) func install_code (
        n : Nat,
        wasm_code : Blob,
        mode : T.InstallMode,
        message : ?Text
    ) : async Result<{ msg : Text; }, T.Error> {
        if (not F.is_identity_registered(msg.caller, controllers))
            return #err(#register_exception({ msg = "Caught exception: You have not registered"; }));
        let canister = switch (F.get_of_array_list(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        let wasm_code_sha256 = SHA256.sha256(Blob.toArray(wasm_code));
        if (F.check_lock(canister)) {
            return await execute_install_code(n, wasm_code, wasm_code_sha256, mode);
        };
        let proposal_type = #install({
            wasm_code = wasm_code;
            wasm_code_sha256 = ?wasm_code_sha256;
            mode = mode;
        });
        switch (post_canister_proposal(n, proposal_type, message, DEFAULT_VOTER_THRESHOLD, DEFAULT_AGREE_THRESHOLD)) {
            case (#ok({msg})) #ok({ msg = "code install is locked, " # msg # " instead" });
            case (#err(err)) #err(err);
        }
    };
    public shared (msg) func start_canister (n : Nat, message : ?Text) : async Result<{ msg : Text; }, T.Error> {
        if(not F.is_identity_registered(msg.caller, controllers))
            return #err(#register_exception({ msg = "Caught exception: You have not registered"; }));
        let canister = switch (F.get_of_array_list(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        if (F.check_lock(canister)) {
            return await execute_start_canister(n);
        };
        switch (post_canister_proposal(n, #start, message, DEFAULT_VOTER_THRESHOLD, DEFAULT_AGREE_THRESHOLD)) {
            case (#ok({msg})) #ok({ msg = "canister start is locked, " # msg # " instead" });
            case (#err(err)) #err(err);
        }
    };
    public shared (msg) func stop_canister (n : Nat, message : ?Text) : async Result<{ msg : Text; }, T.Error> {
        if(not F.is_identity_registered(msg.caller, controllers))
            return #err(#register_exception({ msg = "Caught exception: You have not registered"; }));
        let canister = switch (F.get_of_array_list(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        if (F.check_lock(canister)) {
            return await execute_stop_canister(n);
        };
        switch (post_canister_proposal(n, #stop, message, DEFAULT_VOTER_THRESHOLD, DEFAULT_AGREE_THRESHOLD)) {
            case (#ok({msg})) #ok({ msg = "canister stop is locked, " # msg # " instead" });
            case (#err(err)) #err(err);
        }
    };
    public shared (msg) func delete_canister (n : Nat, message : ?Text) : async Result<{ msg : Text; }, T.Error> {
        if(not F.is_identity_registered(msg.caller, controllers))
            return #err(#register_exception({ msg = "Caught exception: You have not registered"; }));
        let canister = switch (F.get_of_array_list(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        if (F.check_lock(canister)) {
            return await execute_delete_canister(n);
        };
        switch (post_canister_proposal(n, #delete, message, DEFAULT_VOTER_THRESHOLD, DEFAULT_AGREE_THRESHOLD)) {
            case (#ok({msg})) #ok({ msg = "canister delete is locked, " # msg # " instead" });
            case (#err(err)) #err(err);
        }
    };

    private func post_public_proposal (
        proposal_type : T.PublicProposalType,
        message : ?Text,
        voter_threshold : Nat,
        agree_threshold : Nat
    ) : Result<{ msg : Text; }, T.Error> {
        switch (check_public_proposal(proposal_type)) {
            case (#ok()) {};
            case (#err(err)) return #err(err);
        };
        let proposal = {
            proposal_type = proposal_type;
            var proposal_status : T.ProposalStatus = #idle;
            msg = message;
            voter_threshold = voter_threshold;
            agree_threshold = agree_threshold;
            var agree_voters = List.nil<Principal>();
            var total_voters = List.nil<Principal>();
        };
        public_proposals := Deque.pushBack(public_proposals, proposal);
        #ok({ msg = "success, post a public proposal"; })
    };
    private func post_canister_proposal (
        n : Nat,
        proposal_type : T.CanisterProposalType,
        message : ?Text,
        voter_threshold : Nat,
        agree_threshold : Nat
    ) : Result<{ msg : Text; }, T.Error> {
        switch (check_canister_proposal(proposal_type)) {
            case (#ok()) {};
            case (#err(err)) return #err(err);
        };
        let canister = switch (F.get_of_array_list(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        let pt = F.fill_wasm_code_sha256(proposal_type);
        let proposal = {
            proposal_type = pt;
            var proposal_status : T.ProposalStatus = #idle;
            msg = message;
            voter_threshold = voter_threshold;
            agree_threshold = agree_threshold;
            var agree_voters = List.nil<Principal>();
            var total_voters = List.nil<Principal>();
        };
        canister.proposals := Deque.pushBack(canister.proposals, proposal);
        #ok({ msg = "success, post a canister proposal"; })
    };

    // register self or other as a controller
    private func register (registerer : Principal) : Result<{ msg : Text; }, T.Error> {
        controllers := TrieSet.put(controllers, registerer, Principal.hash(registerer), Principal.equal);
        #ok({ msg = "registered identity: " # Principal.toText(registerer); })
    };
    // unregister self or other as a controller
    private func unregister (unregisterer : Principal) : Result<{ msg : Text; }, T.Error> {
        controllers := TrieSet.delete(controllers, unregisterer, Principal.hash(unregisterer), Principal.equal);
        #ok({ msg = "unregistered identity: " # Principal.toText(unregisterer); })
    };
    private func lock (n : Nat) : Result<{ msg : Text; }, T.Error> {
        let canister = switch (F.get_of_array_list<T.Canister>(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        let lock_param : T.LockParam = {
            var install = #disallowed;
            var start = #disallowed;
            var stop = #disallowed;
            var delete = #disallowed;
        };
        canister.lock := #lock(lock_param);
        #ok({ msg = "canister lock success: " # Principal.toText(canister.id); })
    };
    private func unlock (n : Nat) : Result<{ msg : Text; }, T.Error> {
        let canister = switch (F.get_of_array_list<T.Canister>(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        canister.lock := #unlock;
        #ok({ msg = "canister unlock success: " # Principal.toText(canister.id); })
    };
    private func create_canister (cycles : ?Nat) : async Result<{ msg : Text; }, T.Error> {
        var result = DEFAULT_CANISTER_ID;
        let canister_settings = {
            settings = ?{
                controllers = ?[Principal.fromActor(self)];
                freezing_threshold = null;
                memory_allocation = null;
                compute_allocation = null;
            };
        };
        let amount = switch (cycles) {
            case (?amount) {
                let balance = Cycles.balance();
                if (amount > balance) {
                    return #err(#not_enough_cycle_exception({ 
                        msg = "Caught exception: the amount of input cycles is currently larger than the balance. " 
                            # "Please repost a public proposal with the amount less than " # debug_show(balance);
                        cycle_limit = balance;
                    }));
                };
                amount
            };
            case null DEFAULT_CANISTER_CREATE_CYCLES;
        };
        try {
            Cycles.add(amount);
            result := (await ic.create_canister(canister_settings)).canister_id;
            let refund = Cycles.refunded();
        } catch (e) {
            return #err(#async_call_error({ msg = "Caught error: " # Error.message(e); }));
        };
        let canister : T.Canister = {
            id = result;
            var lock = #unlock;
            var proposals = Deque.empty<T.Proposal<T.CanisterProposalType>>();
            var resolutions = Deque.empty<T.Proposal<T.CanisterProposalType>>();
        };
        canisters.add(canister);
        #ok({ msg = "created canister: " # Principal.toText(result); })
    };
    private func execute_public_resolution_by_type (
        proposal_type : T.PublicProposalType
    ) : async Result<{ msg : Text; }, T.Error> {
        switch (proposal_type) {
            case (#register({identity})) register(identity);
            case (#unregister({identity})) unregister(identity);
            case (#create({cycles})) await create_canister(cycles);
            case (#lock({n})) lock(n);
            case (#unlock({n})) unlock(n);
        }
    };
    
    private func execute_canister_resolution_by_type (
        n : Nat,
        proposal_type : T.CanisterProposalType
    ) : async Result<{ msg : Text; }, T.Error> {
        switch (proposal_type) {
            case (#install({wasm_code; wasm_code_sha256; mode;})) {
                let wcs256 = switch (wasm_code_sha256) {
                    case (?wcs256) wcs256;
                    case null return #err(#unknown_error({
                        msg = "Caught error: wasm code sha256 is erroneously missed in install execution";
                    }));
                };
                await execute_install_code(n, wasm_code, wcs256, mode);
            };
            case (#start) await execute_start_canister(n);
            case (#stop) await execute_stop_canister(n);
            case (#delete) await execute_delete_canister(n);
        };
    };
    // install_code
    private func execute_install_code (
        n : Nat,
        wasm_code : Blob,
        wasm_code_sha256 : [Nat8],
        mode : T.InstallMode
    ) : async Result<{ msg : Text; }, T.Error> {
        let canister = switch (F.get_of_array_list<T.Canister>(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        let code_settings = {
            canister_id = canister.id;
            wasm_module = Blob.toArray(wasm_code);
            mode = mode;
            arg = [];
        };
        try {
            await ic.install_code(code_settings);
        } catch (e) {
            return #err(#async_call_error({ msg = "Caught error: " # Error.message(e); }));
        };
        #ok({ msg = "code install success, hash code: " # debug_show(wasm_code_sha256); })
    };
    // start_canister
    private func execute_start_canister (n : Nat) : async Result<{ msg : Text; }, T.Error> {
        let canister = switch (F.get_of_array_list(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        try {
            await ic.start_canister({ canister_id = canister.id; });
        } catch (e) {
            return #err(#async_call_error({ msg = "Caught error: " # Error.message(e); }));
        };
        #ok({ msg = "canister start success, canister: " # Principal.toText(canister.id); })
    };
    // stop_canister
    private func execute_stop_canister (n : Nat) : async Result<{ msg : Text; }, T.Error> {
        let canister = switch (F.get_of_array_list(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        try {
            await ic.stop_canister({ canister_id = canister.id; });
        } catch (e) {
            return #err(#async_call_error({ msg = "Caught error: " # Error.message(e); }));
        };
        #ok({ msg = "canister stop success, canister: " # Principal.toText(canister.id); })
    };
    // delete_canister
    private func execute_delete_canister (n : Nat) : async Result<{ msg : Text; }, T.Error> {
        let canister = switch (F.get_of_array_list(n, canisters)) {
            case (#ok(val)) val;
            case (#err(err)) return #err(err);
        };
        try {
            await ic.delete_canister({ canister_id = canister.id; });
        } catch (e) {
            return #err(#async_call_error({ msg = "Caught error: " # Error.message(e); }));
        };
        canisters.delete(n);
        #ok({ msg = "canister delete success, canister: " # Principal.toText(canister.id); })
    };

    private func check_public_proposal (proposal_type : T.PublicProposalType) : Result<(), T.Error> {
        switch (proposal_type) {
            case (#register({identity})) { 
                if(F.is_identity_registered(identity, controllers)) return #err(#register_exception({
                    msg = "Caught Exception: " 
                        # debug_show(identity) # " has already registered" 
                }));
            };
            case (#unregister({identity})) {
                if(not F.is_identity_registered(identity, controllers)) return #err(#register_exception({ 
                    msg = "Caught Exception: " 
                        # debug_show(identity) # " has already unregistered or never registered"
                }));
            };
            case (#create({cycles})) {
                switch (cycles) {
                    case (?cycles) {
                        let balance = Cycles.balance();
                        if (cycles > balance) return #err(#not_enough_cycle_exception({ 
                            msg = "Caught exception: the amount of input cycles is larger than the balance. " 
                                # "Please input with the amount less than " # debug_show(balance);
                            cycle_limit = balance;
                        }));
                        if (cycles < MIN_CANISTER_CREATE_CYCLES) return #err(#not_enough_cycle_exception({ 
                            msg = "Caught exception: the amount of cycles is less than the minimun requirement of a canister creation process. "
                                # "Please input with the amount larger than " # debug_show(MIN_CANISTER_CREATE_CYCLES);
                            cycle_limit = MIN_CANISTER_CREATE_CYCLES;
                        }));
                    };
                    case null {};
                };
            };
            case (#lock({n})) {
                if (n >= canisters.get_size()) return #err(#index_out_of_bound_error({ 
                    msg = "Caught Error: the index is out of bound" 
                }));
            };
            case (#unlock({n})) {
                if (n >= canisters.get_size()) return #err(#index_out_of_bound_error({ 
                    msg = "Caught Error: the index is out of bound" 
                }));
            };
        };
        #ok()
    };

    private func check_canister_proposal (proposal_type : T.CanisterProposalType) : Result<(), T.Error> {
        switch (proposal_type) {
            case (#install({ wasm_code; wasm_code_sha256; mode; })) {};
            case (#start) {};
            case (#stop) {};
            case (#delete) {};
        };
        #ok()
    };

};