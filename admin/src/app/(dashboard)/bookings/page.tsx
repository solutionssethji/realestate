"use client";

import { useState, Suspense } from "react";
import { useServerPagination } from "@/hooks/useServerPagination";
import { Bookmark, Search, Eye } from "lucide-react";
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatDateTime, formatCurrency } from "@/lib/formatters";
import Link from "next/link";
import { useLanguage } from "@/context/LanguageContext";

type Booking = {
  id: string;
  customerName: string;
  projectName: string;
  plotNumber: string;
  status: string; // e.g., 'BOOKED', 'SOLD'
  totalAmount: number;
  paidAmount: number;
  createdAt: any;
};

function BookingsContent() {
  const { t } = useLanguage();
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");

  const filters: any[] = [];
  if (statusFilter !== "ALL") {
    filters.push({ field: "status", operator: "==", value: statusFilter });
  }

  const {
    data: bookings,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/bookings",
    searchField: "customerName",
    searchQuery,
    filters,
    capitalizeSearch: true
  });

  const columns = [
    {
      header: t('booking_date'),
      key: "createdAt",
      render: (b: Booking) => {
        if (!b.createdAt) return <span>N/A</span>;
        const fullStr = formatDateTime(b.createdAt);
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
      header: t('customer'),
      key: "customerName",
      render: (b: Booking) => (
        <span className="font-bold text-slate-900">{b.customerName || t('unknown_user')}</span>
      )
    },
    {
      header: t('property_details'),
      key: "property",
      render: (b: Booking) => (
        <div>
          <div className="font-bold text-slate-900">{b.projectName}</div>
          <div className="text-xs text-slate-500 mt-0.5">{t('plot')} {b.plotNumber}</div>
        </div>
      )
    },
    {
      header: t('payment'),
      key: "payment",
      render: (b: Booking) => {
        const balance = (b.totalAmount || 0) - (b.paidAmount || 0);
        return (
          <div>
            <div className="font-bold text-slate-900">{formatCurrency(b.paidAmount || 0)} {t('paid')}</div>
            {balance > 0 && <div className="text-xs text-red-500 mt-0.5">{formatCurrency(balance)} {t('pending')}</div>}
            {balance <= 0 && <div className="text-xs text-green-500 mt-0.5">{t('fully_paid')}</div>}
          </div>
        )
      }
    },
    {
      header: t('status'),
      key: "status",
      render: (b: Booking) => (
        <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${b.status === 'SOLD' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'
          }`}>
          {b.status}
        </span>
      )
    },
    {
      header: t('actions'),
      key: "actions",
      render: (b: Booking) => (
        <div className="flex items-center gap-2">
          <Link href={`/bookings/${b.id}`} className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title={t('view_details')}>
            <Eye className="h-5 w-5" />
          </Link>
        </div>
      )
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('bookings_management')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('bookings') }]}
      />

      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <input
            type="text"
            placeholder={t('search_customer_name')}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm"
          />
        </div>
        <div className="sm:w-48 shrink-0">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="block w-full pl-4 pr-10 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%2394A3B8%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:0.75rem_0.75rem] bg-[position:right_1rem_center] bg-no-repeat"
          >
            <option value="ALL">{t('all_bookings')}</option>
            <option value="BOOKED_SOLD">{t('booked_sold')}</option>
            <option value="AVAILABLE">{t('available')}</option>
            <option value="ON_HOLD">{t('on_hold')}</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        {loading && bookings.length === 0 ? (
          <ShimmerTable rows={8} />
        ) : (
          <DataTable
            columns={columns}
            data={bookings}
            isServerSide={true}
            hasNextPage={hasNextPage}
            hasPrevPage={hasPrevPage}
            onNextPage={handleNextPage}
            onPrevPage={handlePrevPage}
            itemsPerPage={10}
            emptyState={
              <EmptyState
                icon={<Bookmark className="h-12 w-12 text-slate-300" />}
                title={t('no_bookings')}
                description={t('no_bookings_desc')}
              />
            }
          />
        )}
      </div>
    </div>
  );
}

export default function BookingsPage() {
  return (
    <Suspense fallback={<ShimmerTable rows={8} />}>
      <BookingsContent />
    </Suspense>
  );
}
