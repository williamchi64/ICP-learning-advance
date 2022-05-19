import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Deque "mo:base/Deque";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Option "mo:base/Option";

import Logger "mo:ic-logger/Logger";

shared actor class InfinityLogger() {

    stable var state: Logger.State<Text> = Logger.new(0, null);

    let logger = Logger.Logger<Text>(state);

    public shared func append (msgs: [Text]) : async () {
        logger.append(msgs);
    };

    public shared query func stats () : async Logger.Stats {
        logger.stats()
    };

    public shared query func view (from: Nat, to: Nat) : async Logger.View<Text> {
        logger.view(from, to)
    };

};
