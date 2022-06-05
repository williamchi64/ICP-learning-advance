import Deque "mo:base/Deque";
import List "mo:base/List";
import Iter "mo:base/Iter";

import ArrayList "ArrayList";
import T "type";

module {

    type ArrayList<T> = ArrayList.ArrayList<T>;
    type List<T> = List.List<T>;

    // CanisterId to Canister
    public func map_canister_id_to_canister (canister_id : T.CanisterId) : T.Canister {
        {
            id = canister_id;
            var lock = #unlock;
            var proposals = Deque.empty<T.Proposal<T.CanisterProposalType>>();
            var resolutions = Deque.empty<T.Proposal<T.CanisterProposalType>>();
        }
    };

    public func map_canister_ids_to_canisters (canister_ids : List<T.CanisterId>, canisters : ArrayList<T.Canister>) {
        let canister_list = List.map<T.CanisterId, T.Canister>(canister_ids, map_canister_id_to_canister);
        for (canister in Iter.fromList(canister_list)) {
            canisters.add(canister);
        };
    };
};