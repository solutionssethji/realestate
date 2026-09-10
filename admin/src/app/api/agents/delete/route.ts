import { NextRequest, NextResponse } from "next/server";
import { adminAuth, adminDb } from "@/lib/firebase-admin";

export async function DELETE(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const uid = searchParams.get("id");

    if (!uid) {
      return NextResponse.json({ error: "Missing agent ID" }, { status: 400 });
    }

    // Delete from Firebase Auth
    try {
      await adminAuth.deleteUser(uid);
      console.log(`Successfully deleted user ${uid} from Firebase Auth`);
    } catch (authError: any) {
      console.error(`Error deleting user ${uid} from Auth:`, authError);
      // We continue to delete from Firestore even if Auth deletion fails
      // (in case the user was already deleted from Auth manually)
    }

    // Delete from Firestore
    await adminDb.collection("agents").doc(uid).delete();
    console.log(`Successfully deleted agent ${uid} from Firestore`);

    return NextResponse.json({ success: true, message: "Agent deleted successfully" });
  } catch (error: any) {
    console.error("Error in delete agent API:", error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
