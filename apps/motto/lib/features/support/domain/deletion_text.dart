/// What "delete my data" does, said before it is done.
///
/// The counter line is not fine print. It is the one thing that survives, and
/// finding that out afterwards is how a deletion screen becomes a store
/// review.
const deletionGoes = [
  'Test cevapların',
  'Profil vektörün ve arketibin',
  'Aldığın mottolar',
];

const deletionStays = [
  'Cihaz kimliğin',
  'Kullandığın hak sayısı',
];

const deletionCounterReason =
    'Kullanım hakkı sayacı, suistimali önlemek için saklanır: silip yeniden '
    'yükleyerek hak kazanılamaz. Bu sayaç kim olduğunu değil, kaç kez '
    'kullandığını bilir.';

/// The chain never leaves the phone, so the server cannot delete it — and
/// someone who asked for everything to go would reasonably expect it to.
const deletionChainNote =
    'Zincirin ve hatırlatıcı ayarların zaten yalnızca bu telefonda; onlar da '
    'birlikte silinir.';
