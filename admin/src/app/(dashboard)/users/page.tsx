"use client";

import { useState, Suspense } from "react";
import { doc, updateDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useServerPagination } from "@/hooks/useServerPagination";
import { Users, Search, Eye, ShieldAlert, ShieldCheck, ChevronDown } from "lucide-react";
import { toast } from "react-hot-toast";
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatDateTime } from "@/lib/formatters";
import Link from "next/link";

type User = {
  id: string;
  fullName: string;
  mobileNumber: string;
  email?: string;
  status: string; // e.g., 'ACTIVE', 'BLOCKED'
  createdAt: any;
};

function UsersContent() {
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [statusLoading, setStatusLoading] = useState<string | null>(null);

  const filters: any[] = [];
  if (statusFilter !== "ALL") {
    filters.push({ field: "status", operator: "==", value: statusFilter });
  }

  const {
    data: users,
    setData: setUsers,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/users",
    searchField: "fullName",
    searchQuery,
    filters,
    capitalizeSearch: true
  });

  const handleUpdateStatus = async (user: User, newStatus: string) => {
    setStatusLoading(user.id);
    try {
      await updateDoc(doc(db, "users", user.id), {
        status: newStatus,
        updatedAt: new Date().toISOString()
      });
      toast.success(`User status updated to ${newStatus}`);
      setUsers(users.map((u: User) => u.id === user.id ? { ...u, status: newStatus } : u));
    } catch (error) {
      toast.error("Failed to update user status");
    } finally {
      setStatusLoading(null);
    }
  };

  const columns = [
    {
      header: "Joined Date",
      key: "createdAt",
      render: (u: User) => {
        if (!u.createdAt) return <span>N/A</span>;
        const fullStr = formatDateTime(u.createdAt);
        const lastCommaIdx = fullStr.lastIndexOf(',');
        const dateStr = lastCommaIdx !== -1 ? fullStr.substring(0, lastCommaIdx).trim() : fullStr;
        return (
          <div>
            <div className="font-bold text-slate-900">{dateStr}</div>
          </div>
        );
      }
    },
    {
      header: "Customer",
      key: "fullName",
      render: (u: User) => (
        <div>
          <div className="font-bold text-slate-900">{u.fullName || 'Unknown'}</div>
          {u.email && <div className="text-xs text-slate-500 mt-0.5">{u.email}</div>}
        </div>
      )
    },
    {
      header: "Mobile",
      key: "mobileNumber",
      render: (u: User) => (
        <span className="font-medium text-slate-700">{u.mobileNumber}</span>
      )
    },
    {
      header: "Status",
      key: "status",
      render: (u: User) => (
        <div className="relative inline-block">
          <select
            value={u.status || 'ACTIVE'}
            onChange={(e) => handleUpdateStatus(u, e.target.value)}
            disabled={statusLoading === u.id}
            className={`appearance-none pl-3 pr-8 py-1.5 text-xs font-bold rounded-full outline-none cursor-pointer border-2 transition-all ${u.status === 'BLOCKED' ? 'bg-red-50 text-red-700 border-red-200 hover:bg-red-100' :
                u.status === 'DELETED' ? 'bg-slate-100 text-slate-600 border-slate-300' :
                  'bg-green-50 text-green-700 border-green-200 hover:bg-green-100'
              } ${statusLoading === u.id ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            <option value="ACTIVE">Active</option>
            <option value="BLOCKED">Blocked</option>
            <option value="DELETED">Deleted</option>
          </select>
          <div className="pointer-events-none absolute right-2 top-1/2 -translate-y-1/2">
            {statusLoading === u.id
              ? <div className="h-3 w-3 animate-spin rounded-full border-b-2 border-current"></div>
              : <ChevronDown className="h-3 w-3 opacity-60" />
            }
          </div>
        </div>
      )
    },
    {
      header: "Actions",
      key: "actions",
      render: (u: User) => (
        <Link
          href={`/users/${u.id}`}
          className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 text-blue-600 text-xs font-semibold rounded-lg hover:bg-blue-100 transition-colors"
        >
          <Eye className="h-3.5 w-3.5" />
          View Profile
        </Link>
      )
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title="Users Management"
        breadcrumbs={[{ label: "Dashboard", href: "/dashboard" }, { label: "Users" }]}
      />

      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <input
            type="text"
            placeholder="Search by name..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm"
          />
        </div>
        <div className="w-full sm:w-64">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="block w-full pl-4 pr-10 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%2394A3B8%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:0.75rem_0.75rem] bg-[position:right_1rem_center] bg-no-repeat"
          >
            <option value="ALL">All Users</option>
            <option value="ACTIVE">Active</option>
            <option value="BLOCKED">Blocked</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        {loading && users.length === 0 ? (
          <ShimmerTable rows={8} />
        ) : (
          <DataTable
            columns={columns}
            data={users}
            isServerSide={true}
            hasNextPage={hasNextPage}
            hasPrevPage={hasPrevPage}
            onNextPage={handleNextPage}
            onPrevPage={handlePrevPage}
            itemsPerPage={10}
            emptyState={
              <EmptyState
                icon={<Users className="h-12 w-12 text-slate-300" />}
                title="No Users"
                description="There are no users matching your criteria."
              />
            }
          />
        )}
      </div>
    </div>
  );
}

export default function UsersPage() {
  return (
    <Suspense fallback={<ShimmerTable rows={8} />}>
      <UsersContent />
    </Suspense>
  );
}
