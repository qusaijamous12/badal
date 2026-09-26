const fs = require('node:fs');
const assert = require('node:assert/strict');
const { initializeTestEnvironment, assertSucceeds, assertFails } = require('@firebase/rules-unit-testing');
const firebase = require('firebase/compat/app');
require('firebase/compat/firestore');

const stamp = () => firebase.firestore.FieldValue.serverTimestamp();
const image = firebase.firestore.Blob.fromUint8Array(new Uint8Array([1, 2, 3]));

function item(ownerId, title, category, wanted) {
  return {
    ownerId, ownerName: ownerId, title, description: 'وصف واضح وكاف للغرض',
    category, condition: 'جيدة', wanted, image,
    status: 'available', createdAt: stamp(),
  };
}

async function main() {
  const env = await initializeTestEnvironment({
    projectId: 'demo-badal',
    firestore: { rules: fs.readFileSync('firestore.rules', 'utf8') },
  });
  try {
    const owner = env.authenticatedContext('owner').firestore();
    const requester = env.authenticatedContext('requester').firestore();
    const stranger = env.authenticatedContext('stranger').firestore();
    await assertSucceeds(owner.doc('items/chair').set(item('owner', 'كرسي خشبي', 'أثاث', 'كتب')));
    await assertSucceeds(requester.doc('items/book').set(item('requester', 'كتاب تاريخ', 'كتب', 'أثاث')));
    await assertFails(stranger.doc('items/forged').set(item('owner', 'غرض مزيف', 'أثاث', 'كتب')));

    const offer = {
      targetItemId: 'chair', offeredItemId: 'book', targetTitle: 'كرسي خشبي',
      offeredTitle: 'كتاب تاريخ', ownerId: 'owner', requesterId: 'requester',
      ownerName: 'owner', requesterName: 'requester', status: 'pending', createdAt: stamp(),
    };
    await assertSucceeds(requester.doc('offers/swap').set(offer));
    await assertFails(stranger.doc('offers/swap').get());
    await assertSucceeds(owner.doc('offers/swap').get());
    await assertSucceeds(owner.collection('offers').where('ownerId', '==', 'owner').get());
    await assertSucceeds(requester.collection('offers').where('requesterId', '==', 'requester').get());
    await assertSucceeds(requester.doc('offers/swap/messages/hello').set({
      senderId: 'requester', body: 'مرحبًا، هل يناسبك التبادل؟', createdAt: stamp(),
    }));
    await assertFails(stranger.doc('offers/swap/messages/fake').set({
      senderId: 'stranger', body: 'رسالة', createdAt: stamp(),
    }));
    await assertFails(requester.doc('offers/swap').update({status: 'accepted'}));

    await assertSucceeds(owner.runTransaction(async (tx) => {
      const offerRef = owner.doc('offers/swap');
      const targetRef = owner.doc('items/chair');
      const offeredRef = owner.doc('items/book');
      await tx.get(offerRef);
      await tx.get(targetRef);
      await tx.get(offeredRef);
      tx.update(offerRef, { status: 'accepted' });
      tx.update(targetRef, { status: 'reserved', activeOfferId: 'swap' });
      tx.update(offeredRef, { status: 'reserved', activeOfferId: 'swap' });
    }));
    assert.equal((await owner.doc('items/book').get()).data().status, 'reserved');
    await assertFails(requester.doc('items/chair').update({title: 'تعديل غير مصرح'}));
    await assertSucceeds(owner.runTransaction(async (tx) => {
      const offerRef = owner.doc('offers/swap');
      const targetRef = owner.doc('items/chair');
      const offeredRef = owner.doc('items/book');
      await tx.get(offerRef);
      await tx.get(targetRef);
      await tx.get(offeredRef);
      tx.update(offerRef, {status: 'completed'});
      tx.update(targetRef, {status: 'exchanged', activeOfferId: 'swap'});
      tx.update(offeredRef, {status: 'exchanged', activeOfferId: 'swap'});
    }));
    assert.equal((await requester.doc('offers/swap').get()).data().status, 'completed');
    console.log('Firestore rules: ownership, offers, chat, atomic acceptance and completion passed.');
  } finally {
    await env.cleanup();
  }
}

main().catch((error) => { console.error(error); process.exitCode = 1; });
