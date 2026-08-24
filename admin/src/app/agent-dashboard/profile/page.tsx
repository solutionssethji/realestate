"use client";

import { useAuth } from "@/context/AuthContext";
import { PageHeader } from "@/components/ui/PageHeader";
import { User, Mail, ShieldAlert } from "lucide-react";

export default function AgentProfilePage() {
  const { user } = useAuth();

  return (
    <div className="space-y-6 pb-8 max-w-3xl mx-auto">
      <PageHeader
        title="My Profile"
        breadcrumbs={[
          { label: "Agent Portal", href: "/agent-dashboard" },
          { label: "Profile" }
        ]}
      />

      <div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
        <div className="flex items-center gap-6 mb-8 pb-8 border-b border-slate-100">
          <div className="h-24 w-24 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center font-bold text-4xl shadow-inner border-4 border-white">
            {user?.email?.charAt(0).toUpperCase() || 'A'}
          </div>
          <div>
            <h2 className="text-2xl font-bold text-slate-900">Agent Details</h2>
            <div className="flex items-center gap-2 mt-2">
              <span className="px-3 py-1 bg-green-100 text-green-700 text-xs font-bold rounded-full">
                ACTIVE
              </span>
              <span className="px-3 py-1 bg-blue-100 text-blue-700 text-xs font-bold rounded-full">
                SALES PARTNER
              </span>
            </div>
          </div>
        </div>

        <form className="space-y-6">
          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2 flex items-center gap-2">
              <Mail className="h-4 w-4 text-slate-400" />
              Registered Email (Locked)
            </label>
            <input 
              type="email" 
              value={user?.email || ''} 
              disabled 
              className="w-full px-4 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-slate-500 cursor-not-allowed" 
            />
            <p className="text-xs text-slate-500 mt-2 flex items-center gap-1">
              <ShieldAlert className="h-3 w-3" />
              Email address cannot be changed. Contact an Administrator to update it.
            </p>
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2 flex items-center gap-2">
              <User className="h-4 w-4 text-slate-400" />
              Update Password
            </label>
            <button
              type="button"
              className="px-6 py-2.5 bg-slate-100 text-slate-700 font-semibold rounded-xl hover:bg-slate-200 transition-colors border border-slate-200"
            >
              Send Password Reset Email
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
