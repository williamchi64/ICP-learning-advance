import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import List "mo:base/List";

import T "type";
import F "func";

actor class () = self {

    stable var canister_ids : List.List<T.canister_id> = List.nil();

    let ic : T.ic = actor("aaaaa-aa");
    let default_canister_id : T.canister_id = Principal.fromActor(ic);

    private func get (n : Nat) : T.canister_id {
        F.get<T.canister_id>(n, canister_ids, default_canister_id)
    };
    private func remove (n : Nat) {
        canister_ids := F.remove(n, canister_ids);
    };
    // envoke function<Principal -> ()>, return bool determining success
    private func envoke (
        function : shared {canister_id : T.canister_id} -> async (),
        n : Nat
    ) : async Bool {
        try {
            await function({canister_id = get(n)});
        } catch (e) {
            Debug.print("Caught error: " # Error.message(e));
            return false;
        };
        true
    };
    public query func get_canisters () : async List.List<T.canister_id> {
        canister_ids
    };
    // create_canister
    public func create_canister () : async T.canister_id {
        let canister_settings = {
            settings = ?{
                controllers = ?[Principal.fromActor(self)];
                freezing_threshold = null;
                memory_allocation = null;
                compute_allocation = null;
            };
        };
        let result = await ic.create_canister(canister_settings);
        canister_ids := List.push(result.canister_id, canister_ids);
        result.canister_id
    };
    
    // install_code
    public func install_code (n : Nat, code : Blob, mode : T.install_mode) : async Bool {
        let code_settings = {
            canister_id = get(n);
            wasm_module = Blob.toArray(code);
            mode = #install;
            arg = [];
        };
        try {
            await ic.install_code(code_settings);
        } catch (e) {
            Debug.print("Caught error: " # Error.message(e));
            return false;
        };
        true
    };
    // start_canister
    public func start_canister (n : Nat) : async Bool {
        await envoke(ic.start_canister, n)
    };
    // stop_canister
    public func stop_canister (n : Nat) : async Bool {
        await envoke(ic.stop_canister, n)
    };
    // delete_canister
    public func delete_canister (n : Nat) : async Bool {
        let flag = await envoke(ic.delete_canister, n);
        if (flag)
            remove(n);
        flag
    };
    /* show canister status. A field - idle_cycles_burned_per_second : Float is ignored, 
     *   probably caused by the different environment with the main net
     */
    public func canister_status (n : Nat) : async T.canister_status {
        await ic.canister_status({ canister_id = get(n) })
    };
    
};