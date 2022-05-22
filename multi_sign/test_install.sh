import multi_sign = "rrkah-fqaaa-aaaaa-aaaaq-cai";
let test_file = file "greet.wasm";
let result = call multi_sign.install_code (0, test_file, variant { install });
result;
