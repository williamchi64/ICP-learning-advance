export const idlFactory = ({ IDL }) => {
  const List = IDL.Rec();
  const definite_canister_settings = IDL.Record({
    'freezing_threshold' : IDL.Nat,
    'controllers' : IDL.Vec(IDL.Principal),
    'memory_allocation' : IDL.Nat,
    'compute_allocation' : IDL.Nat,
  });
  const canister_status = IDL.Record({
    'status' : IDL.Variant({
      'stopped' : IDL.Null,
      'stopping' : IDL.Null,
      'running' : IDL.Null,
    }),
    'freezing_threshold' : IDL.Nat,
    'memory_size' : IDL.Nat,
    'cycles' : IDL.Nat,
    'settings' : definite_canister_settings,
    'module_hash' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const canister_id = IDL.Principal;
  List.fill(IDL.Opt(IDL.Tuple(canister_id, List)));
  const install_mode = IDL.Variant({
    'reinstall' : IDL.Null,
    'upgrade' : IDL.Null,
    'install' : IDL.Null,
  });
  const anon_class_10_1 = IDL.Service({
    'canister_status' : IDL.Func([IDL.Nat], [canister_status], []),
    'create_canister' : IDL.Func([], [canister_id], []),
    'delete_canister' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'get_canisters' : IDL.Func([], [List], ['query']),
    'install_code' : IDL.Func(
        [IDL.Nat, IDL.Vec(IDL.Nat8), install_mode],
        [IDL.Bool],
        [],
      ),
    'start_canister' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'stop_canister' : IDL.Func([IDL.Nat], [IDL.Bool], []),
  });
  return anon_class_10_1;
};
export const init = ({ IDL }) => { return []; };
