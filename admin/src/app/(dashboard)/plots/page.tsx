/* eslint-disable react-hooks/immutability */
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client";

import { useState, useEffect } from "react";
import api from "@/lib/api";
import { useServerPagination } from "@/hooks/useServerPagination";
import Link from "next/link";
import { Plus, Edit2, Trash2, Map as MapIcon, Search, Loader2, Eye, EyeOff, UserPlus } from "lucide-react";
import { toast } from "react-hot-toast";
import { useLanguage } from '@/context/LanguageContext';
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";
import { ConfirmModal } from "@/components/ui/ConfirmModal";
import { AssignPlotDialog } from "@/components/AssignPlotDialog";
import { useAuth } from "@/context/AuthContext";

export default function PlotsListPage() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [projects, setProjects] = useState<any[]>([]);
  const [assignedUserNames, setAssignedUserNames] = useState<Record<string, string>>({});
  const [deleteLoading, setDeleteLoading] = useState<string | null>(null);
  const [statusLoading, setStatusLoading] = useState<string | null>(null);

  const [confirmModal, setConfirmModal] = useState<{
    isOpen: boolean;
    title: string;
    message: React.ReactNode;
    onConfirm: () => void;
    isDanger?: boolean;
    confirmText?: string;
  }>({ isOpen: false, title: "", message: "", onConfirm: () => { } });

  const [assignDialog, setAssignDialog] = useState<{
    isOpen: boolean;
    plot: any | null;
  }>({ isOpen: false, plot: null });

  const [selectedProjectId, setSelectedProjectId] = useState<string>("");
  const [selectedStatus, setSelectedStatus] = useState<string>("");
  const [searchQuery, setSearchQuery] = useState("");

  const filters: any[] = [];
  if (selectedProjectId) {
    filters.push({ field: "projectId", operator: "==", value: selectedProjectId });
  }
  if (selectedStatus) {
    filters.push({ field: "status", operator: "==", value: selectedStatus });
  }

  const {
    data: plots,
    setData: setPlots,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/plots",
    searchField: "plotNumber",
    searchQuery: searchQuery.toUpperCase(),
    filters,
    capitalizeSearch: false
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

  useEffect(() => {
    if (user?.role === 'AGENT') return;
    const assignedUserIds = [...new Set(
      plots
        .map((plot: any) => plot.assignedUserId)
        .filter((userId: any): userId is string => Boolean(userId)),
    )];
    if (assignedUserIds.length === 0) return;

    Promise.all(
      assignedUserIds.map(async (userId) => {
        try {
          const response = await api.get(`/users/${userId}`);
          const customer = response.data?.data;
          return [userId, customer?.fullName || customer?.name || 'Unknown'] as const;
        } catch (error) {
          console.error(`Unable to load assigned user ${userId}`, error);
          return [userId, 'Unknown'] as const;
        }
      }),
    ).then((entries) => setAssignedUserNames((current) => ({
      ...current,
      ...Object.fromEntries(entries),
    })));
  }, [plots, user?.role]);

  async function handleDelete(id: string, plotNumber: string) {
    setConfirmModal({
      isOpen: true,
      title: t('delete_plot'),
      message: t('delete_plot_confirm', { plotNumber }),
      isDanger: true,
      confirmText: t('delete'),
      onConfirm: async () => {
        try {
          setDeleteLoading(id);
          await api.delete(`/plots/${id}`);
          setPlots(plots.filter((p: any) => p.id !== id));
          setConfirmModal(prev => ({ ...prev, isOpen: false }));
        } catch (error: any) {
          toast.error(error.response?.data?.message || t('failed_delete_plot'));
        } finally {
          setDeleteLoading(null);
        }
      }
    });
  }

  async function handleStatusChange(id: string, newStatus: string) {
    if (newStatus === "BOOKED_SOLD") {
      const plot = plots.find((p: any) => p.id === id);
      setAssignDialog({ isOpen: true, plot });
      return;
    }

    setConfirmModal({
      isOpen: true,
      title: t('change_status'),
      message: t('change_status_confirm', { status: newStatus.replace('_', ' ') }),
      isDanger: false,
      confirmText: t('confirm'),
      onConfirm: async () => {
        try {
          setStatusLoading(id);
          await api.put(`/plots/${id}`, { status: newStatus });
          setPlots(plots.map((p: any) => p.id === id ? { ...p, status: newStatus } : p) as any);
          setConfirmModal(prev => ({ ...prev, isOpen: false }));
        } catch (error: any) {
          toast.error(error.response?.data?.message || t('failed_update_status'));
        } finally {
          setStatusLoading(null);
        }
      }
    });
  }

  async function handleToggleVisibility(plot: any) {
    try {
      const isCurrentlyActive = plot.isActive !== false;
      const newStatus = !isCurrentlyActive;

      setPlots(plots.map(p => p.id === plot.id ? { ...p, isActive: newStatus } : p) as any);
      await api.put(`/plots/${plot.id}`, { ...plot, isActive: newStatus });
      toast.success(newStatus ? t('plot_enabled_success') : t('plot_disabled_success'));
    } catch (error: any) {
      setPlots(plots.map(p => p.id === plot.id ? { ...p, isActive: plot.isActive } : p) as any);
      toast.error(t('failed_update_plot_visibility'));
    }
  }
  const handlePlotAssigned = (plotId: string, assignedUserId: string, assignedUserName?: string) => {
    if (assignedUserName) {
      setAssignedUserNames((current) => ({ ...current, [assignedUserId]: assignedUserName }));
    }
    setPlots(plots.map((p: any) => p.id === plotId ? { ...p, status: "BOOKED_SOLD", assignedUserId } : p) as any);
  };

  // Filtered dynamically by useServerPagination

  const columns = [
    {
      header: t('plot_number'),
      key: "plotNumber",
      render: (plot: any) => (
        <span className="font-bold text-slate-900">{plot.plotNumber}</span>
      )
    },
    {
      header: t('project'),
      key: "project",
      render: (plot: any) => {
        const project = projects.find((p: any) => p.id === plot.projectId);
        return <span className="font-medium text-slate-600">{project?.name?.en || (typeof project?.name === 'string' ? project.name : t('unknown'))}</span>;
      }
    },
    {
      header: t('details'),
      key: "details",
      render: (plot: any) => (
        <div>
          <div className="font-medium text-slate-900">₹{plot.price?.toLocaleString()}</div>
          <div className="text-xs text-slate-500 mt-0.5">{String(plot.size).toLowerCase().includes('sq') || String(plot.size).toLowerCase().includes('yd') ? plot.size : `${plot.size} ${plot.sizeUnit || 'sq.yd'}`}</div>
        </div>
      )
    },
    {
      header: t('specifications'),
      key: "specs",
      render: (plot: any) => (
        <div className="text-xs text-slate-500 space-y-0.5">
          <div><span className="font-medium text-slate-700">{t('dimensions_short')}</span> {plot.dimensions || 'N/A'}</div>
          <div><span className="font-medium text-slate-700">{t('facing_short')}</span> {plot.facing?.en || (typeof plot.facing === 'string' ? plot.facing : 'N/A')}</div>
          <div><span className="font-medium text-slate-700">{t('road_short')}</span> {plot.road?.en || (typeof plot.road === 'string' ? plot.road : 'N/A')}</div>
        </div>
      )
    },
    {
      header: t('status'),
      key: "status",
      render: (plot: any) => (
        <div className="flex items-center space-x-2">
          {statusLoading === plot.id ? (
            <Loader2 className="h-5 w-5 animate-spin text-blue-500" />
          ) : (
            <select
              value={plot.status}
              disabled={plot.status === 'BOOKED_SOLD'}
              onChange={(e) => handleStatusChange(plot.id, e.target.value)}
              className={`
                text-xs font-bold rounded-full px-3 py-1 border outline-none appearance-none cursor-pointer transition-colors
                bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23000%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] 
                bg-[length:0.5rem_0.5rem] bg-[position:right_0.5rem_center] bg-no-repeat pr-6
                ${plot.status === 'AVAILABLE' ? 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100' :
                  plot.status === 'HOLD' ? 'bg-amber-50 text-amber-700 border-amber-200 hover:bg-amber-100' :
                    'bg-red-50 text-red-700 border-red-200 hover:bg-red-100 disabled:opacity-80 disabled:cursor-not-allowed'
                }
              `}
            >
              <option value="AVAILABLE" className="bg-white text-slate-900">{t('status_available')}</option>
              <option value="HOLD" className="bg-white text-slate-900">{t('status_hold')}</option>
              <option value="BOOKED_SOLD" className="bg-white text-slate-900">{t('status_booked_sold')}</option>
            </select>
          )}
        </div>
      )
    },
    ...(user?.role !== 'AGENT' ? [{
      header: t('actions'),
      key: "actions",
      render: (plot: any) => (
        <div className="flex items-center space-x-2">
          {plot.status === 'BOOKED_SOLD' ? (
            !plot.assignedUserId ? (
              <button
                onClick={() => setAssignDialog({ isOpen: true, plot })}
                title={t('assign_plot')}
                className="flex items-center space-x-1 px-3 py-1.5 text-xs font-semibold text-blue-700 bg-blue-50 border border-blue-200 rounded-lg hover:bg-blue-100 transition-colors"
              >
                <UserPlus className="h-4 w-4" />
                <span>{t('assign')}</span>
              </button>
            ) : (
              <span className="text-xs font-bold text-slate-800">
                {assignedUserNames[plot.assignedUserId]
                  ? `${assignedUserNames[plot.assignedUserId]}`
                  : t('no_actions_available')}
              </span>
            )
          ) : (
            <>
              <button
                onClick={() => handleToggleVisibility(plot)}
                title={plot.isActive === false ? t('enable_plot') : t('disable_plot')}
                className={`p-2 rounded-lg transition-colors ${plot.isActive === false
                  ? "text-slate-400 hover:text-green-600 hover:bg-green-50"
                  : "text-blue-600 hover:text-orange-600 hover:bg-orange-50 bg-blue-50"
                  }`}
              >
                {plot.isActive === false ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </button>
              <Link href={`/plots/${plot.id}/edit`}>
                <button title={t('edit_plot')} className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
                  <Edit2 className="h-4 w-4" />
                </button>
              </Link>
              <button
                onClick={() => handleDelete(plot.id, plot.plotNumber)}
                title={t('delete_plot')}
                disabled={deleteLoading === plot.id}
                className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            </>
          )}
        </div>
      )
    }] : [])
  ];

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('plots_management')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('plots') }]}
        actions={
          user?.role !== 'AGENT' && (
            <Link href="/plots/new">
              <Button icon={<Plus className="h-4 w-4" />}>
                {t('add_plot')}
              </Button>
            </Link>
          )
        }
      />

      {/* Toolbar */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <input
            type="text"
            placeholder={t('search_plots_by_number')}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm"
          />
        </div>
        <div className="w-full sm:w-48">
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value)}
            className="block w-full pl-4 pr-10 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%2394A3B8%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:0.75rem_0.75rem] bg-[position:right_1rem_center] bg-no-repeat"
          >
            <option value="">{t('all_statuses')}</option>
            <option value="AVAILABLE">{t('available')}</option>
            <option value="HOLD">{t('hold')}</option>
            <option value="BOOKED_SOLD">{t('booked_sold')}</option>
          </select>
        </div>
        <div className="w-full sm:w-64">
          <select
            value={selectedProjectId}
            onChange={(e) => setSelectedProjectId(e.target.value)}
            className="block w-full pl-4 pr-10 py-2.5 bg-white border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%2394A3B8%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:0.75rem_0.75rem] bg-[position:right_1rem_center] bg-no-repeat"
          >
            <option value="">{t('all_projects')}</option>
            {projects.map((proj: any) => (
              <option key={proj.id} value={proj.id}>{proj.name?.en || (typeof proj.name === 'string' ? proj.name : t('unknown'))}</option>
            ))}
          </select>
        </div>
      </div>

      {loading ? (
        <ShimmerTable rows={6} />
      ) : (
        <DataTable
          columns={columns}
          data={plots}
          isServerSide={true}
          hasNextPage={hasNextPage}
          hasPrevPage={hasPrevPage}
          onNextPage={handleNextPage}
          onPrevPage={handlePrevPage}
          itemsPerPage={10}
          emptyState={
            <EmptyState
              icon={<MapIcon className="h-12 w-12 text-slate-300" />}
              title={t('no_plots_found')}
              description={t('no_plots_desc')}
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
        isLoading={deleteLoading !== null || statusLoading !== null}
      />

      {assignDialog.plot && (
        <AssignPlotDialog
          isOpen={assignDialog.isOpen}
          onClose={() => setAssignDialog({ isOpen: false, plot: null })}
          plot={assignDialog.plot}
          onAssigned={handlePlotAssigned}
        />
      )}
    </div>
  );
}
