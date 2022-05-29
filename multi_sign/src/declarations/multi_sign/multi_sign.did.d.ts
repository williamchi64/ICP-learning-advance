import type { Principal } from '@dfinity/principal';
export type AssocList = [] | [[[Key, null], List_2]];
export interface Branch { 'left' : Trie, 'size' : bigint, 'right' : Trie }
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
export type Hash = number;
export type InstallMode = { 'reinstall' : null } |
  { 'upgrade' : null } |
  { 'install' : null };
export interface Key { 'key' : Principal, 'hash' : Hash }
export interface Leaf { 'size' : bigint, 'keyvals' : AssocList }
export type List = [] | [[ProposalType, List]];
export type List_1 = [] | [[Principal, List_1]];
export type List_2 = [] | [[[Key, null], List_2]];
export type List_3 = [] | [[CanisterId, List_3]];
export interface ProposalOutput {
  'total_voter_num' : bigint,
  'total_voter_agree' : bigint,
  'voter_total' : List_1,
  'voter_agree' : List_1,
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
export type Set = { 'branch' : Branch } |
  { 'leaf' : Leaf } |
  { 'empty' : null };
export type Trie = { 'branch' : Branch } |
  { 'leaf' : Leaf } |
  { 'empty' : null };
export interface anon_class_16_1 {
  'canister_status' : (arg_0: bigint) => Promise<CanisterStatus>,
  'create_canister' : (arg_0: [] | [bigint]) => Promise<boolean>,
  'delete_canister' : (arg_0: bigint) => Promise<boolean>,
  'get_canisters' : () => Promise<List_3>,
  'get_controllers' : () => Promise<Set>,
  'get_cycles' : () => Promise<bigint>,
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
  'register' : (arg_0: [] | [Principal]) => Promise<Principal>,
  'start_canister' : (arg_0: bigint) => Promise<boolean>,
  'stop_canister' : (arg_0: bigint) => Promise<boolean>,
  'unregister' : (arg_0: [] | [Principal]) => Promise<Principal>,
  'vote_proposal' : (
      arg_0: [] | [bigint],
      arg_1: boolean,
      arg_2: [] | [Principal],
    ) => Promise<boolean>,
}
export interface definite_canister_settings {
  'freezing_threshold' : bigint,
  'controllers' : Array<Principal>,
  'memory_allocation' : bigint,
  'compute_allocation' : bigint,
}
export interface _SERVICE extends anon_class_16_1 {}
