"use client";

import { useState, Suspense } from "react";
import { doc, updateDoc, deleteDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useServerPagination } from "@/hooks/useServerPagination";
import { Users, Search, ShieldAlert, ShieldCheck, UserPlus, Trash2, Edit } from "lucide-react";
import { toast } from "react-hot-toast";
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatDateTime } from "@/lib/formatters";
import Link from "next/link";
import { Modal } from "@/components/ui/Modal";
import { Button } from "@/components/ui/Button";
import { useLanguage } from '@/context/LanguageContext';

type Agent = {
  id: string;
  fullName: string;
  mobileNumber: string;
  whatsappNumber?: string;
  email: string;
  firmName?: string;
  status: string; // e.g., 'ACTIVE', 'DISABLED'
  createdAt: any;
};

function AgentsContent() {
  const { t } = useLanguage();
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [statusLoading, setStatusLoading] = useState<string | null>(null);
  
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [agentToDelete, setAgentToDelete] = useState<Agent | null>(null);
  const [deleting, setDeleting] = useState(false);

  const filters: any[] = [];
  if (statusFilter !== "ALL") {
    filters.push({ field: "status", operator: "==", value: statusFilter });
  }

  const {
    data: agents,
    setData: setAgents,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/agents", // using abstract endpoint assuming it handles querying the agents collection
    searchField: "fullName",
    searchQuery,
    filters,
    capitalizeSearch: true
  });

  const handleToggleStatus = async (agent: Agent) => {
    const newStatus = agent.status === 'DISABLED' ? 'ACTIVE' : 'DISABLED';
    setStatusLoading(agent.id);
    try {
      await updateDoc(doc(db, "agents", agent.id), {
        status: newStatus,
        updatedAt: new Date().toISOString()
      });
      toast.success(newStatus === 'DISABLED' ? t('agent_access_disabled') : t('agent_access_enabled'));
      setAgents(agents.map((a: Agent) => a.id === agent.id ? { ...a, status: newStatus } : a));
    } catch (error) {
      toast.error(t('failed_update_agent_status'));
    } finally {
      setStatusLoading(null);
    }
  };
  
  const confirmDelete = (agent: Agent) => {
    setAgentToDelete(agent);
    setIsDeleteModalOpen(true);
  };
  
  const handleDeleteAgent = async () => {
    if (!agentToDelete) return;
    setDeleting(true);
    try {
      await deleteDoc(doc(db, "agents", agentToDelete.id));
      setAgents(agents.filter((a: Agent) => a.id !== agentToDelete.id));
      toast.success(t('agent_deleted'));
      setIsDeleteModalOpen(false);
      setAgentToDelete(null);
    } catch (error) {
      toast.error(t('failed_delete_agent'));
    } finally {
      setDeleting(false);
    }
  };

  const columns = [
    {
      header: t('joined_date'),
      key: "createdAt",
      render: (a: Agent) => {
        if (!a.createdAt) return <span>N/A</span>;
        const fullStr = formatDateTime(a.createdAt);
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
      header: t('agent_details'),
      key: "fullName",
      render: (a: Agent) => (
        <div>
          <div className="font-bold text-slate-900">{a.fullName}</div>
          <div className="text-xs text-slate-500 mt-0.5">{a.email}</div>
          {a.firmName && <div className="text-xs font-semibold text-blue-600 mt-1">{a.firmName}</div>}
        </div>
      )
    },
    {
      header: t('contact'),
      key: "mobileNumber",
      render: (a: Agent) => (
        <div>
          <div className="font-medium text-slate-700">{a.mobileNumber}</div>
          {a.whatsappNumber && <div className="text-xs text-green-600 mt-0.5">WA: {a.whatsappNumber}</div>}
        </div>
      )
    },
    {
      header: t('access_status'),
      key: "status",
      render: (a: Agent) => (
        <span className={`px-2.5 py-1 rounded-full text-xs font-bold ${
          a.status === 'DISABLED' ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'
        }`}>
          {a.status === 'DISABLED' ? t('disabled') : t('active')}
        </span>
      )
    },
    {
      header: t('actions'),
      key: "actions",
      render: (a: Agent) => (
        <div className="flex items-center gap-2">
          <button
            onClick={() => handleToggleStatus(a)}
            disabled={statusLoading === a.id}
            className={`p-2 rounded-lg transition-colors ${
              a.status === 'DISABLED' 
                ? 'text-green-600 hover:bg-green-50' 
                : 'text-orange-600 hover:bg-orange-50'
            }`}
            title={a.status === 'DISABLED' ? t('enable_access') : t('disable_access')}
          >
            {statusLoading === a.id ? (
              <div className="h-5 w-5 animate-spin rounded-full border-b-2 border-current"></div>
            ) : a.status === 'DISABLED' ? (
              <ShieldCheck className="h-5 w-5" />
            ) : (
              <ShieldAlert className="h-5 w-5" />
            )}
          </button>
          
          <button
            onClick={() => confirmDelete(a)}
            className="p-2 text-red-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            title={t('delete_agent')}
          >
            <Trash2 className="h-5 w-5" />
          </button>
        </div>
      )
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('agents_management')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('agents') }]}
        actions={
          <Link href="/agents/add" className="inline-flex items-center px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-xl hover:bg-blue-700 transition-colors shadow-sm shadow-blue-200">
            <UserPlus className="h-4 w-4 mr-2" />
            {t('add_new_agent')}
          </Link>
        }
      />

      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <input
            type="text"
            placeholder={t('search_agent_name')}
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
            <option value="ALL">{t('all_agents')}</option>
            <option value="ACTIVE">{t('active')}</option>
            <option value="DISABLED">{t('disabled')}</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        {loading && agents.length === 0 ? (
          <ShimmerTable rows={8} />
        ) : (
          <DataTable
            columns={columns}
            data={agents}
            isServerSide={true}
            hasNextPage={hasNextPage}
            hasPrevPage={hasPrevPage}
            onNextPage={handleNextPage}
            onPrevPage={handlePrevPage}
            itemsPerPage={10}
            emptyState={
              <EmptyState
                icon={<Users className="h-12 w-12 text-slate-300" />}
                title={t('no_agents')}
                description={t('no_agents_desc')}
              />
            }
          />
        )}
      </div>

      <Modal
        isOpen={isDeleteModalOpen}
        onClose={() => setIsDeleteModalOpen(false)}
        title={t('delete_agent')}
        maxWidth="md"
        footer={
          <div className="flex justify-end gap-3 w-full">
            <Button variant="secondary" onClick={() => setIsDeleteModalOpen(false)}>
              {t('cancel')}
            </Button>
            <Button variant="danger" onClick={handleDeleteAgent} isLoading={deleting}>
              {t('delete')}
            </Button>
          </div>
        }
      >
        <p className="text-slate-600">
          {t('delete_agent_confirm', { name: agentToDelete?.fullName || '' })}
        </p>
      </Modal>
    </div>
  );
}

export default function AgentsPage() {
  return (
    <Suspense fallback={<ShimmerTable rows={8} />}>
      <AgentsContent />
    </Suspense>
  );
}
