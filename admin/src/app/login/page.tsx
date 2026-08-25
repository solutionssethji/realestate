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
        throw new Error(t('access_denied_privileges'));
      }

      // If agent is disabled, explicitly reject them
      if (agentSnap.exists() && !adminSnap.exists()) {
        const agentData = agentSnap.data();
        if (agentData.status !== "ACTIVE") {
          await signOut(auth);
          throw new Error(t('account_disabled_contact_admin'));
        }
      }

      // If agent is unverified — AuthContext will handle the dialog, just silently stop here
      if (agentSnap.exists() && !adminSnap.exists() && !userCredential.user.emailVerified) {
        setLoading(false);
        return;
      }

      // Unverified agents are handled in AuthContext's onAuthStateChanged — nothing to do here
      toast.success(t('login_successful'));
    } catch (err: any) {
      let friendlyMessage = err.message || t('login_failed_credentials');
      if (err.code === 'auth/invalid-credential' || err.code === 'auth/wrong-password' || err.code === 'auth/user-not-found') {
        friendlyMessage = t('incorrect_email_password');
      } else if (err.code === 'auth/too-many-requests') {
        friendlyMessage = t('too_many_failed_attempts');
      } else if (err.code === 'auth/network-request-failed') {
        friendlyMessage = t('network_error');
      }
      toast.error(friendlyMessage);
      setLoading(false);
    }
  }

  const handleResendVerification = async () => {
    setResendingMail(true);
    try {
      await resendVerificationEmail();
      toast.success(t('verification_email_sent'));
    } catch (error: any) {
      if (error.code === 'auth/too-many-requests') {
        toast.error(t('verification_email_too_many_requests'));
      } else {
        toast.error(error.message || t('verification_email_failed'));
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
              {t('welcome_back')}
            </h2>
            <p className="text-slate-500 text-sm mt-1">
              {t('sign_in_to_manage')}
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
                  {t('forgot_password')}
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
                    {t('sign_in')} <ArrowRight className="ml-2 h-4 w-4" />
                  </>
                )}
              </button>
            </div>
          </form>
        </div>

        {/* Footer */}
        <div className="mt-8 text-center">
          <p className="text-white/60 text-sm">
            &copy; {new Date().getFullYear()} {t('real_estate')}. {t('all_rights_reserved')}
          </p>
        </div>
      </div>

      <Modal
        isOpen={!!unverifiedFirebaseUser}
        onClose={clearUnverifiedFirebaseUser}
        title={t('email_verification_required')}
        maxWidth="md"
        footer={
          <div className="flex justify-end gap-3 w-full">
            <button
              onClick={clearUnverifiedFirebaseUser}
              className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded-lg transition-colors font-medium"
            >
              {t('cancel')}
            </button>
            <button
              onClick={handleResendVerification}
              disabled={resendingMail}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium flex items-center gap-2 disabled:opacity-50"
            >
              {resendingMail ? <Loader2 className="w-4 h-4 animate-spin" /> : <MailWarning className="w-4 h-4" />}
              {t('send_verification_mail')}
            </button>
          </div>
        }
      >
        <div className="py-4 text-slate-600">
          <div className="flex items-center justify-center w-16 h-16 bg-blue-50 rounded-full mb-4 mx-auto text-blue-600">
            <MailWarning className="w-8 h-8" />
          </div>
          <p className="text-center mb-4 text-slate-800 font-semibold text-lg">
            {t('account_not_verified')}
          </p>
          <p className="text-center text-sm">
            {t('agent_verification_reason')}
            <br /><br />
            {t('check_inbox_verification')}
          </p>
        </div>
      </Modal>

    </div>
  );
}
