import type { Principal } from '@dfinity/principal';
export interface View { 'messages' : Array<string>, 'start_index' : bigint }
export interface _SERVICE {
  'append' : (arg_0: Array<string>) => Promise<undefined>,
  'view' : (arg_0: bigint, arg_1: bigint) => Promise<Array<View>>,
}
