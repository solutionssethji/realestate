/* eslint-disable react-hooks/immutability */
"use client";

import { useState } from "react";
import Link from "next/link";
import { Loader2, CheckCircle2, ArrowRight } from "lucide-react";
import { useLanguage } from '@/context/LanguageContext';
import { toast } from 'react-hot-toast';
import { findAdminOrAgentByEmail, normalizeEmail } from '@/lib/firebase';

export default function ForgotPasswordPage() {
  const { t } = useLanguage();
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);

    try {
      const { sendPasswordResetEmail } = await import("firebase/auth");
      const { auth } = await import("@/lib/firebase");

      const normalizedEmail = normalizeEmail(email);
      const adminOrAgent = await findAdminOrAgentByEmail(normalizedEmail);

      if (!adminOrAgent) {
        toast.error(t('invalid_email_id'));
        return;
      }

      await sendPasswordResetEmail(auth, normalizedEmail);
      setSuccess(true);
    } catch (err: any) {
      let friendlyMessage = t('something_went_wrong_email');
      if (
        err.code === 'permission-denied' ||
        err.code === 'firestore/permission-denied' ||
        err.message?.includes('Missing or insufficient permissions')
      ) {
        friendlyMessage = t('invalid_email_id');
      } else if (err.code === 'auth/invalid-email') {
        friendlyMessage = t('invalid_email_id');
      } else if (err.code === 'auth/user-not-found') {
        friendlyMessage = t('invalid_email_id');
      } else if (err.code === 'auth/too-many-requests') {
        friendlyMessage = t('too_many_failed_attempts');
      } else if (err.code === 'auth/network-request-failed') {
        friendlyMessage = t('network_error');
      }
      toast.error(friendlyMessage);
    } finally {
      setLoading(false);
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

      {/* Glassmorphic Container */}
      <div className="relative z-10 w-full max-w-md px-4 sm:px-0">
        <div className="backdrop-blur-xl bg-white/90 p-8 sm:p-10 shadow-2xl rounded-3xl border border-white/20">

          <div className="flex flex-col items-center mb-8">
            <div className="mb-6">
              <img src="/logo_with_text.png" alt="SHUBHAYTANAM CONNECT" className="h-24 w-auto object-contain" />
            </div>
            <h2 className="text-2xl font-bold text-slate-900 tracking-tight">
              {t('forgot_password_title')}
            </h2>
            {!success && (
              <p className="text-slate-500 text-sm mt-1 text-center">
                {t('enter_email_to_reset')}
              </p>
            )}
          </div>

          {success ? (
            <div className="text-center animate-in fade-in slide-in-from-bottom-2">
              <div className="flex justify-center mb-4">
                <div className="bg-emerald-100 p-3 rounded-full">
                  <CheckCircle2 className="h-10 w-10 text-emerald-600" />
                </div>
              </div>
              <h3 className="text-xl font-bold text-slate-900">{t('reset_link_sent')}</h3>
              <p className="mt-2 text-sm text-slate-500">
                {t('reset_link_sent_desc')}
              </p>
              <div className="mt-8">
                <Link
                  href="/login"
                  className="w-full flex justify-center items-center py-3.5 px-4 border border-transparent rounded-xl shadow-lg shadow-blue-600/20 text-sm font-bold text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200 transform hover:-translate-y-0.5"
                >
                  Return to Login <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </div>
            </div>
          ) : (
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

              <div className="pt-2">
                <button
                  type="submit"
                  disabled={loading || !email}
                  className="w-full flex justify-center items-center py-3.5 px-4 border border-transparent rounded-xl shadow-lg shadow-blue-600/20 text-sm font-bold text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-70 disabled:cursor-not-allowed transition-all duration-200 transform hover:-translate-y-0.5 active:translate-y-0"
                >
                  {loading ? (
                    <Loader2 className="h-5 w-5 animate-spin" />
                  ) : (
                    t('send_reset_link')
                  )}
                </button>
              </div>

              <div className="text-center pt-2">
                <Link href="/login" className="text-sm font-medium text-slate-500 hover:text-slate-800 transition-colors">
                  {t('nevermind_back_to_login')}
                </Link>
              </div>
            </form>
          )}
        </div>

        {/* Footer */}
        <div className="mt-8 text-center">
          <p className="text-white/60 text-sm">
            &copy; {new Date().getFullYear()} {t('real_estate')}. {t('all_rights_reserved')}
          </p>
        </div>
      </div>
    </div>
  );
}
