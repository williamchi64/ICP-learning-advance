import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

module {

    public class ArrayList<T> (init_array : ?[T]) {

        let DEFAULT_INIT_CAPACITY = 5;
        let MIN_CAPACITY = 5;
        let INCREASE_PROPORTION_DENOMINATOR = 2;

        var size : Nat = 0;
        var arr : [var ?T] = Array.init(DEFAULT_INIT_CAPACITY, null);

        switch (init_array) {
            case (?array) {
                size := array.size();
                arr := Array.tabulateVar<?T>(
                    Nat.max(array.size(), MIN_CAPACITY),
                    func (n : Nat) {
                        if (n < array.size()) ?array[n] 
                        else null
                    }
                );
            };
            case null {};
        };

        public func get_size () : Nat {
            size
        };

        public func freeze () : [T] {
            Array.tabulate<T>(
                size, 
                func (n : Nat) { get_unwrap(n) }
            )
        };

        public func get (n : Nat) : ?T {
            if (n < size) arr[n]
            else null
        };

        public func add (val : T) {
            if (size < arr.size()) {
                arr.put(size, ?val);
                size += 1;
            } else {
                expend(Nat.div(arr.size(), INCREASE_PROPORTION_DENOMINATOR));
                add(val);
            };
        };

        public func append (al : ArrayList<T>) {
            if (size + al.get_size() < arr.size()) {
                for (i in Iter.range(0, al.get_size() - 1)) {
                    arr.put(i + size, al.get(i));
                };
                size += al.get_size();
            } else {
                expend(Nat.div(arr.size(), INCREASE_PROPORTION_DENOMINATOR));
                append(al);
            };
        };

        public func put (n : Nat, val : T) {
            if (n < size) arr.put(n, ?val);
        };

        public func delete (n : Nat) {
            if (n >= size) return;
            shift_left(n, 1);
            size -= 1;
        };

        public func iter () : Iter.Iter<T> {
            Iter.fromArray(freeze())
        };

        private func get_unwrap (n : Nat) : T {
            switch (arr[n]) {
                case (?val) val;
                case null {
                    assert(false);
                    get_unwrap (0)
                };
            }
        };

        private func expend (expend_size : Nat) {
            arr := Array.tabulateVar<?T>(
                arr.size() + expend_size,
                func (n : Nat) { get(n) }
            );
        };

        private func shift_left (start : Nat, len : Nat) {
            for (i in Iter.range(start, size - 1 - len)) {
                arr[i] := arr[i + len];
            };
        };
    };

    public func map <T, R> (al : ArrayList<T>, f : T -> R) : ArrayList<R> {
        let result_arr = Array.map<T, R>(al.freeze(), f : T -> R);
        ArrayList<R>(?result_arr)
    };

}