import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Float "mo:base/Float";
import List "mo:base/List";

import T "type";

module {

    let DEFAULT_VOTER_THRESHOLD = 10;
    let DEFAULT_AGREE_PROPORTION = 0.5;

    public func get<A> (n : Nat, list : List.List<A>, default : A) : A {
        switch (List.get(list, n)) {
            case (?x) x;
            case null {
                if (n != 0) get<A> (0, list, default) else default
            };
        }
    };
    public func remove<A> (n : Nat, list : List.List<A>) : List.List<A> {
        let head_part = List.take(list, n);
        let tail_part = List.drop(list, n + 1);
        List.append(head_part, tail_part);
    };
    public func vote (
        proposal : T.Proposal, 
        agree : Bool, 
        caller : Principal
    ) : T.ProposalStatus {
        if (agree) proposal.voter_agree := List.push(caller, proposal.voter_agree);
        proposal.voter_total := List.push(caller, proposal.voter_total);
        if (List.size(proposal.voter_total) < proposal.voter_threshold) return #voting;
        let agree_threshold = Float.toInt(
            Float.mul(
                Float.fromInt(proposal.voter_threshold), proposal.agree_proportion
            )
        );
        if (List.size(proposal.voter_agree) < agree_threshold) #fail else #pass
    };
    public func construct_proposal (
        proposal_type : T.ProposalType, 
        voter_threshold : ?Nat, 
        agree_proportion : ?Float
    ) : T.Proposal {
        {
            proposal_type = proposal_type;
            voter_threshold = switch (voter_threshold) {
                case (?x) x; case null DEFAULT_VOTER_THRESHOLD};
            agree_proportion = switch (agree_proportion) {
                case (?x) x; case null DEFAULT_AGREE_PROPORTION};
            var voter_agree = List.nil<Principal>();
            var voter_total = List.nil<Principal>();
        }
    };
    public func map_proposal (canister_id : T.CanisterId, proposal : T.Proposal) : T.ProposalOutput {
        {
            proposal_type = proposal.proposal_type;
            voter_threshold = proposal.voter_threshold;
            agree_proportion = proposal.agree_proportion;
            total_voter_agree = List.size(proposal.voter_agree);
            total_voter_total = List.size(proposal.voter_total);
        }
    };
}