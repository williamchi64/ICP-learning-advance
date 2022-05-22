import IC "ic";

module {
    public type ic = IC.Self;
    public type canister_id = IC.canister_id;
    public type canister_id_param = {canister_id : canister_id};
    public type canister_status = {
        status : { #stopped; #stopping; #running };
        freezing_threshold : Nat;
        memory_size : Nat;
        cycles : Nat;
        settings : IC.definite_canister_settings;
        module_hash : ?[Nat8];
        // idle_cycles_burned_per_second : Float;
    };
    public type install_mode = { #reinstall; #upgrade; #install };
    
}