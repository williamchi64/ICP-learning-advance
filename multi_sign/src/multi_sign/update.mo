import ArrayList "ArrayList";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Deque "mo:base/Deque";
import Iter "mo:base/Iter";
import List "mo:base/List";
import T "type";
import TrieMap "mo:base/TrieMap";

module {
    /* 
     * canister_ids : List<T.CanisterId> + waiting_processes : TrieMap<T.CanisterId, T.ProposalTypes> 
     *   -> canisters : MutArrayList<T.Canister>
     */
    public func update_canisters (
        canister_ids : List.List<T.CanisterId>, 
        waiting_processes : TrieMap.TrieMap<T.CanisterId, T.ProposalTypes>,
        default_canister : T.Canister
    ) : ArrayList.MutArrayList<T.Canister> {
        let result = ArrayList.MutArrayList<T.Canister>(default_canister, null);
        let cid_iter = Iter.fromList<T.CanisterId>(canister_ids);
        for (cid in cid_iter) {
            var lock = switch (waiting_processes.get(cid)) {
                case null #unlock;
                case (?wp) {
                    // Debug.print("wp" # debug_show(wp));
                    #lock(
                        {
                            var install = List.some<T.ProposalType>(wp, func (pt : T.ProposalType) {pt == #install});
                            var start = List.some<T.ProposalType>(wp, func (pt : T.ProposalType) {pt == #start});
                            var stop = List.some<T.ProposalType>(wp, func (pt : T.ProposalType) {pt == #stop});
                            var delete = List.some<T.ProposalType>(wp, func (pt : T.ProposalType) {pt == #delete});
                        }
                    )
                };
            };
            // Debug.print("cid" # debug_show(cid));
            result.add(
                {
                    id = cid;
                    var lock = lock;
                    var proposals = Deque.empty<T.ProposalUpdate>();
                }
            );
        };
        result
    };
    private func update_proposal_type (proposal_type : T.ProposalType) : T.ProposalTypeUpdate {
        switch (proposal_type) {
            case (#create) {
                #create({ cycles = 100_000_000_000; })
            };
            case (#install) {
                #install({
                    wasm_code = Blob.fromArray([0]); wasm_code_sha256 = [0]; mode = #install;
                })
            };
            case (#start) {#start};
            case (#stop) {#stop};
            case (#delete) {#delete};
        }
    };
    /* 
     * canister_ids : List<T.CanisterId> + waiting_processes : TrieMap<T.CanisterId, T.ProposalTypes> 
     *   -> canisters : MutArrayList<T.Canister>
     */
    public func update_proposals (
        proposals : TrieMap.TrieMap<T.CanisterId, T.Proposal>,
        canisters : ArrayList.MutArrayList<T.Canister>
    ) {
        for (canister in canisters.iter()) {
            let proposal = proposals.get(canister.id);
            switch (proposal) {
                case null {};
                case (?p) {
                    canister.proposals := Deque.pushBack<T.ProposalUpdate>(
                        canister.proposals, 
                        {
                            proposal_type = update_proposal_type(p.proposal_type);
                            voter_threshold = p.voter_threshold;
                            agree_proportion = { numerator = 1; denominator = 1; };
                            var agree_voters = p.voter_agree;
                            var total_voters = p.voter_total;
                        }
                    );
                }
            };
        };
    };
}