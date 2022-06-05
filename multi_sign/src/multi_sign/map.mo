import Deque "mo:base/Deque";
import List "mo:base/List";

import ArrayList "ArrayList";
import T "type";

module {

    type ArrayList<T> = ArrayList.ArrayList<T>;
    type Deque<T> = Deque.Deque<T>;
    type List<T> = List.List<T>;

    public type CanisterOuput = {
        id : T.CanisterId;
        lock : { #lock : LockParamOuput; #unlock };
        proposals : [ProposalOutput<T.CanisterProposalType>];
        resolutions : [ProposalOutput<T.CanisterProposalType>];
    };
    public type LockParamOuput = {
        install : T.Permission;
        start : T.Permission;
        stop : T.Permission;
        delete : T.Permission;
    };
    public type ProposalOutput <T> = {
        proposal_type : T;
        proposal_status : T.ProposalStatus;
        msg : ?Text;
        voter_threshold : Nat;
        agree_threshold : Nat;
        agree_voters : [Principal];
        total_voters : [Principal];
    };

    public func canister_output (canister : T.Canister) : CanisterOuput {
        let lock = switch (canister.lock) {
            case (#unlock) #unlock;
            case (#lock(lock_param)) #lock({
                install = lock_param.install;
                start = lock_param.start;
                stop = lock_param.stop;
                delete = lock_param.delete;
            });
        };
        {
            id = canister.id;
            lock = lock;
            proposals = array_of_proposal<T.CanisterProposalType>(canister.proposals);
            resolutions = array_of_proposal<T.CanisterProposalType>(canister.resolutions);
        }
    };

    public func array_of_proposal <T> (proposals : Deque<T.Proposal<T>>) : [ProposalOutput<T>] {
        var mut_proposals = proposals;
        let al = ArrayList.ArrayList<ProposalOutput<T>>(null);
        while (not Deque.isEmpty(mut_proposals)) {
            switch (Deque.popFront(mut_proposals)) {
                case (?(val, deque)) {
                    al.add(proposal_freeze<T>(val));
                    mut_proposals := deque;
                };
                case null {};
            };
        };
        al.freeze()
    };

    private func proposal_freeze <T> (proposal : T.Proposal<T>) : ProposalOutput <T> {
        {
            proposal_type = proposal.proposal_type;
            proposal_status =  proposal.proposal_status;
            msg = proposal.msg;
            voter_threshold = proposal.voter_threshold;
            agree_threshold = proposal.agree_threshold;
            agree_voters = List.toArray(proposal.agree_voters);
            total_voters = List.toArray(proposal.total_voters);
        }
    };

}