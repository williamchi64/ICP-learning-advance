export const idlFactory = ({ IDL }) => {
  const definite_canister_settings = IDL.Record({
    'freezing_threshold' : IDL.Nat,
    'controllers' : IDL.Vec(IDL.Principal),
    'memory_allocation' : IDL.Nat,
    'compute_allocation' : IDL.Nat,
  });
  const CanisterStatus = IDL.Record({
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
  const Error = IDL.Variant({
    'async_call_error' : IDL.Record({ 'msg' : IDL.Text }),
    'resolution_exception' : IDL.Record({ 'msg' : IDL.Text }),
    'register_exception' : IDL.Record({ 'msg' : IDL.Text }),
    'index_out_of_bound_error' : IDL.Record({ 'msg' : IDL.Text }),
    'proposal_exception' : IDL.Record({ 'msg' : IDL.Text }),
    'not_enough_cycle_exception' : IDL.Record({
      'msg' : IDL.Text,
      'cycle_limit' : IDL.Nat,
    }),
    'unknown_error' : IDL.Record({ 'msg' : IDL.Text }),
  });
  const Result_3 = IDL.Variant({ 'ok' : CanisterStatus, 'err' : Error });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Record({ 'msg' : IDL.Text }),
    'err' : Error,
  });
  const CanisterId = IDL.Principal;
  const ProposalStatus = IDL.Variant({
    'fail' : IDL.Null,
    'idle' : IDL.Null,
    'pass' : IDL.Null,
    'voting' : IDL.Null,
  });
  const InstallMode = IDL.Variant({
    'reinstall' : IDL.Null,
    'upgrade' : IDL.Null,
    'install' : IDL.Null,
  });
  const CanisterProposalType = IDL.Variant({
    'stop' : IDL.Null,
    'delete' : IDL.Null,
    'start' : IDL.Null,
    'install' : IDL.Record({
      'mode' : InstallMode,
      'wasm_code_sha256' : IDL.Opt(IDL.Vec(IDL.Nat8)),
      'wasm_code' : IDL.Vec(IDL.Nat8),
    }),
  });
  const ProposalOutput_1 = IDL.Record({
    'msg' : IDL.Opt(IDL.Text),
    'agree_voters' : IDL.Vec(IDL.Principal),
    'agree_threshold' : IDL.Nat,
    'voter_threshold' : IDL.Nat,
    'proposal_status' : ProposalStatus,
    'total_voters' : IDL.Vec(IDL.Principal),
    'proposal_type' : CanisterProposalType,
  });
  const Permission = IDL.Variant({
    'allowed' : IDL.Null,
    'disallowed' : IDL.Null,
  });
  const LockParamOuput = IDL.Record({
    'stop' : Permission,
    'delete' : Permission,
    'start' : Permission,
    'install' : Permission,
  });
  const CanisterOuput = IDL.Record({
    'id' : CanisterId,
    'resolutions' : IDL.Vec(ProposalOutput_1),
    'lock' : IDL.Variant({ 'lock' : LockParamOuput, 'unlock' : IDL.Null }),
    'proposals' : IDL.Vec(ProposalOutput_1),
  });
  const Result_2 = IDL.Variant({ 'ok' : CanisterOuput, 'err' : Error });
  const PublicProposalType = IDL.Variant({
    'lock' : IDL.Record({ 'n' : IDL.Nat }),
    'unregister' : IDL.Record({ 'identity' : IDL.Principal }),
    'unlock' : IDL.Record({ 'n' : IDL.Nat }),
    'create' : IDL.Record({ 'cycles' : IDL.Opt(IDL.Nat) }),
    'register' : IDL.Record({ 'identity' : IDL.Principal }),
  });
  const ProposalOutput = IDL.Record({
    'msg' : IDL.Opt(IDL.Text),
    'agree_voters' : IDL.Vec(IDL.Principal),
    'agree_threshold' : IDL.Nat,
    'voter_threshold' : IDL.Nat,
    'proposal_status' : ProposalStatus,
    'total_voters' : IDL.Vec(IDL.Principal),
    'proposal_type' : PublicProposalType,
  });
  const ProposalType = IDL.Variant({
    'canister_proposal' : CanisterProposalType,
    'public_proposal' : PublicProposalType,
  });
  const Result = IDL.Variant({ 'ok' : ProposalStatus, 'err' : Error });
  const anon_class_24_1 = IDL.Service({
    'canister_status' : IDL.Func([IDL.Nat], [Result_3], []),
    'delete_canister' : IDL.Func([IDL.Nat, IDL.Opt(IDL.Text)], [Result_1], []),
    'execute_resolution' : IDL.Func([IDL.Opt(IDL.Nat)], [Result_1], []),
    'get_canister' : IDL.Func([IDL.Nat], [Result_2], ['query']),
    'get_canisters' : IDL.Func([], [IDL.Vec(CanisterOuput)], ['query']),
    'get_controllers' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'get_cycles' : IDL.Func([], [IDL.Nat], ['query']),
    'get_old_canisters' : IDL.Func([], [IDL.Vec(CanisterId)], ['query']),
    'get_public_proposals' : IDL.Func([], [IDL.Vec(ProposalOutput)], ['query']),
    'get_public_resolutions' : IDL.Func(
        [],
        [IDL.Vec(ProposalOutput)],
        ['query'],
      ),
    'install_code' : IDL.Func(
        [IDL.Nat, IDL.Vec(IDL.Nat8), InstallMode, IDL.Opt(IDL.Text)],
        [Result_1],
        [],
      ),
    'post_proposal' : IDL.Func(
        [
          IDL.Opt(IDL.Nat),
          ProposalType,
          IDL.Opt(IDL.Text),
          IDL.Opt(IDL.Nat),
          IDL.Opt(IDL.Nat),
        ],
        [Result_1],
        [],
      ),
    'start_canister' : IDL.Func([IDL.Nat, IDL.Opt(IDL.Text)], [Result_1], []),
    'stop_canister' : IDL.Func([IDL.Nat, IDL.Opt(IDL.Text)], [Result_1], []),
    'vote' : IDL.Func(
        [IDL.Opt(IDL.Nat), IDL.Bool, IDL.Opt(IDL.Principal)],
        [Result],
        [],
      ),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
  return anon_class_24_1;
};
export const init = ({ IDL }) => { return []; };
