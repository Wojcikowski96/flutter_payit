package com.example.payit;

import androidx.annotation.NonNull;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

class JavaDatabaseOperations {


    static void getUIDFromDB(String username, String email, CallbackFromFirebase callbackFromFirebase){

        String emailKey = email.replace(".","");

        Thread thread = new Thread(() -> FirebaseDatabase.getInstance().getReference().child("Users").child(username).child("myEmails").child(emailKey).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                int UID;
                try {
                    UID=snapshot.child("lastUID").getValue(int.class);
                } catch (Exception e) {
                    System.out.println("Java nie ma takiego rekordu, może masz pusty rekord z mailami?");
                    UID=0;
                }
                callbackFromFirebase.onCallback(UID);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        }));
        thread.start();
    }
}
