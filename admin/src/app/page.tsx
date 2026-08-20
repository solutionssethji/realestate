/* eslint-disable react-hooks/immutability */
import { redirect } from "next/navigation";

export default function Home() {
  // Automatically redirect the root URL to the dashboard
  // The AuthContext layout will handle kicking them to /login if they aren't authenticated
  redirect("/login");
}
