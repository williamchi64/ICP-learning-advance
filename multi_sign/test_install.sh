
import multi_sign = "rrkah-fqaaa-aaaaa-aaaaq-cai";
let test_file = file "greet.wasm";
call multi_sign.install_code (0, test_file, variant { install }, null);