# test install code of the canister on ic mainnet
import multi_sign = "ece5y-kyaaa-aaaal-qa4bq-cai";
let test_file = file "greet.wasm";
call multi_sign.register(null);
call multi_sign.install_code (0, test_file, variant { install });