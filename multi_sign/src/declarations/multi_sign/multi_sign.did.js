export const idlFactory = ({ IDL }) => {
  const Branch = IDL.Rec();
  const List = IDL.Rec();
  const List_1 = IDL.Rec();
  const List_2 = IDL.Rec();
  const List_3 = IDL.Rec();
  const List_4 = IDL.Rec();
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
  const CanisterId = IDL.Principal;
  List_4.fill(IDL.Opt(IDL.Tuple(CanisterId, List_4)));
  List_1.fill(IDL.Opt(IDL.Tuple(IDL.Principal, List_1)));
  const CreateParam = IDL.Record({ 'cycles' : IDL.Nat });
  const InstallMode = IDL.Variant({
    'reinstall' : IDL.Null,
    'upgrade' : IDL.Null,
    'install' : IDL.Null,
  });
  const InstallParam = IDL.Record({
    'mode' : InstallMode,
    'wasm_code_sha256' : IDL.Vec(IDL.Nat8),
    'wasm_code' : IDL.Vec(IDL.Nat8),
  });
  const ProposalTypeUpdate = IDL.Variant({
    'stop' : IDL.Null,
    'delete' : IDL.Null,
    'create' : CreateParam,
    'start' : IDL.Null,
    'install' : InstallParam,
  });
  const ProposalOutputUpdate = IDL.Record({
    'agree_voters' : List_1,
    'total_voter_num' : IDL.Nat,
    'total_agree_num' : IDL.Nat,
    'voter_threshold' : IDL.Nat,
    'total_voters' : List_1,
    'agree_proportion' : IDL.Record({
      'numerator' : IDL.Nat,
      'denominator' : IDL.Nat,
    }),
    'proposal_type' : ProposalTypeUpdate,
  });
  List_3.fill(IDL.Opt(IDL.Tuple(ProposalOutputUpdate, List_3)));
  const List__1 = IDL.Opt(IDL.Tuple(ProposalOutputUpdate, List_3));
  const Deque = IDL.Tuple(List__1, List__1);
  const CanisterOuputUpdate = IDL.Record({
    'id' : CanisterId,
    'lock' : IDL.Variant({
      'lock' : IDL.Record({
        'stop' : IDL.Bool,
        'delete' : IDL.Bool,
        'start' : IDL.Bool,
        'install' : IDL.Bool,
      }),
      'unlock' : IDL.Null,
    }),
    'proposals' : Deque,
  });
  const Hash = IDL.Nat32;
  const Key = IDL.Record({ 'key' : IDL.Principal, 'hash' : Hash });
  List_2.fill(IDL.Opt(IDL.Tuple(IDL.Tuple(Key, IDL.Null), List_2)));
  const AssocList = IDL.Opt(IDL.Tuple(IDL.Tuple(Key, IDL.Null), List_2));
  const Leaf = IDL.Record({ 'size' : IDL.Nat, 'keyvals' : AssocList });
  const Trie = IDL.Variant({
    'branch' : Branch,
    'leaf' : Leaf,
    'empty' : IDL.Null,
  });
  Branch.fill(IDL.Record({ 'left' : Trie, 'size' : IDL.Nat, 'right' : Trie }));
  const Set = IDL.Variant({
    'branch' : Branch,
    'leaf' : Leaf,
    'empty' : IDL.Null,
  });
  const ProposalType = IDL.Variant({
    'stop' : IDL.Null,
    'delete' : IDL.Null,
    'create' : IDL.Null,
    'start' : IDL.Null,
    'install' : IDL.Null,
  });
  const ProposalOutput = IDL.Record({
    'total_voter_num' : IDL.Nat,
    'total_voter_agree' : IDL.Nat,
    'voter_total' : List_1,
    'voter_agree' : List_1,
    'voter_threshold' : IDL.Nat,
    'agree_proportion' : IDL.Float64,
    'proposal_type' : ProposalType,
  });
  List.fill(IDL.Opt(IDL.Tuple(ProposalType, List)));
  const ProposalTypes = IDL.Opt(IDL.Tuple(ProposalType, List));
  const anon_class_20_1 = IDL.Service({
    'canister_status' : IDL.Func([IDL.Nat], [CanisterStatus], []),
    'create_canister' : IDL.Func([IDL.Opt(IDL.Nat)], [IDL.Bool], []),
    'delete_canister' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'get_canisters' : IDL.Func([], [List_4], ['query']),
    'get_canisters_update' : IDL.Func(
        [],
        [IDL.Vec(CanisterOuputUpdate)],
        ['query'],
      ),
    'get_controllers' : IDL.Func([], [Set], ['query']),
    'get_cycles' : IDL.Func([], [IDL.Nat], ['query']),
    'get_proposals' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(CanisterId, ProposalOutput))],
        ['query'],
      ),
    'get_waiting_processes' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(CanisterId, ProposalTypes))],
        ['query'],
      ),
    'install_code' : IDL.Func(
        [IDL.Nat, IDL.Vec(IDL.Nat8), InstallMode],
        [IDL.Bool],
        [],
      ),
    'post_proposal' : IDL.Func(
        [
          IDL.Opt(IDL.Nat),
          ProposalType,
          IDL.Opt(IDL.Nat),
          IDL.Opt(IDL.Float64),
        ],
        [IDL.Bool],
        [],
      ),
    'register' : IDL.Func([IDL.Opt(IDL.Principal)], [IDL.Principal], []),
    'start_canister' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'stop_canister' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'unregister' : IDL.Func([IDL.Opt(IDL.Principal)], [IDL.Principal], []),
    'vote_proposal' : IDL.Func(
        [IDL.Opt(IDL.Nat), IDL.Bool, IDL.Opt(IDL.Principal)],
        [IDL.Bool],
        [],
      ),
  });
  return anon_class_20_1;
};
export const init = ({ IDL }) => { return []; };
