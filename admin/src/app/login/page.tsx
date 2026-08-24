"use client";

import { useState } from "react";
import { useAuth } from "@/context/AuthContext";
import Link from "next/link";
import { toast } from "react-hot-toast";
import { Loader2, Eye, EyeOff, ArrowRight, MailWarning } from "lucide-react";
import { useLanguage } from '@/context/LanguageContext';
import { normalizeEmail } from '@/lib/firebase';
import { Modal } from "@/components/ui/Modal";

export default function LoginPage() {
  const { t } = useLanguage();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [resendingMail, setResendingMail] = useState(false);

  const {
    unverifiedFirebaseUser,
    clearUnverifiedFirebaseUser,
    resendVerificationEmail,
  } = useAuth();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);

    try {
      const { signInWithEmailAndPassword, signOut } = await import("firebase/auth");
      const { doc, getDoc } = await import("firebase/firestore");
      const { auth, db } = await import("@/lib/firebase");

      const normalizedEmail = normalizeEmail(email);
      const userCredential = await signInWithEmailAndPassword(auth, normalizedEmail, password);

      const adminRef = doc(db, "admins", userCredential.user.uid);
      const adminSnap = await getDoc(adminRef);
      const agentRef = doc(db, "agents", userCredential.user.uid);
      const agentSnap = await getDoc(agentRef);

      if (!adminSnap.exists() && !agentSnap.exists()) {
        await signOut(auth);
        throw new Error("Access denied. You do not have admin or agent privileges.");
      }

      // If agent is disabled, explicitly reject them
      if (agentSnap.exists() && !adminSnap.exists()) {
        const agentData = agentSnap.data();
        if (agentData.status !== "ACTIVE") {
          await signOut(auth);
          throw new Error("Your account has been disabled. Please contact the administrator.");
        }
      }

      // If agent is unverified — AuthContext will handle the dialog, just silently stop here
      if (agentSnap.exists() && !adminSnap.exists() && !userCredential.user.emailVerified) {
        setLoading(false);
        return;
      }

      // Unverified agents are handled in AuthContext's onAuthStateChanged — nothing to do here
      toast.success("Login successful!");
    } catch (err: any) {
      let friendlyMessage = err.message || "Login failed. Please check your credentials.";
      if (err.code === 'auth/invalid-credential' || err.code === 'auth/wrong-password' || err.code === 'auth/user-not-found') {
        friendlyMessage = "Incorrect email or password. Please try again.";
      } else if (err.code === 'auth/too-many-requests') {
        friendlyMessage = "Too many failed attempts. Please try again later.";
      } else if (err.code === 'auth/network-request-failed') {
        friendlyMessage = "Network error. Please check your internet connection.";
      }
      toast.error(friendlyMessage);
      setLoading(false);
    }
  }

  const handleResendVerification = async () => {
    setResendingMail(true);
    try {
      await resendVerificationEmail();
      toast.success("Verification email sent! Please check your inbox and spam folder.");
    } catch (error: any) {
      if (error.code === 'auth/too-many-requests') {
        toast.error("Too many requests. Please wait a few minutes before trying again.");
      } else {
        toast.error(error.message || "Failed to send verification email.");
      }
    } finally {
      setResendingMail(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden bg-slate-900">
      {/* Premium Background Image with Overlay */}
      <div
        className="absolute inset-0 z-0 bg-cover bg-center"
        style={{ backgroundImage: 'url("https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=2075&auto=format&fit=crop")' }}
      >
        <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-[2px]"></div>
        <div className="absolute inset-0 bg-gradient-to-t from-slate-900 via-transparent to-transparent"></div>
      </div>

      {/* Glassmorphic Login Container */}
      <div className="relative z-10 w-full max-w-md px-4 sm:px-0">
        <div className="backdrop-blur-xl bg-white/90 p-8 sm:p-10 shadow-2xl rounded-3xl border border-white/20">

          <div className="flex flex-col items-center mb-8">
            <div className="mb-6">
              <img src="/logo_with_text.png" alt="SHUBHAYTANAM CONNECT" className="h-24 w-auto object-contain" />
            </div>
            <h2 className="text-2xl font-bold text-slate-900 tracking-tight">
              Welcome Back
            </h2>
            <p className="text-slate-500 text-sm mt-1">
              Sign in to manage your Shubhaytanam Connect portfolio
            </p>
          </div>

          <form className="space-y-5" onSubmit={handleSubmit}>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">{t('email_address')}</label>
              <div className="relative">
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="block w-full px-4 py-3 bg-white/50 border border-slate-200 rounded-xl text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 shadow-sm"
                  placeholder="admin@example.com"
                />
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="block text-sm font-semibold text-slate-700">{t('password')}</label>
                <Link href="/forgot-password" className="text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors">
                  Forgot password?
                </Link>
              </div>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full px-4 py-3 bg-white/50 border border-slate-200 rounded-xl text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 shadow-sm pr-12"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-4 flex items-center text-slate-400 hover:text-slate-600 transition-colors"
                >
                  {showPassword ? (
                    <EyeOff className="h-5 w-5" aria-hidden="true" />
                  ) : (
                    <Eye className="h-5 w-5" aria-hidden="true" />
                  )}
                </button>
              </div>
            </div>

            <div className="pt-2">
              <button
                type="submit"
                disabled={loading}
                className="w-full flex justify-center items-center py-3.5 px-4 border border-transparent rounded-xl shadow-lg shadow-blue-600/20 text-sm font-bold text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-70 disabled:cursor-not-allowed transition-all duration-200 transform hover:-translate-y-0.5 active:translate-y-0"
              >
                {loading ? (
                  <Loader2 className="h-5 w-5 animate-spin" />
                ) : (
                  <>
                    Sign In <ArrowRight className="ml-2 h-4 w-4" />
                  </>
                )}
              </button>
            </div>
          </form>
        </div>

        {/* Footer */}
        <div className="mt-8 text-center">
          <p className="text-white/60 text-sm">
            &copy; {new Date().getFullYear()} {t('real_estate')}. All rights reserved.
          </p>
        </div>
      </div>

      <Modal
        isOpen={!!unverifiedFirebaseUser}
        onClose={clearUnverifiedFirebaseUser}
        title="Email Verification Required"
        maxWidth="md"
        footer={
          <div className="flex justify-end gap-3 w-full">
            <button
              onClick={clearUnverifiedFirebaseUser}
              className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded-lg transition-colors font-medium"
            >
              Cancel
            </button>
            <button
              onClick={handleResendVerification}
              disabled={resendingMail}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium flex items-center gap-2 disabled:opacity-50"
            >
              {resendingMail ? <Loader2 className="w-4 h-4 animate-spin" /> : <MailWarning className="w-4 h-4" />}
              Send Verification Mail
            </button>
          </div>
        }
      >
        <div className="py-4 text-slate-600">
          <div className="flex items-center justify-center w-16 h-16 bg-blue-50 rounded-full mb-4 mx-auto text-blue-600">
            <MailWarning className="w-8 h-8" />
          </div>
          <p className="text-center mb-4 text-slate-800 font-semibold text-lg">
            Your account is not verified yet.
          </p>
          <p className="text-center text-sm">
            For security reasons, agents must verify their email address before accessing the dashboard.
            <br /><br />
            Please check your inbox (and spam folder) for a verification link, or click below to receive a new one. Once verified, you can log in.
          </p>
        </div>
      </Modal>

    </div>
  );
}
