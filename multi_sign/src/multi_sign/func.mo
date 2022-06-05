import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Deque "mo:base/Deque";
import Error "mo:base/Error";
import Float "mo:base/Float";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Res "mo:base/Float";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import TrieSet "mo:base/TrieSet";
import Principal "mo:base/Principal";

import SHA256 "mo:sha256/SHA256";

import ArrayList "ArrayList";
import T "type";

module {

    type ArrayList<T> = ArrayList.ArrayList<T>;
    type Result<T, E> = Result.Result<T, E>;
    type TrieSet<T> = TrieSet.Set<T>;
    type Deque<T> = Deque.Deque<T>;

    public func get_of_array_list<T> (n : Nat, al : ArrayList<T>) : Result<T, T.Error> {
        Result.fromOption<T, T.Error>(
            al.get(n),
            #index_out_of_bound_error({ msg = "Caught Error: the index is out of bound" })
        )
    };

    public func get_canister_id (n : Nat, canisters : ArrayList<T.Canister>) : Result<T.CanisterId, T.Error> {
        Result.mapOk<T.Canister, T.CanisterId,T.Error>(
            Result.fromOption<T.Canister, T.Error>(
                canisters.get(n), 
                #index_out_of_bound_error({ msg = "Caught Error: the index is out of bound" })
            ), 
            func (canister : T.Canister) { canister.id }
        )
    };

    public func is_identity_registered (identity : Principal, controllers : TrieSet<Principal>) : Bool {
        TrieSet.mem(controllers, identity, Principal.hash(identity), Principal.equal)
    };

    public func pop_proposal<T> (proposals : Deque<T.Proposal<T>>) : Result<(T.Proposal<T>, Deque<T.Proposal<T>>), T.Error> {
        switch (Deque.popFront(proposals)) {
            case (null) {
                return #err(#proposal_exception({ 
                    msg = "Caught exception: there is no proposal in the list. " 
                        # "Please post a proposal or vote a proposal first" 
                }));
            };
            case (?(val, deque)) #ok(val, deque);
        };
    };

    public func vote_proposal <T> (
        caller : Principal,
        agree : Bool,
        proposal : T.Proposal<T>
    ) : T.ProposalStatus {
        if (agree) proposal.agree_voters := List.push(caller, proposal.agree_voters);
        proposal.total_voters := List.push(caller, proposal.total_voters);
        if (List.size(proposal.total_voters) < proposal.voter_threshold) {
            proposal.proposal_status := #voting;
            return #voting;
        };
        if (List.size(proposal.agree_voters) < proposal.agree_threshold) {
            proposal.proposal_status := #fail;
            #fail
        } else {
            proposal.proposal_status := #pass;
            #pass
        };
    };

    public func fill_wasm_code_sha256 (proposal_type : T.CanisterProposalType) : T.CanisterProposalType {
        switch (proposal_type) {
            case (#install({ wasm_code; wasm_code_sha256; mode; })) {
                let wcs256 = switch (wasm_code_sha256) {
                    case (?wcs256) wcs256;
                    case null SHA256.sha256(Blob.toArray(wasm_code));
                };
                #install({
                    wasm_code = wasm_code;
                    wasm_code_sha256 = ?wcs256;
                    mode = mode;
                })
            };
            case _ proposal_type;
        };
    };

    public func check_lock (canister : T.Canister) : Bool {
        switch (canister.lock) {
            case (#unlock) true;
            case (#lock(lock_param)) {
                switch (lock_param.install) {
                    case (#allowed) true;
                    case (#disallowed) false;
                };
            };
        }
    };

    public func check_voter <T> (caller : Principal, proposal : T.Proposal<T>) : Bool {
        List.some<Principal>(proposal.total_voters, func (voter : Principal) {
            Principal.equal(voter, caller)
        })
    };

}