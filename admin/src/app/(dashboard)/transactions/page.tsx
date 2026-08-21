"use client";

import { useState } from "react";
import { CreditCard, Eye, Search, Plus } from "lucide-react";
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatDateTime } from "@/lib/formatters";
import { useServerPagination } from "@/hooks/useServerPagination";
import { Button } from "@/components/ui/Button";
import { getFunctions, httpsCallable } from "firebase/functions";
import { app } from "@/lib/firebase";
import toast from "react-hot-toast";

export default function TransactionsPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");

  const filters: any[] = [];
  if (statusFilter !== "ALL") {
    filters.push({ field: "status", operator: "==", value: statusFilter });
  }

  // Smart formatting for Transaction ID
  let formattedSearch = searchQuery.trim().toUpperCase();
  if (formattedSearch && /^\d+$/.test(formattedSearch)) {
    // If they typed just numbers like "10001", automatically prefix it with "TXN-"
    formattedSearch = `TXN-${formattedSearch}`;
  }

  const {
    data: transactions,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage,
    refreshCurrentPage
  } = useServerPagination({
    endpoint: "/transactions",
    searchField: "transactionId",
    searchQuery: formattedSearch,
    filters,
    capitalizeSearch: false
  });

  const columns = [
    {
      header: "Date",
      key: "createdAt",
      render: (txn: any) => {
        if (!txn.createdAt) return <span className="text-sm font-medium text-slate-700">-</span>;
        const fullStr = formatDateTime(txn.createdAt);
        const lastCommaIdx = fullStr.lastIndexOf(',');
        const dateStr = lastCommaIdx !== -1 ? fullStr.substring(0, lastCommaIdx).trim() : fullStr;
        const timeStr = lastCommaIdx !== -1 ? fullStr.substring(lastCommaIdx + 1).trim() : '';
        return (
          <div>
            <div className="font-bold text-slate-900">{dateStr}</div>
            {timeStr && <div className="text-xs text-slate-500 mt-0.5">{timeStr}</div>}
          </div>
        );
      }
    },
    {
      header: "Transaction ID",
      key: "transactionId",
      render: (txn: any) => (
        <span className="font-bold text-slate-900">{txn.transactionId || txn.id}</span>
      )
    },
    {
      header: "Customer",
      key: "customerName",
      render: (txn: any) => (
        <div>
          <div className="font-bold text-slate-900">{txn.customerName}</div>
          {txn.customerMobile && <div className="text-xs font-medium text-slate-600 mt-0.5">{txn.customerMobile}</div>}
          {txn.customerEmail && <div className="text-xs text-slate-500 mt-0.5">{txn.customerEmail}</div>}
        </div>
      )
    },
    {
      header: "Amount",
      key: "amount",
      render: (txn: any) => (
        <span className="font-bold text-blue-600">
          {new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', minimumFractionDigits: 0 }).format(txn.amount || 0)}
        </span>
      )
    },
    {
      header: "Type",
      key: "type",
      render: (txn: any) => (
        <span className="text-sm text-slate-600">{txn.type}</span>
      )
    },
    {
      header: "Status",
      key: "status",
      render: (txn: any) => (
        <span className={`px-2 py-1 rounded-full text-xs font-bold ${txn.status === 'COMPLETED' ? 'bg-green-100 text-green-700' : 'bg-yellow-100 text-yellow-700'
          }`}>
          {txn.status}
        </span>
      )
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title="Transactions"
        breadcrumbs={[{ label: "Dashboard", href: "/dashboard" }, { label: "Transactions" }]}
      />

      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <input
            type="text"
            placeholder="Search by transaction ID..."
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
            <option value="ALL">All Statuses</option>
            <option value="PENDING">Pending</option>
            <option value="COMPLETED">Completed</option>
            <option value="FAILED">Failed</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        <DataTable
          columns={columns}
          data={transactions}
          isServerSide={true}
          hasNextPage={hasNextPage}
          hasPrevPage={hasPrevPage}
          onNextPage={handleNextPage}
          onPrevPage={handlePrevPage}
          itemsPerPage={10}
          emptyState={
            <EmptyState
              icon={<CreditCard className="h-12 w-12 text-slate-300" />}
              title="No Transactions"
              description="There are no transactions found in the database."
            />
          }
        />
      </div>
    </div>
  );
}
