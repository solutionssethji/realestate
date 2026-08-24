/* eslint-disable react-hooks/immutability */
"use client";

import { useState, Suspense } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Building2, Loader2, CheckCircle2, Eye, EyeOff } from "lucide-react";
import { useLanguage } from '@/context/LanguageContext';
import { toast } from 'react-hot-toast';
import { validateStrongPassword } from "@/lib/validators";

function ResetPasswordForm() {
  const { t } = useLanguage();
  const searchParams = useSearchParams();
  const token = searchParams.get("token");

  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [confirmPasswordError, setConfirmPasswordError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!token) {
      toast.error("Invalid or missing reset token.");
      return;
    }
    if (password !== confirmPassword) {
      toast.error("Passwords do not match.");
      return;
    }

    const passwordError = validateStrongPassword(password);
    if (passwordError) {
      toast.error(passwordError);
      return;
    }

    setLoading(true);

    try {
      const { confirmPasswordReset } = await import("firebase/auth");
      const { auth } = await import("@/lib/firebase");
      await confirmPasswordReset(auth, token, password);
      setSuccess(true);
    } catch (err: any) {
      toast.error(err.message || "Failed to reset password.");
    } finally {
      setLoading(false);
    }
  };

  if (!token && !success) {
    return (
      <div className="text-center">
        <p className="text-red-600 mb-4">Invalid or missing reset token.</p>
        <Link href="/login" className="text-blue-600 hover:underline">{t('return_to_login')}</Link>
      </div>
    );
  }

  if (success) {
    return (
      <div className="text-center">
        <CheckCircle2 className="mx-auto h-12 w-12 text-green-500" />
        <h3 className="mt-2 text-lg font-medium text-gray-900">Password Reset!</h3>
        <p className="mt-1 text-sm text-gray-500">Your password has been successfully updated.</p>
        <div className="mt-6">
          <Link
            href="/login"
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
          >
            Login Now
          </Link>
        </div>
      </div>
    );
  }

  return (
    <form className="space-y-6" onSubmit={handleSubmit}>
      <div>
        <label className="block text-sm font-medium text-gray-700">{t('new_password')}</label>
        <div className="mt-1 relative">
          <input
            type={showPassword ? "text" : "password"}
            required
            minLength={6}
            value={password}
            onChange={(e) => {
              const val = e.target.value;
              setPassword(val);
              if (!val) {
                setPasswordError("New password is required");
              } else {
                setPasswordError(validateStrongPassword(val));
              }

              if (confirmPassword && val !== confirmPassword) {
                setConfirmPasswordError("Passwords do not match");
              } else if (confirmPassword && val === confirmPassword) {
                setConfirmPasswordError(null);
              }
            }}
            onBlur={() => {
              if (!password) {
                setPasswordError("New password is required");
              } else {
                setPasswordError(validateStrongPassword(password));
              }
            }}
            className={`appearance-none block w-full px-3 py-2 pr-10 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm ${passwordError ? 'border-red-300 bg-red-50' : 'border-gray-300'}`}
          />
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600"
          >
            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
        </div>
        {passwordError && <p className="mt-1.5 text-sm text-red-600">{passwordError}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">{t('confirm_password')}</label>
        <div className="mt-1 relative">
          <input
            type={showConfirmPassword ? "text" : "password"}
            required
            minLength={6}
            value={confirmPassword}
            onChange={(e) => {
              const val = e.target.value;
              setConfirmPassword(val);
              if (!val) {
                setConfirmPasswordError("Please confirm your new password");
              } else if (val !== password) {
                setConfirmPasswordError("Passwords do not match");
              } else {
                setConfirmPasswordError(null);
              }
            }}
            onBlur={() => {
              if (!confirmPassword) {
                setConfirmPasswordError("Please confirm your new password");
              } else if (confirmPassword !== password) {
                setConfirmPasswordError("Passwords do not match");
              }
            }}
            className={`appearance-none block w-full px-3 py-2 pr-10 border rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm ${confirmPasswordError ? 'border-red-300 bg-red-50' : 'border-gray-300'}`}
          />
          <button
            type="button"
            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
            className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600"
          >
            {showConfirmPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
        </div>
        {confirmPasswordError && <p className="mt-1.5 text-sm text-red-600">{confirmPasswordError}</p>}
      </div>

      <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100">
        <p className="text-sm text-blue-800 font-medium mb-1">Password Requirements:</p>
        <ul className="text-xs text-blue-600/80 list-disc list-inside space-y-0.5">
          <li>Must be at least 8 characters</li>
          <li>1 uppercase and 1 lowercase letter</li>
          <li>1 number and 1 special character</li>
        </ul>
      </div>

      <div>
        <button
          type="submit"
          disabled={loading || !password || !confirmPassword}
          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:bg-blue-400"
        >
          {loading ? <Loader2 className="h-5 w-5 animate-spin" /> : "Reset Password"}
        </button>
      </div>
    </form>
  );
}

export default function ResetPasswordPage() {
  const { t } = useLanguage();
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="flex justify-center mb-6">
          <img src="/logo_with_text.png" alt="SHUBHAYTANAM CONNECT" className="h-24 w-auto object-contain" />
        </div>
        <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
          Create New Password
        </h2>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <Suspense fallback={<div className="flex justify-center"><Loader2 className="animate-spin text-blue-600" /></div>}>
            <ResetPasswordForm />
          </Suspense>
        </div>
      </div>
    </div>
  );
}
