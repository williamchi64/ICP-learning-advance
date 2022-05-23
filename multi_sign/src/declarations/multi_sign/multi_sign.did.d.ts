import type { Principal } from '@dfinity/principal';
export type CanisterId = Principal;
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
export type InstallMode = { 'reinstall' : null } |
  { 'upgrade' : null } |
  { 'install' : null };
export type List = [] | [[ProposalType, List]];
export type List_1 = [] | [[CanisterId, List_1]];
export interface ProposalOutput {
  'total_voter_total' : bigint,
  'total_voter_agree' : bigint,
  'voter_threshold' : bigint,
  'agree_proportion' : number,
  'proposal_type' : ProposalType,
}
export type ProposalType = { 'stop' : null } |
  { 'delete' : null } |
  { 'create' : null } |
  { 'start' : null } |
  { 'install' : null };
export type ProposalTypes = [] | [[ProposalType, List]];
export interface anon_class_15_1 {
  'canister_status' : (arg_0: bigint) => Promise<CanisterStatus>,
  'create_canister' : () => Promise<boolean>,
  'delete_canister' : (arg_0: bigint) => Promise<boolean>,
  'get_canisters' : () => Promise<List_1>,
  'get_proposals' : () => Promise<Array<[CanisterId, ProposalOutput]>>,
  'get_waiting_processes' : () => Promise<Array<[CanisterId, ProposalTypes]>>,
  'install_code' : (
      arg_0: bigint,
      arg_1: Array<number>,
      arg_2: InstallMode,
    ) => Promise<boolean>,
  'post_proposal' : (
      arg_0: [] | [bigint],
      arg_1: ProposalType,
      arg_2: [] | [bigint],
      arg_3: [] | [number],
    ) => Promise<boolean>,
  'start_canister' : (arg_0: bigint) => Promise<boolean>,
  'stop_canister' : (arg_0: bigint) => Promise<boolean>,
  'vote_proposal' : (arg_0: [] | [bigint], arg_1: boolean) => Promise<boolean>,
}
export interface definite_canister_settings {
  'freezing_threshold' : bigint,
  'controllers' : Array<Principal>,
  'memory_allocation' : bigint,
  'compute_allocation' : bigint,
}
export interface _SERVICE extends anon_class_15_1 {}
