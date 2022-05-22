import Debug "mo:base/Debug";
import Error "mo:base/Error";
import List "mo:base/List";

import T "type";

module {
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
}