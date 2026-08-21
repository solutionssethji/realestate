/* eslint-disable react-hooks/immutability */
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client";

import { useState, useEffect } from "react";
import api from "@/lib/api";
import { useServerPagination } from "@/hooks/useServerPagination";
import Link from "next/link";
import { Plus, Trash2, Tag, Search, Eye, EyeOff, Edit2 } from "lucide-react";
import { useLanguage } from '@/context/LanguageContext';
import { toast } from 'react-hot-toast';
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { StatusBadge } from "@/components/ui/StatusBadge";
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
    filters: [],
    capitalizeSearch: true
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

  async function handleToggleVisibility(offer: any) {
    try {
      const isCurrentlyActive = offer.active !== false;
      const newStatus = !isCurrentlyActive;

      setOffers(offers.map(o => o.id === offer.id ? { ...o, active: newStatus } : o));
      await api.put(`/offers/${offer.id}`, { ...offer, active: newStatus });
      toast.success(newStatus ? "Offer enabled successfully" : "Offer disabled successfully");
    } catch (error: any) {
      setOffers(offers.map(o => o.id === offer.id ? { ...o, active: offer.active } : o));
      toast.error("Failed to update offer visibility");
    }
  }

  const columns = [
    {
      header: t('offer'),
      key: "title",
      render: (offer: any) => {
        const project = projects.find(p => p.id === offer.projectId);
        return (
          <div>
            <div className="font-bold text-slate-900">{offer.title?.en || (typeof offer.title === 'string' ? offer.title : 'Offer')}</div>
            <div className="text-sm text-slate-500 mt-1 line-clamp-1">{offer.description?.en || (typeof offer.description === 'string' ? offer.description : '')}</div>
            {project && (
              <div className="inline-flex items-center mt-2 px-2 py-1 rounded-md bg-slate-100 text-xs font-medium text-slate-600">
                <Tag className="h-3 w-3 mr-1" />
                {project.name?.en || project.name}
              </div>
            )}
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
      render: (offer: any) => (
        <StatusBadge
          status={offer.active !== false ? 'ACTIVE' : 'INACTIVE'}
        />
      )
    },
    {
      header: t('actions'),
      key: "actions",
      render: (offer: any) => (
        <div className="flex items-center space-x-2">
          <button
            onClick={() => handleToggleVisibility(offer)}
            title={offer.active === false ? "Enable Offer" : "Disable Offer"}
            className={`p-2 rounded-lg transition-colors ${offer.active === false
              ? "text-slate-400 hover:text-green-600 hover:bg-green-50"
              : "text-blue-600 hover:text-orange-600 hover:bg-orange-50 bg-blue-50"
              }`}
          >
            {offer.active === false ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
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
