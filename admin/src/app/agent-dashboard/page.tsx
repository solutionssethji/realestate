"use client";

import { PageHeader } from "@/components/ui/PageHeader";
import { Building2, Tag, Users } from "lucide-react";
import Link from "next/link";

export default function AgentDashboardPage() {
  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title="Agent Dashboard"
        breadcrumbs={[{ label: "Agent Portal" }]}
      />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
          <div>
            <p className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-1">Total Projects</p>
            <h3 className="text-3xl font-bold text-slate-900">12</h3>
          </div>
          <div className="h-12 w-12 bg-blue-100 text-blue-600 rounded-2xl flex items-center justify-center">
            <Building2 className="h-6 w-6" />
          </div>
        </div>
        
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
          <div>
            <p className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-1">Active Offers</p>
            <h3 className="text-3xl font-bold text-slate-900">5</h3>
          </div>
          <div className="h-12 w-12 bg-purple-100 text-purple-600 rounded-2xl flex items-center justify-center">
            <Tag className="h-6 w-6" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center justify-between">
          <div>
            <p className="text-sm font-semibold text-slate-500 uppercase tracking-wider mb-1">My Leads</p>
            <h3 className="text-3xl font-bold text-slate-900">24</h3>
          </div>
          <div className="h-12 w-12 bg-green-100 text-green-600 rounded-2xl flex items-center justify-center">
            <Users className="h-6 w-6" />
          </div>
        </div>
      </div>

      <div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100 mt-8 text-center">
        <h2 className="text-2xl font-bold text-slate-900 mb-4">Welcome to the Agent Portal!</h2>
        <p className="text-slate-600 max-w-2xl mx-auto mb-8">
          This dashboard gives you read-only access to view active projects, available plots, and current promotional offers. Use this information to guide your clients effectively. Lead management capabilities are coming soon.
        </p>
        <Link href="/agent-dashboard/profile" className="inline-flex items-center px-6 py-3 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 transition-colors shadow-sm shadow-blue-200">
          Complete Your Profile
        </Link>
      </div>
    </div>
  );
}
