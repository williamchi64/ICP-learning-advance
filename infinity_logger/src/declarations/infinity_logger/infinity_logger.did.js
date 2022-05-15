export const idlFactory = ({ IDL }) => {
  const View = IDL.Record({
    'messages' : IDL.Vec(IDL.Text),
    'start_index' : IDL.Nat,
  });
  return IDL.Service({
    'append' : IDL.Func([IDL.Vec(IDL.Text)], [], ['oneway']),
    'view' : IDL.Func([IDL.Nat, IDL.Nat], [IDL.Vec(View)], []),
  });
};
export const init = ({ IDL }) => { return []; };
