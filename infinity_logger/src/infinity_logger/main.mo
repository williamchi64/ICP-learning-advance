import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";

import Logger "mo:ic-logger/Logger";

import IL "InfinityLogger";

actor {
    type InfinityLogger = IL.InfinityLogger;
    stable var sizeOfTopLogger : Nat = 0;
    stable var infinityLoggers : List.List<InfinityLogger> = List.nil();
    stable var totalSize : Nat = 0;
    let MAX_LOGGER_SIZE : Nat = 3;
    // size of messages about a logger, return size
    private func sizeOfLogger (logger : InfinityLogger) : async Nat {
        let stats = await logger.stats();
        var size = 0;
        for (bucketSize in stats.bucket_sizes.vals()) {
            size += bucketSize;
        };
        size
    };
    // get sub array, return new fix array
    private func subArr <T> (arr : [T], start : Nat, end : Nat) : [T] {
        var bufferArr = Buffer.Buffer<T>(end - start);
        var p = start;
        while (p < end) {
            bufferArr.add(arr[p]);
            p += 1;
        };
        bufferArr.toArray()
    };
    // push infinity logger to list head, return this infinity logger reference
    private func pushLogger () : async InfinityLogger {
        let infinityLogger = await IL.InfinityLogger();
        infinityLoggers := List.push(infinityLogger, infinityLoggers);
        infinityLogger
    };
    // get infinity logger by index
    private func getLogger (n : Nat) : async InfinityLogger {
        switch (List.get<InfinityLogger>(infinityLoggers, n)) {
            case (?x) x;
            case null {
                let infinityLogger = await pushLogger();
                Debug.print("No logger, create No." # debug_show(Nat.sub(List.size(infinityLoggers), 1)) # " logger canister");
                infinityLogger
            };
        }
    };
    /*
     * append messages array by order (old to new)
     * Problem with append: it will probably lead to a dead lock situation 
     *   when create multiple canisters as initiation. 
     * To avoid it, append first messages array with a size less then MAX_LOGGER_SIZE, 
     *   so that only one canister is created as initiation.
     */
    public func append (msgs : [Text]) : async () {
        var start : Nat = 0;
        var end : Nat = 0;
        var infinityLogger = await getLogger(0);
        let startSize = sizeOfTopLogger;
        while (start < msgs.size()) {
            if ((end + startSize) % MAX_LOGGER_SIZE == 0 and startSize != 0) {
                infinityLogger := await pushLogger();
                Debug.print("No." # debug_show(Nat.sub(List.size(infinityLoggers), 1)) # " logger canister was created");
                sizeOfTopLogger := 0;
            };
            end := Nat.min(start + MAX_LOGGER_SIZE - sizeOfTopLogger, msgs.size());
            await infinityLogger.append(subArr<Text>(msgs, start, end));
            let size = Nat.sub(end, start);
            totalSize += size;
            sizeOfTopLogger += size;
            start := end;
        };
    };
    // view messages by asc order (from old to new)
    public func view (from : Nat, to : Nat) : async Logger.View<Text> {
        let textBuffer = Buffer.Buffer<Text>(Nat.sub(to + 1, from));
        let totalLoggers = List.size(infinityLoggers);
        if (totalLoggers > 0) {
            let reverseFromLogger = Nat.max(from / MAX_LOGGER_SIZE, 0);
            let reverseToLogger = Nat.min(to / MAX_LOGGER_SIZE, totalLoggers - 1);
            let fromLogger = Nat.sub(totalLoggers - 1, reverseFromLogger);
            let toLogger = Nat.sub(totalLoggers - 1, reverseToLogger);
            for (loggerIndex in Iter.revRange(fromLogger, toLogger)) {
                let infinityLogger = await getLogger(Int.abs(loggerIndex));
                let f = if(loggerIndex == fromLogger) from % MAX_LOGGER_SIZE else 0;
                let t = if(loggerIndex == toLogger) to % MAX_LOGGER_SIZE else Nat.sub(MAX_LOGGER_SIZE, 1);
                let view = await infinityLogger.view(f, t);
                for (m in view.messages.vals()) {
                    textBuffer.add(m);
                };
            };
        };
        {
            start_index = Nat.max(from, 0);
            messages = textBuffer.toArray();
        }
    };
}
