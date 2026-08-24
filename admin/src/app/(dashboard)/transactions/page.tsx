"use client";

import { useState, Suspense } from "react";
import { useServerPagination } from "@/hooks/useServerPagination";
import { CreditCard, Search } from "lucide-react";
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatDateTime, formatCurrency } from "@/lib/formatters";

type Payment = {
  id: string;
  customerId: string;
  bookingId: string;
  amount: number;
  mode: string;
  transactionId?: string;
  notes?: string;
  status: string;
  createdAt: any;
  // Enriched fields from api.ts
  customerName?: string;
  projectName?: string;
  plotNumber?: string;
};

const PAGE_SIZE = 15;

function TransactionsContent() {
  const [searchQuery, setSearchQuery] = useState("");

  const {
    data: payments,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/payments",
    searchField: "transactionId",
    searchQuery,
    itemsPerPage: PAGE_SIZE,
    capitalizeSearch: false
  });

  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchQuery(e.target.value);
  };

  const columns = [
    {
      header: "Date",
      key: "createdAt",
      render: (p: Payment) => (
        <div>
          <div className="font-semibold text-slate-900">
            {formatDateTime(p.createdAt).split(' at ')[0]}
          </div>
          <div className="text-xs text-slate-500">
            {formatDateTime(p.createdAt).split(' at ')[1]}
          </div>
        </div>
      )
    },
    {
      header: "Customer",
      key: "customerName",
      render: (p: Payment) => (
        <div className="font-medium text-slate-900">
          {p.customerName || "Unknown User"}
        </div>
      )
    },
    {
      header: "Project & Plot",
      key: "projectName",
      render: (p: Payment) => (
        <div>
          <div className="font-semibold text-slate-900">{p.projectName || "Unknown Project"}</div>
          <div className="text-xs text-slate-500">Plot {p.plotNumber || "N/A"}</div>
        </div>
      )
    },
    {
      header: "Amount",
      key: "amount",
      render: (p: Payment) => (
        <div className="font-bold text-slate-900">{formatCurrency(p.amount)}</div>
      )
    },
    {
      header: "Mode & Details",
      key: "mode",
      render: (p: Payment) => (
        <div>
          <div className="text-sm font-semibold text-slate-800">{p.mode}</div>
          {p.transactionId && (
            <div className="text-xs text-slate-500 font-mono mt-0.5">Txn: {p.transactionId}</div>
          )}
        </div>
      )
    },
    {
      header: "Status",
      key: "status",
      render: (p: Payment) => (
        <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
          p.status === 'COMPLETED' ? 'bg-green-100 text-green-800' : 'bg-slate-100 text-slate-800'
        }`}>
          {p.status || "COMPLETED"}
        </span>
      )
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title="Transactions Ledger"
        breadcrumbs={[
          { label: "Dashboard", href: "/dashboard" },
          { label: "Transactions" }
        ]}
      />

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100">
        <div className="p-4 sm:p-6 border-b border-slate-100">
          <div className="flex flex-col sm:flex-row sm:items-center gap-4">
            <div className="relative flex-1 max-w-md">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
              <input
                type="text"
                placeholder="Search by Transaction ID..."
                value={searchQuery}
                onChange={handleSearch}
                className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all"
              />
            </div>
          </div>
        </div>

        {loading ? (
          <div className="p-6">
            <ShimmerTable rows={6} />
          </div>
        ) : payments.length === 0 ? (
          <EmptyState
            icon={<CreditCard className="h-12 w-12 text-slate-300" />}
            title="No Transactions Found"
            description="No payments have been recorded yet or match your search."
          />
        ) : (
          <DataTable
            columns={columns}
            data={payments}
            isServerSide={true}
            hasNextPage={hasNextPage}
            hasPrevPage={hasPrevPage}
            onNextPage={handleNextPage}
            onPrevPage={handlePrevPage}
            itemsPerPage={PAGE_SIZE}
          />
        )}
      </div>
    </div>
  );
}

export default function TransactionsPage() {
  return (
    <Suspense fallback={
      <div className="space-y-6">
        <div className="h-12 w-48 bg-slate-200 animate-pulse rounded-lg"></div>
        <div className="bg-white rounded-2xl p-6 border border-slate-100">
          <ShimmerTable rows={8} />
        </div>
      </div>
    }>
      <TransactionsContent />
    </Suspense>
  );
}
