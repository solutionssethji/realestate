"use client";

import { useState } from "react";
import { useAuth } from "@/context/AuthContext";
import { auth } from "@/lib/firebase";
import { EmailAuthProvider, reauthenticateWithCredential, updatePassword } from "firebase/auth";
import { toast } from "react-hot-toast";
import { Lock, Save, Loader2, Eye, EyeOff } from "lucide-react";
import { validateStrongPassword } from "@/lib/validators";
import { useLanguage } from '@/context/LanguageContext';

export default function ChangePasswordPage() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  const [newPasswordError, setNewPasswordError] = useState<string | null>(null);
  const [confirmPasswordError, setConfirmPasswordError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!auth.currentUser || !user?.email) return;

    // Final validation before submit
    const strengthError = validateStrongPassword(newPassword);
    if (strengthError) {
      setNewPasswordError(strengthError);
      return;
    }
    if (newPassword !== confirmPassword) {
      setConfirmPasswordError(t('passwords_do_not_match'));
      return;
    }

    setLoading(true);
    try {
      const credential = EmailAuthProvider.credential(user.email, currentPassword);
      await reauthenticateWithCredential(auth.currentUser, credential);
      await updatePassword(auth.currentUser, newPassword);

      toast.success(t('password_updated'));
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
      setNewPasswordError(null);
      setConfirmPasswordError(null);
    } catch (err: any) {
      console.error(err);
      if (err.code === "auth/invalid-credential") {
        toast.error(t('incorrect_current_password'));
      } else {
        toast.error(err.message || t('failed_update_password'));
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-3 mb-6">
        <div className="p-2 bg-blue-100 text-blue-600 rounded-lg">
          <Lock className="w-6 h-6" />
        </div>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">{t('change_password_page_title')}</h1>
          <p className="text-gray-500 text-sm">{t('change_password_subtitle')}</p>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <form onSubmit={handleSubmit} className="p-6 space-y-6">

          {/* Current Password */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('current_password')}
            </label>
            <div className="relative">
              <input
                type={showCurrent ? "text" : "password"}
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                required
                className="w-full px-4 py-2 pr-11 bg-gray-50 border border-gray-200 rounded-lg focus:bg-white focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all outline-none"
                placeholder={t('enter_current_password')}
              />
              <button
                type="button"
                onClick={() => setShowCurrent(!showCurrent)}
                className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600 transition-colors"
              >
                {showCurrent ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
              </button>
            </div>
          </div>

          {/* New Password */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('new_password')}
            </label>
            <div className="relative">
              <input
                type={showNew ? "text" : "password"}
                value={newPassword}
                onChange={(e) => {
                  const val = e.target.value;
                  setNewPassword(val);
                  setNewPasswordError(val ? validateStrongPassword(val) : null);
                  if (confirmPassword && val !== confirmPassword) {
                    setConfirmPasswordError(t('passwords_do_not_match'));
                  } else if (confirmPassword && val === confirmPassword) {
                    setConfirmPasswordError(null);
                  }
                }}
                onBlur={() => setNewPasswordError(newPassword ? validateStrongPassword(newPassword) : null)}
                required
                className={`w-full px-4 py-2 pr-11 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all outline-none ${newPasswordError ? "border-red-300 bg-red-50" : "bg-gray-50 border-gray-200 focus:bg-white"
                  }`}
                placeholder={t('enter_new_password')}
              />
              <button
                type="button"
                onClick={() => setShowNew(!showNew)}
                className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600 transition-colors"
              >
                {showNew ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
              </button>
            </div>
            {newPasswordError && <p className="mt-1.5 text-sm text-red-600">{newPasswordError}</p>}
          </div>

          {/* Confirm Password */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('confirm_new_password')}
            </label>
            <div className="relative">
              <input
                type={showConfirm ? "text" : "password"}
                value={confirmPassword}
                onChange={(e) => {
                  const val = e.target.value;
                  setConfirmPassword(val);
                  if (!val) setConfirmPasswordError(t('confirm_new_password'));
                  else if (val !== newPassword) setConfirmPasswordError(t('passwords_do_not_match'));
                  else setConfirmPasswordError(null);
                }}
                onBlur={() => {
                  if (!confirmPassword) setConfirmPasswordError(t('confirm_new_password'));
                  else if (confirmPassword !== newPassword) setConfirmPasswordError(t('passwords_do_not_match'));
                }}
                required
                className={`w-full px-4 py-2 pr-11 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all outline-none ${confirmPasswordError ? "border-red-300 bg-red-50" : "bg-gray-50 border-gray-200 focus:bg-white"
                  }`}
                placeholder={t('confirm_new_password_placeholder')}
              />
              <button
                type="button"
                onClick={() => setShowConfirm(!showConfirm)}
                className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600 transition-colors"
              >
                {showConfirm ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
              </button>
            </div>
            {confirmPasswordError && <p className="mt-1.5 text-sm text-red-600">{confirmPasswordError}</p>}
          </div>

          {/* Password Requirements */}
          <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100">
            <p className="text-sm text-blue-800 font-medium mb-1">{t('password_requirements')}</p>
            <ul className="text-xs text-blue-600/80 list-disc list-inside space-y-0.5">
              <li>{t('password_req_length')}</li>
              <li>{t('password_req_case')}</li>
              <li>{t('password_req_special')}</li>
            </ul>
          </div>

          <div className="pt-2 flex justify-end">
            <button
              type="submit"
              disabled={loading || !!newPasswordError || !!confirmPasswordError}
              className="flex items-center px-6 py-2.5 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-200 transition-all disabled:opacity-70 disabled:cursor-not-allowed"
            >
              {loading ? (
                <Loader2 className="w-5 h-5 mr-2 animate-spin" />
              ) : (
                <Save className="w-5 h-5 mr-2" />
              )}
              {t('update_password')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
