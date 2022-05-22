import type { Principal } from '@dfinity/principal';
export type List = [] | [[canister_id, List]];
export interface anon_class_10_1 {
  'canister_status' : (arg_0: bigint) => Promise<canister_status>,
  'create_canister' : () => Promise<canister_id>,
  'delete_canister' : (arg_0: bigint) => Promise<boolean>,
  'get_canisters' : () => Promise<List>,
  'install_code' : (
      arg_0: bigint,
      arg_1: Array<number>,
      arg_2: install_mode,
    ) => Promise<boolean>,
  'start_canister' : (arg_0: bigint) => Promise<boolean>,
  'stop_canister' : (arg_0: bigint) => Promise<boolean>,
}
export type canister_id = Principal;
export interface canister_status {
  'status' : { 'stopped' : null } |
    { 'stopping' : null } |
    { 'running' : null },
  'freezing_threshold' : bigint,
  'memory_size' : bigint,
  'cycles' : bigint,
  'settings' : definite_canister_settings,
  'module_hash' : [] | [Array<number>],
}
export interface definite_canister_settings {
  'freezing_threshold' : bigint,
  'controllers' : Array<Principal>,
  'memory_allocation' : bigint,
  'compute_allocation' : bigint,
}
export type install_mode = { 'reinstall' : null } |
  { 'upgrade' : null } |
  { 'install' : null };
export interface _SERVICE extends anon_class_10_1 {}
