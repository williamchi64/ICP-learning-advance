import Array "mo:base/Array";
import Float "mo:base/Float";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

module {

    public type ArrayList<T> = {
        default : T;
        size : Nat;
        arr : [T];
    };

    public class MutArrayList<T> (init_val : T, al : ?ArrayList<T>) {

        let DEFAULT_INIT_CAPACITY = 5;
        let INCREASE_PROPORTION_DENOMINATOR = 2;

        var default : T = init_val;
        var size : Nat = switch (al) {
            case (?al) al.size;
            case null 0;
        };
        var arr : [var T] = switch (al) {
            case (?al) Array.thaw(al.arr);
            case null Array.init(DEFAULT_INIT_CAPACITY, init_val);
        };

        public func get_default () : T {
            default
        };

        public func get_size () : Nat {
            size
        };

        public func freeze () : ArrayList<T> {
            {
                default = default;
                size = size;
                arr = Array.freeze(arr);
            }
        };

        public func get (n : Nat) : ?T {
            if (n < size)
                ?arr[n]
            else
                null
        };

        public func get_unwrap (n : Nat) : T {
            arr[n]
        };

        public func add (val : T) {
            if (size < arr.size()) {
                arr.put(size, val);
                size += 1;
            } else {
                expend(Nat.div(arr.size(), INCREASE_PROPORTION_DENOMINATOR));
                add(val);
            };
        };

        public func append (mal : MutArrayList<T>) {
            if (size + mal.get_size() < arr.size()) {
                for (i in Iter.range(0, mal.get_size() - 1)) {
                    arr.put(i + size, mal.get_unwrap(i));
                };
                size += mal.get_size();
            } else {
                expend(Nat.div(arr.size(), INCREASE_PROPORTION_DENOMINATOR));
                append(mal);
            };
        };

        public func put (n : Nat, val : T) {
            if (n < size)
                arr.put(n, val);
        };

        public func delete (n : Nat) {
            if (n >= size) return;
            shift_left(n, 1);
            size -= 1;
        };

        public func iter () : Iter.Iter<T> {
            var n = 0;
            Iter.filter<T>(Iter.fromArrayMut(arr), func(val : T) {
                let flag = (n < size);
                n += 1;
                flag
            })
        };

        private func expend (expend_size : Nat) {
            arr := Array.tabulateVar<T>(arr.size() + expend_size, func (n : Nat) {
                switch (get(n)) {
                    case (?val) val;
                    case null default;
                }
            });
        };

        private func shift_left (start : Nat, len : Nat) {
            for (i in Iter.range(start, size - 1 - len)) {
                arr[i] := arr[i + len];
            };
        };
    };

    public func thaw<T> (al : ArrayList<T>) : MutArrayList<T> {
        MutArrayList<T>(al.default, ?al)
    };

    public func map<T, R> (mal : MutArrayList<T>, default : R, f : T -> R) : MutArrayList<R> {
        let result = MutArrayList<R>(default, null);
        for (val in mal.iter()) {
            result.add(f(val));
        };
        result
    };

}