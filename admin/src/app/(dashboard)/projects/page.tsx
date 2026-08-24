/* eslint-disable react-hooks/immutability */
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client";

import { useState } from "react";
import api from "@/lib/api";
import { useServerPagination } from "@/hooks/useServerPagination";
import Link from "next/link";
import { Plus, Edit2, Trash2, MapPin, Building2, Search, Filter, Eye, EyeOff } from "lucide-react";
import { useLanguage } from '@/context/LanguageContext';
import { toast } from 'react-hot-toast';
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { StatusBadge } from "@/components/ui/StatusBadge";
import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";
import { ConfirmModal } from "@/components/ui/ConfirmModal";
import { useAuth } from "@/context/AuthContext";

export default function ProjectsListPage() {
  const { t } = useLanguage();
  const { user } = useAuth();

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
  if (statusFilter === "ACTIVE") filters.push({ field: "isActive", operator: "==", value: true });
  if (statusFilter === "INACTIVE") filters.push({ field: "isActive", operator: "==", value: false });
  if (["UPCOMING", "ONGOING", "COMPLETED"].includes(statusFilter)) {
    filters.push({ field: "developmentStatus", operator: "==", value: statusFilter });
  }

  // Detect if the search query contains Hindi characters
  const isHindi = (text: string) => /[\u0900-\u097F]/.test(text);
  const currentSearchField = isHindi(searchQuery) ? "name.hi" : "name.en";

  const {
    data: projects,
    setData: setProjects,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/projects",
    searchField: currentSearchField,
    searchQuery,
    filters,
    capitalizeSearch: true
  });

  async function handleDelete(id: string, name: string) {
    setConfirmModal({
      isOpen: true,
      title: t('delete_project'),
      message: t('delete_project_confirm', { name }),
      isDanger: true,
      confirmText: t('delete'),
      onConfirm: async () => {
        try {
          setDeleteLoading(id);
          await api.delete(`/projects/${id}`);
          setProjects(projects.filter((p: any) => p.id !== id));
          setConfirmModal(prev => ({ ...prev, isOpen: false }));
        } catch (error: any) {
          toast.error(error.response?.data?.message || t('failed_delete_project'));
        } finally {
          setDeleteLoading(null);
        }
      }
    });
  }

  async function handleToggleVisibility(project: any) {
    try {
      const isCurrentlyActive = project.isActive !== false;
      const newStatus = !isCurrentlyActive;

      setProjects(projects.map(p => p.id === project.id ? { ...p, isActive: newStatus } : p));
      await api.put(`/projects/${project.id}`, { ...project, isActive: newStatus });
      toast.success(newStatus ? t('project_enabled_success') : t('project_disabled_success'));
    } catch (error: any) {
      setProjects(projects.map(p => p.id === project.id ? { ...p, isActive: project.isActive } : p));
      toast.error(t('failed_update_project_visibility'));
    }
  }

  const [statusLoading, setStatusLoading] = useState<string | null>(null);

  async function handleStatusChange(projectId: string, newStatusKey: string) {
    try {
      setStatusLoading(projectId);
      const project = projects.find(p => p.id === projectId);
      if (!project) return;

      const statusMap: Record<string, { en: string; hi: string }> = {
        Upcoming: { en: 'Upcoming', hi: 'आगामी' },
        Ongoing: { en: 'Ongoing', hi: 'जारी है' },
        Completed: { en: 'Completed', hi: 'पूर्ण' }
      };

      const newStatusObj = statusMap[newStatusKey] || { en: newStatusKey, hi: newStatusKey };

      const updatedProject = { ...project, developmentStatus: newStatusObj };
      await api.put(`/projects/${projectId}`, updatedProject);

      setProjects(projects.map(p => p.id === projectId ? updatedProject : p));
      toast.success(t('project_status_updated_success'));
    } catch (error) {
      toast.error(t('failed_update_project_status'));
    } finally {
      setStatusLoading(null);
    }
  }

  // Removed client-side filteredProjects array

  const columns = [
    {
      header: t('project'),
      key: "name",
      render: (project: any) => (
        <div className="flex items-center">
          {project.projectPhotos && project.projectPhotos.length > 0 ? (
            <img className="h-12 w-12 rounded-xl object-cover shadow-sm" src={project.projectPhotos[0]} alt={project.name?.en || (typeof project.name === 'string' ? project.name : 'Project')} />
          ) : (
            <div className="h-12 w-12 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center shadow-sm">
              <Building2 className="h-6 w-6 text-slate-400" />
            </div>
          )}
          <div className="ml-4">
            <div className="text-sm font-bold text-slate-900 flex items-center gap-2">
              {project.name?.en || (typeof project.name === 'string' ? project.name : t('project'))}
            </div>
            <div className="text-xs text-slate-500 mt-0.5">{project.plotPrice?.en || (typeof project.plotPrice === 'string' ? project.plotPrice : t('price_unlisted'))}</div>
          </div>
        </div>
      )
    },
    {
      header: t('location'),
      key: "location",
      render: (project: any) => (
        <div className="flex items-center text-sm font-medium text-slate-700">
          <MapPin className="h-4 w-4 mr-1.5 text-slate-400" />
          {project.location?.en || (typeof project.location === 'string' ? project.location : t('location'))}
        </div>
      )
    },
    {
      header: t('available_plots'),
      key: "availablePlots",
      render: (project: any) => (
        <div className="text-sm font-medium text-slate-700">
          {project.availablePlots || '0'}
        </div>
      )
    },
    {
      header: t('status'),
      key: "developmentStatus",
      render: (project: any) => {
        const currentVal = project.developmentStatus?.en || (typeof project.developmentStatus === 'string' ? project.developmentStatus : 'Upcoming');
        return (
          <select
            value={currentVal}
            onChange={(e) => handleStatusChange(project.id, e.target.value)}
            disabled={statusLoading === project.id || user?.role === 'AGENT'}
            className="inline-flex items-center px-2 py-1 rounded-lg text-xs font-medium bg-blue-50 text-blue-800 border border-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50"
          >
            <option value="Upcoming">{t('upcoming')}</option>
            <option value="Ongoing">{t('ongoing')}</option>
            <option value="Completed">{t('completed')}</option>
          </select>
        );
      }
    },
    ...(user?.role !== 'AGENT' ? [{
      header: t('actions'),
      key: "actions",
      render: (project: any) => (
        <div className="flex items-center space-x-2">
          <button
            onClick={() => handleToggleVisibility(project)}
            title={project.isActive === false ? t('enable_project') : t('disable_project')}
            className={`p-2 rounded-lg transition-colors ${project.isActive === false
              ? "text-slate-400 hover:text-green-600 hover:bg-green-50"
              : "text-blue-600 hover:text-orange-600 hover:bg-orange-50 bg-blue-50"
              }`}
          >
            {project.isActive === false ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
          <Link href={`/projects/${project.id}/edit`}>
            <button title={t('edit_project')} className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
              <Edit2 className="h-4 w-4" />
            </button>
          </Link>
          <button
            onClick={() => handleDelete(project.id, project.name?.en || (typeof project.name === 'string' ? project.name : t('project')))}
            title={t('delete_project')}
            disabled={deleteLoading === project.id}
            className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      )
    }] : [])
  ];

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('projects_management')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('projects') }]}
        actions={
          user?.role !== 'AGENT' && (
            <Link href="/projects/new">
              <Button icon={<Plus className="h-4 w-4" />}>
                {t('add_project')}
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
            placeholder={t('search_projects_by_name')}
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
            <option value="ALL">{t('all_projects')}</option>
            <option value="ACTIVE">{t('active_projects')}</option>
            <option value="INACTIVE">{t('hidden_inactive_projects')}</option>
            <option value="UPCOMING">{t('upcoming')}</option>
            <option value="ONGOING">{t('ongoing')}</option>
            <option value="COMPLETED">{t('completed')}</option>
          </select>
        </div>
      </div>

      {loading ? (
        <ShimmerTable rows={5} />
      ) : (
        <DataTable
          columns={columns}
          data={projects}
          isServerSide={true}
          hasNextPage={hasNextPage}
          hasPrevPage={hasPrevPage}
          onNextPage={handleNextPage}
          onPrevPage={handlePrevPage}
          itemsPerPage={10}
          emptyState={
            <EmptyState
              icon={<Building2 className="h-12 w-12 text-slate-300" />}
              title={t('no_projects_found')}
              description={t('no_projects_desc')}
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
    </div>
  );
}
