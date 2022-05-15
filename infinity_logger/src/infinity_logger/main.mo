import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import IL "InfinityLogger";
import Logger "mo:ic-logger/Logger";
import Nat "mo:base/Int";

actor {
    type InfinityLogger = IL.InfinityLogger;
    stable var size: Nat = 0;
    stable var infinityLoggers:[InfinityLogger] = [];
    let bucketSize = 3;
    public shared func append(msgs: [Text]) {
        let prevSize = infinityLoggers.size();
        if ((size + msgs.size()) / bucketSize >= prevSize) {
            var bufferLoggers = Buffer.Buffer<InfinityLogger>(prevSize);
            var i: Nat = 0;
            while(i < prevSize) {
                bufferLoggers.add(infinityLoggers[i]);
                i+=1;
            };
            i := (size + msgs.size()) / bucketSize - prevSize + 1;
            while (i > 0) {
                let infinityLogger:InfinityLogger = await IL.InfinityLogger();
                bufferLoggers.add(infinityLogger);
                i-=1;
            };
            infinityLoggers := bufferLoggers.toArray();
        };
        let nowSize = infinityLoggers.size();
        var p: Nat = prevSize;
        var l = 0;
        while (p < nowSize) {
            var size: Nat = await infinityLoggers[p].size();
            if (size < bucketSize) {
                infinityLoggers[p].append(subarr<Text>(msgs, l, l+bucketSize-size));
            };
            l := l+bucketSize-size;
            p+=1;
        };
    };
    public shared func view(from: Nat, to: Nat) : async [Logger.View<Text>] {
        let start: Nat = from / bucketSize;
        let end: Nat = to / bucketSize + 1;
        var results = Buffer.Buffer<Logger.View<Text>>(1);
        var p = start;
        while (p < end) {
            var l = 0;
            var r = bucketSize;
            if (p == start) {
                l := start;
            };
            if (p == Nat.sub(end, 1)) {
                r := end;
            };
            let logger = infinityLoggers[p];
            let result = await logger.view(l,r);
            results.add(result);
            p+=1;
        };
        results.toArray()
    };
    private func subarr<T>(arr: [T], start: Nat, end: Nat): [T] {
        var bufferArr = Buffer.Buffer<T>(1);
        var p = start;
        while (p < end) {
            bufferArr.add(arr[start]);
            p += 1;
        };
        bufferArr.toArray();
    }
}
