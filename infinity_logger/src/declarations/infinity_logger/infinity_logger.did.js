export const idlFactory = ({ IDL }) => {
  const View = IDL.Record({
    'messages' : IDL.Vec(IDL.Text),
    'start_index' : IDL.Nat,
  });
  return IDL.Service({
    'append' : IDL.Func([IDL.Vec(IDL.Text)], [], []),
    'view' : IDL.Func([IDL.Nat, IDL.Nat], [View], []),
  });
};
export const init = ({ IDL }) => { return []; };
