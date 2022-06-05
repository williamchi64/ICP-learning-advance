import type { Principal } from '@dfinity/principal';
export type CanisterId = Principal;
export interface CanisterOuput {
  'id' : CanisterId,
  'resolutions' : Array<ProposalOutput_1>,
  'lock' : { 'lock' : LockParamOuput } |
    { 'unlock' : null },
  'proposals' : Array<ProposalOutput_1>,
}
export type CanisterProposalType = { 'stop' : null } |
  { 'delete' : null } |
  { 'start' : null } |
  {
    'install' : {
      'mode' : InstallMode,
      'wasm_code_sha256' : [] | [Array<number>],
      'wasm_code' : Array<number>,
    }
  };
export interface CanisterStatus {
  'status' : { 'stopped' : null } |
    { 'stopping' : null } |
    { 'running' : null },
  'freezing_threshold' : bigint,
  'memory_size' : bigint,
  'cycles' : bigint,
  'settings' : definite_canister_settings,
  'module_hash' : [] | [Array<number>],
}
export type Error = { 'async_call_error' : { 'msg' : string } } |
  { 'resolution_exception' : { 'msg' : string } } |
  { 'register_exception' : { 'msg' : string } } |
  { 'index_out_of_bound_error' : { 'msg' : string } } |
  { 'proposal_exception' : { 'msg' : string } } |
  {
    'not_enough_cycle_exception' : { 'msg' : string, 'cycle_limit' : bigint }
  } |
  { 'unknown_error' : { 'msg' : string } };
export type InstallMode = { 'reinstall' : null } |
  { 'upgrade' : null } |
  { 'install' : null };
export interface LockParamOuput {
  'stop' : Permission,
  'delete' : Permission,
  'start' : Permission,
  'install' : Permission,
}
export type Permission = { 'allowed' : null } |
  { 'disallowed' : null };
export interface ProposalOutput {
  'msg' : [] | [string],
  'agree_voters' : Array<Principal>,
  'agree_threshold' : bigint,
  'voter_threshold' : bigint,
  'proposal_status' : ProposalStatus,
  'total_voters' : Array<Principal>,
  'proposal_type' : PublicProposalType,
}
export interface ProposalOutput_1 {
  'msg' : [] | [string],
  'agree_voters' : Array<Principal>,
  'agree_threshold' : bigint,
  'voter_threshold' : bigint,
  'proposal_status' : ProposalStatus,
  'total_voters' : Array<Principal>,
  'proposal_type' : CanisterProposalType,
}
export type ProposalStatus = { 'fail' : null } |
  { 'idle' : null } |
  { 'pass' : null } |
  { 'voting' : null };
export type ProposalType = { 'canister_proposal' : CanisterProposalType } |
  { 'public_proposal' : PublicProposalType };
export type PublicProposalType = { 'lock' : { 'n' : bigint } } |
  { 'unregister' : { 'identity' : Principal } } |
  { 'unlock' : { 'n' : bigint } } |
  { 'create' : { 'cycles' : [] | [bigint] } } |
  { 'register' : { 'identity' : Principal } };
export type Result = { 'ok' : ProposalStatus } |
  { 'err' : Error };
export type Result_1 = { 'ok' : { 'msg' : string } } |
  { 'err' : Error };
export type Result_2 = { 'ok' : CanisterOuput } |
  { 'err' : Error };
export type Result_3 = { 'ok' : CanisterStatus } |
  { 'err' : Error };
export interface anon_class_24_1 {
  'canister_status' : (arg_0: bigint) => Promise<Result_3>,
  'delete_canister' : (arg_0: bigint, arg_1: [] | [string]) => Promise<
      Result_1
    >,
  'execute_resolution' : (arg_0: [] | [bigint]) => Promise<Result_1>,
  'get_canister' : (arg_0: bigint) => Promise<Result_2>,
  'get_canisters' : () => Promise<Array<CanisterOuput>>,
  'get_controllers' : () => Promise<Array<Principal>>,
  'get_cycles' : () => Promise<bigint>,
  'get_old_canisters' : () => Promise<Array<CanisterId>>,
  'get_public_proposals' : () => Promise<Array<ProposalOutput>>,
  'get_public_resolutions' : () => Promise<Array<ProposalOutput>>,
  'install_code' : (
      arg_0: bigint,
      arg_1: Array<number>,
      arg_2: InstallMode,
      arg_3: [] | [string],
    ) => Promise<Result_1>,
  'post_proposal' : (
      arg_0: [] | [bigint],
      arg_1: ProposalType,
      arg_2: [] | [string],
      arg_3: [] | [bigint],
      arg_4: [] | [bigint],
    ) => Promise<Result_1>,
  'start_canister' : (arg_0: bigint, arg_1: [] | [string]) => Promise<Result_1>,
  'stop_canister' : (arg_0: bigint, arg_1: [] | [string]) => Promise<Result_1>,
  'vote' : (
      arg_0: [] | [bigint],
      arg_1: boolean,
      arg_2: [] | [Principal],
    ) => Promise<Result>,
  'whoami' : () => Promise<Principal>,
}
export interface definite_canister_settings {
  'freezing_threshold' : bigint,
  'controllers' : Array<Principal>,
  'memory_allocation' : bigint,
  'compute_allocation' : bigint,
}
export interface _SERVICE extends anon_class_24_1 {}
