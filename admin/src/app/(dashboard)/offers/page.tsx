/* eslint-disable react-hooks/immutability */
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client";

import { useState, useEffect } from "react";
import api from "@/lib/api";
import { useServerPagination } from "@/hooks/useServerPagination";
import Link from "next/link";
import { Plus, Trash2, Tag, Search, Edit2 } from "lucide-react";
import { useLanguage } from '@/context/LanguageContext';
import { toast } from 'react-hot-toast';
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";

import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";
import { ConfirmModal } from "@/components/ui/ConfirmModal";

export default function OffersListPage() {
  const { t } = useLanguage();
  const [projects, setProjects] = useState<any[]>([]);
  const [deleteLoading, setDeleteLoading] = useState<string | null>(null);

  const [confirmModal, setConfirmModal] = useState<{
    isOpen: boolean;
    title: string;
    message: React.ReactNode;
    onConfirm: () => void;
    isDanger?: boolean;
    confirmText?: string;
  }>({ isOpen: false, title: "", message: "", onConfirm: () => { } });

  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");

  const filters: any[] = [];
  if (statusFilter !== "ALL") {
    filters.push({ field: "status", operator: "==", value: statusFilter });
  }

  // Detect if the search query contains Hindi characters
  const isHindi = (text: string) => /[\u0900-\u097F]/.test(text);
  const currentSearchField = isHindi(searchQuery) ? "title.hi" : "title.en";

  const {
    data: offers,
    setData: setOffers,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/offers",
    searchField: currentSearchField,
    searchQuery,
    filters
  });

  useEffect(() => {
    async function loadProjects() {
      try {
        const res = await api.get("/projects");
        setProjects(res.data.data || []);
      } catch (e) {
        console.error(e);
      }
    }
    loadProjects();
  }, []);

  async function handleDelete(id: string, title: string) {
    setConfirmModal({
      isOpen: true,
      title: "Delete Offer",
      message: `Are you sure you want to delete offer "${title}"?`,
      isDanger: true,
      confirmText: "Delete",
      onConfirm: async () => {
        try {
          setDeleteLoading(id);
          await api.delete(`/offers/${id}`);
          setOffers(offers.filter((o: any) => o.id !== id));
          setConfirmModal(prev => ({ ...prev, isOpen: false }));
        } catch (error: any) {
          toast.error("Failed to delete offer");
        } finally {
          setDeleteLoading(null);
        }
      }
    });
  }

  const [statusLoading, setStatusLoading] = useState<string | null>(null);

  async function handleStatusChange(offerId: string, newStatus: string) {
    try {
      setStatusLoading(offerId);
      const offer = offers.find((o: any) => o.id === offerId);
      if (!offer) return;

      const updatedOffer = { ...offer, status: newStatus };
      await api.put(`/offers/${offerId}`, updatedOffer);

      setOffers(offers.map((o: any) => o.id === offerId ? updatedOffer : o));
      toast.success("Offer status updated successfully");
    } catch (error) {
      toast.error("Failed to update offer status");
    } finally {
      setStatusLoading(null);
    }
  }

  const columns = [
    {
      header: t('offer'),
      key: "title",
      render: (offer: any) => {
        const project = projects.find(p => p.id === offer.projectId);
        return (
          <div className="flex items-center">
            {offer.image ? (
              <img className="h-12 w-12 rounded-xl object-cover shadow-sm" src={offer.image} alt={offer.title?.en || 'Offer'} />
            ) : (
              <div className="h-12 w-12 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center shadow-sm">
                <Tag className="h-6 w-6 text-slate-400" />
              </div>
            )}
            <div className="ml-4 flex-1">
              <div className="font-bold text-slate-900 text-base">{offer.title?.en || (typeof offer.title === 'string' ? offer.title : 'Offer')}</div>
              <div className="text-sm text-slate-500 mt-1 line-clamp-1">{offer.description?.en || (typeof offer.description === 'string' ? offer.description : '')}</div>
              {project && (
                <div className="inline-flex items-center mt-2 px-2 py-1 rounded-md bg-indigo-50 border border-indigo-100 text-xs font-medium text-indigo-700">
                  <Tag className="h-3 w-3 mr-1" />
                  {project.name?.en || (typeof project.name === 'string' ? project.name : 'Project')}
                </div>
              )}
            </div>
          </div>
        );
      }
    },
    {
      header: "Discount",
      key: "discount",
      render: (offer: any) => {
        if (offer.discountType === 'PERCENTAGE') {
          return <span className="font-bold text-green-600">{offer.discountValue}% OFF</span>;
        }
        return <span className="font-bold text-green-600">₹{offer.discountValue} OFF</span>;
      }
    },
    {
      header: t('validity'),
      key: "validity",
      render: (offer: any) => (
        <div className="text-sm">
          <div className="text-slate-900">From: {new Date(offer.startDate).toLocaleDateString()}</div>
          <div className="text-slate-500">To: {new Date(offer.endDate).toLocaleDateString()}</div>
        </div>
      )
    },
    {
      header: t('status'),
      key: "status",
      render: (offer: any) => {
        const currentVal = offer.status || 'ACTIVE';
        return (
          <select
            value={currentVal}
            onChange={(e) => handleStatusChange(offer.id, e.target.value)}
            disabled={statusLoading === offer.id || currentVal === 'EXPIRED'}
            className={`inline-flex items-center px-2 py-1 rounded-lg text-xs font-medium border focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 ${currentVal === 'ACTIVE' ? 'bg-green-50 text-green-800 border-green-200' :
                currentVal === 'INACTIVE' ? 'bg-slate-50 text-slate-800 border-slate-200' :
                  'bg-red-50 text-red-800 border-red-200'
              }`}
          >
            <option value="ACTIVE">Active</option>
            <option value="INACTIVE">Inactive</option>
            <option value="EXPIRED">Expired</option>
          </select>
        );
      }
    },
    {
      header: t('actions'),
      key: "actions",
      render: (offer: any) => (
        <div className="flex items-center space-x-2">
          <Link href={`/offers/${offer.id}/edit`}>
            <button title="Edit Offer" className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
              <Edit2 className="h-4 w-4" />
            </button>
          </Link>
          <button
            onClick={() => handleDelete(offer.id, offer.title?.en || (typeof offer.title === 'string' ? offer.title : 'Offer'))}
            title="Delete Offer"
            disabled={deleteLoading === offer.id}
            className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      )
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('offers_management')}
        breadcrumbs={[{ label: "Dashboard", href: "/dashboard" }, { label: "Offers" }]}
        actions={
          <Link href="/offers/new">
            <Button icon={<Plus className="h-4 w-4" />}>
              Add Offer
            </Button>
          </Link>
        }
      />

      {/* Toolbar */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <input
            type="text"
            placeholder="Search offers by title..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm"
          />
        </div>
        <div className="w-full sm:w-48">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="block w-full pl-4 pr-10 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%2394A3B8%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:0.75rem_0.75rem] bg-[position:right_1rem_center] bg-no-repeat"
          >
            <option value="ALL">All Offers</option>
            <option value="ACTIVE">Active</option>
            <option value="INACTIVE">Inactive</option>
            <option value="EXPIRED">Expired</option>
          </select>
        </div>
      </div>

      {loading ? (
        <ShimmerTable rows={5} />
      ) : (
        <DataTable
          columns={columns}
          data={offers}
          isServerSide={true}
          hasNextPage={hasNextPage}
          hasPrevPage={hasPrevPage}
          onNextPage={handleNextPage}
          onPrevPage={handlePrevPage}
          itemsPerPage={10}
          emptyState={
            <EmptyState
              icon={<Tag className="h-12 w-12 text-slate-300" />}
              title={t('no_offers_found')}
              description="Create promotional offers and discounts to display to your customers."
            />
          }
        />
      )}

      <ConfirmModal
        isOpen={confirmModal.isOpen}
        onClose={() => setConfirmModal(prev => ({ ...prev, isOpen: false }))}
        onConfirm={confirmModal.onConfirm}
        title={confirmModal.title}
        message={confirmModal.message}
        isDanger={confirmModal.isDanger}
        confirmText={confirmModal.confirmText}
        isLoading={deleteLoading !== null}
      />
    </div>
  );
}
