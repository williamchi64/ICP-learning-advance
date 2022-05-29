# ICP-learning-advance
## multi_sign guide
test here: https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.ic0.app/?id=ece5y-kyaaa-aaaal-qa4bq-cai

canister id: ece5y-kyaaa-aaaal-qa4bq-cai

All processes (create canister; install code; start canister; stop canister; delete canister) to a canister are covered by authority management.

First of all, you need to gain the authority to use multi-sign manager by registeration of a principal.
3 pseudo callers are set as default voters for tesing:
-- ebffk-bwfav-ug43x-oxpjj-aqko7-e7n5l-2xrpg-twq5s-sjlib-pa6b4-sqe
-- to4yd-p3ipb-q2tlu-irxoc-f3gge-7losz-4mqnk-3kmd3-otdhw-nrjlp-aae
-- wlutc-kzlpm-qchz4-ucxeo-ktswb-jpea6-ocngv-di4oz-heqh4-qtwo7-vqe
For testing, anonymous caller is used to accomplish most processes, except voting-process which accept pseudo caller as controller to simulate multi-principal situation.
In release version, pseudo callers should be removed; the authority of register/unregister process should be limit to the owner.

To successfully accomplish a process, you need to start a proposal, then vote it to get a resolution. 
Each successful invocation will consume a resolution. 
-- [Post proposal -> Vote -> Process canister]
For convenience, canister_id is represented by index of a list.
You can get all canister ids and the order by get_canisters.

For proposal posting, the create process proposal mandatorily have no canister list index as one of the parameter; other process proposals mandatorily have a canister list index as one of the parameter.
Each canister can only have a proposal at the same time.
You can query proposal list by get_proposals.
Please finish previous proposal voting before starting a new one.

For voting, same to proposal posting, null as canister list index is used for create process voting.
Voting process resulting in false represet fail or voting; resulting in true represent success, and you gain a resolution stored in waiting process.
Fail or success of a proposal vote consume a proposal in the list.
Each canister can have multiple proposal type in waiting process list.
You can query waiting process list by get_waiting_processes.

To accomplish a canister process, you should have a corresponding proposal type in waiting process list which is consumed by a successful invocation.



