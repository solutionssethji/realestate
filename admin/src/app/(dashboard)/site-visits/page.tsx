"use client";

import { useState, useEffect, Suspense } from "react";
import { doc, updateDoc, getDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { useServerPagination } from "@/hooks/useServerPagination";
import { CalendarCheck, Search, Eye, User } from "lucide-react";
import { toast } from "react-hot-toast";
import { sendNotificationToUser } from "@/app/actions/notifications";
import { useSearchParams } from "next/navigation";
import { useLanguage } from '@/context/LanguageContext';
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";
import { Modal } from "@/components/ui/Modal";
import { Select } from "@/components/ui/Select";

type SiteVisit = {
  id: string;
  customerId?: string;
  customerName?: string;
  mobileNumber?: string;
  email?: string;
  projectId?: string;
  preferredDate?: string;
  preferredTime?: string;
  message?: string;
  status: string;
  createdAt: any;
};

type UserInfo = {
  fullName: string;
  mobileNumber: string;
  email?: string;
};


function SiteVisitsContent() {
  const { t } = useLanguage();
  const searchParams = useSearchParams();
  const notificationId = searchParams.get('id');

  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [selectedVisit, setSelectedVisit] = useState<SiteVisit | null>(null);
  const [updating, setUpdating] = useState(false);

  // Cache of customerId → user info
  const [userCache, setUserCache] = useState<Record<string, UserInfo>>({});
  // Cache of projectId → project info
  const [projectCache, setProjectCache] = useState<Record<string, any>>({});

  const filters: any[] = [];
  if (statusFilter !== "ALL") {
    filters.push({ field: "status", operator: "==", value: statusFilter });
  }

  const {
    data: siteVisits,
    setData: setSiteVisits,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/site-visits",
    searchField: "customerId",
    searchQuery,
    filters,
    capitalizeSearch: false
  });

  // Batch-fetch user and project info
  useEffect(() => {
    if (!siteVisits || siteVisits.length === 0) return;

    // Fetch users
    const userIdsToFetch = [
      ...new Set(
        siteVisits
          .map((v: SiteVisit) => v.customerId)
          .filter((id: string | undefined) => id && !userCache[id])
      )
    ] as string[];

    if (userIdsToFetch.length > 0) {
      Promise.allSettled(
        userIdsToFetch.map(async (id) => {
          const docSnap = await getDoc(doc(db, "users", id));
          if (docSnap.exists()) {
            const d = docSnap.data();
            return { id, info: { fullName: d.fullName || d.name || "Unknown", mobileNumber: d.mobileNumber || "—", email: d.email } };
          }
          return { id, info: { fullName: "Unknown User", mobileNumber: "—" } };
        })
      ).then((results) => {
        const newEntries: Record<string, UserInfo> = {};
        results.forEach((r) => {
          if (r.status === "fulfilled" && r.value) {
            newEntries[r.value.id] = r.value.info;
          }
        });
        setUserCache((prev) => ({ ...prev, ...newEntries }));
      });
    }

    // Fetch projects
    const projectIdsToFetch = [
      ...new Set(
        siteVisits
          .map((v: SiteVisit) => v.projectId)
          .filter((id: string | undefined) => id && !projectCache[id])
      )
    ] as string[];

    if (projectIdsToFetch.length > 0) {
      Promise.allSettled(
        projectIdsToFetch.map(async (id) => {
          const docSnap = await getDoc(doc(db, "projects", id));
          if (docSnap.exists()) {
            return { id, info: docSnap.data() };
          }
          return { id, info: null };
        })
      ).then((results) => {
        const newEntries: Record<string, any> = {};
        results.forEach((r) => {
          if (r.status === "fulfilled" && r.value) {
            newEntries[r.value.id] = r.value.info;
          }
        });
        setProjectCache((prev) => ({ ...prev, ...newEntries }));
      });
    }

  }, [siteVisits]);

  useEffect(() => {
    if (notificationId) {
      loadSpecificVisit(notificationId);
    }
  }, [notificationId]);

  const loadSpecificVisit = async (id: string) => {
    try {
      const docSnap = await getDoc(doc(db, "siteVisits", id));
      if (docSnap.exists()) {
        const visit = { id: docSnap.id, ...docSnap.data() } as SiteVisit;
        setSelectedVisit(visit);

        // Also fetch user if not in cache
        if (visit.customerId && !userCache[visit.customerId]) {
          const userSnap = await getDoc(doc(db, "users", visit.customerId));
          if (userSnap.exists()) {
            const d = userSnap.data();
            setUserCache((prev) => ({
              ...prev,
              [visit.customerId!]: { fullName: d.fullName || d.name || "Unknown", mobileNumber: d.mobileNumber || "—", email: d.email }
            }));
          }
        }

        // Also fetch project if not in cache
        if (visit.projectId && !projectCache[visit.projectId]) {
          const projectSnap = await getDoc(doc(db, "projects", visit.projectId));
          if (projectSnap.exists()) {
            setProjectCache((prev) => ({
              ...prev,
              [visit.projectId!]: projectSnap.data()
            }));
          }
        }
      }
    } catch (error) {
      console.error("Failed to load specific visit", error);
    }
  };

  const [statusLoading, setStatusLoading] = useState<string | null>(null);

  const handleQuickStatusUpdate = async (id: string, newStatus: string) => {
    setStatusLoading(id);
    try {
      await updateDoc(doc(db, "siteVisits", id), {
        status: newStatus,
        updatedAt: new Date().toISOString()
      });

      const visit = siteVisits.find((v: SiteVisit) => v.id === id);
      if (visit && visit.customerId) {
        await sendNotificationToUser(
          visit.customerId,
          "SITE_VISIT_UPDATE",
          "Site Visit Status Updated",
          `Your site visit status has been updated to ${newStatus}.`,
          { siteVisitId: id, status: newStatus },
          id
        );
      }

      toast.success(t('site_visit_status_updated'));
      setSiteVisits(siteVisits.map((v: SiteVisit) => v.id === id ? { ...v, status: newStatus } : v));
    } catch (error) {
      toast.error(t('failed_update_enquiry_status'));
    } finally {
      setStatusLoading(null);
    }
  };

  const handleStatusUpdate = async (newStatus: string) => {
    if (!selectedVisit) return;
    setUpdating(true);
    try {
      await updateDoc(doc(db, "siteVisits", selectedVisit.id), {
        status: newStatus,
        updatedAt: new Date().toISOString()
      });

      if (selectedVisit.customerId) {
        await sendNotificationToUser(
          selectedVisit.customerId,
          "SITE_VISIT_UPDATE",
          "Site Visit Status Updated",
          `Your site visit status has been updated to ${newStatus}.`,
          { siteVisitId: selectedVisit.id, status: newStatus },
          selectedVisit.id
        );
      }

      toast.success(t('site_visit_status_updated'));
      setSelectedVisit({ ...selectedVisit, status: newStatus });
      setSiteVisits(siteVisits.map((v: SiteVisit) => v.id === selectedVisit.id ? { ...v, status: newStatus } : v));
    } catch (error) {
      toast.error(t('failed_update_enquiry_status'));
    } finally {
      setUpdating(false);
    }
  };

  // Filtered dynamically by useServerPagination

  const columns = [
    {
      header: t('date_time'),
      key: "preferredDate",
      render: (visit: SiteVisit) => {
        let dateStr = "N/A";
        try {
          if (visit.preferredDate) {
            const d = new Date(visit.preferredDate);
            if (!isNaN(d.getTime())) {
              dateStr = d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
            }
          }
        } catch (e) { }

        return (
          <div>
            <div className="font-bold text-slate-900">{dateStr}</div>
            <div className="text-xs text-slate-500 mt-0.5">{visit.preferredTime || t('time_not_specified')}</div>
          </div>
        );
      }
    },
    {
      header: t('customer'),
      key: "customerId",
      render: (visit: SiteVisit) => {
        const user = visit.customerId ? userCache[visit.customerId] : null;
        const name = user ? user.fullName : (visit.customerName || "Unknown");
        const email = user?.email || visit.email;
        return (
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-full bg-blue-50 flex items-center justify-center flex-shrink-0">
              <User className="h-4 w-4 text-blue-500" />
            </div>
            <div>
              <div className="font-bold text-slate-900">
                {name}
              </div>
              {email && <div className="text-xs text-slate-500 mt-0.5">{email}</div>}
            </div>
          </div>
        );
      }
    },
    {
      header: t('mobile'),
      key: "mobileNumber",
      render: (visit: SiteVisit) => {
        const user = visit.customerId ? userCache[visit.customerId] : null;
        const mobile = user ? user.mobileNumber : (visit.mobileNumber || "—");
        return (
          <span className="font-medium text-slate-700">
            {mobile}
          </span>
        );
      }
    },
    {
      header: t('project'),
      key: "project",
      render: (visit: SiteVisit) => {
        const project = visit.projectId ? projectCache[visit.projectId] : null;
        const projectName = project?.name?.en || (typeof project?.name === 'string' ? project.name : null);
        
        return (
          <div>
            {projectName ? (
              <span className="font-bold text-blue-900">{projectName}</span>
            ) : visit.projectId ? (
              <span className="font-bold text-blue-900">{visit.projectId}</span>
            ) : (
              <span className="text-slate-400">—</span>
            )}
          </div>
        );
      }
    },
    {
      header: t('status'),
      key: "status",
      render: (visit: SiteVisit) => (
        <div className="flex items-center space-x-2">
          {statusLoading === visit.id ? (
            <div className="h-5 w-5 animate-spin rounded-full border-b-2 border-blue-500"></div>
          ) : (
            <select
              value={visit.status}
              onChange={(e) => handleQuickStatusUpdate(visit.id, e.target.value)}
              className="text-xs font-bold rounded-full px-3 py-1 border outline-none appearance-none cursor-pointer transition-colors bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100 pr-6 bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23000%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:0.5rem_0.5rem] bg-[position:right_0.5rem_center] bg-no-repeat"
            >
              <option value="NEW">{t('new_status')}</option>
              <option value="CONFIRMED">{t('confirmed')}</option>
              <option value="COMPLETED">{t('completed')}</option>
              <option value="CANCELLED">{t('cancelled')}</option>
            </select>
          )}
        </div>
      )
    },
    {
      header: t('actions'),
      key: "actions",
      render: (visit: SiteVisit) => (
        <button
          onClick={() => setSelectedVisit(visit)}
          className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
        >
          <Eye className="h-5 w-5" />
        </button>
      )
    }
  ];

  const selectedUser = (selectedVisit && selectedVisit.customerId) ? userCache[selectedVisit.customerId] : null;
  const selectedProject = (selectedVisit && selectedVisit.projectId) ? projectCache[selectedVisit.projectId] : null;
  const projectName = selectedProject?.name?.en || (typeof selectedProject?.name === 'string' ? selectedProject.name : null);

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('site_visits')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('site_visits') }]}
      />

      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <input
            type="text"
            placeholder={t('search_by_customer_id')}
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
            <option value="ALL">{t('all_statuses')}</option>
            <option value="NEW">{t('new_status')}</option>
            <option value="CONFIRMED">{t('confirmed')}</option>
            <option value="COMPLETED">{t('completed')}</option>
            <option value="CANCELLED">{t('cancelled')}</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        {loading && siteVisits.length === 0 ? (
          <ShimmerTable rows={8} />
        ) : (
          <DataTable
            columns={columns}
            data={siteVisits}
            isServerSide={true}
            hasNextPage={hasNextPage}
            hasPrevPage={hasPrevPage}
            onNextPage={handleNextPage}
            onPrevPage={handlePrevPage}
            itemsPerPage={10}
            emptyState={
              <EmptyState
                icon={<CalendarCheck className="h-12 w-12 text-slate-300" />}
                title={t('no_site_visits')}
                description={t('no_site_visits_desc')}
              />
            }
          />
        )}
      </div>

      {/* Details Modal */}
      {selectedVisit && (
        <Modal
          isOpen={!!selectedVisit}
          onClose={() => setSelectedVisit(null)}
          title={t('site_visit_details')}
          maxWidth="lg"
          footer={
            <Button variant="secondary" onClick={() => setSelectedVisit(null)}>
              {t('close')}
            </Button>
          }
        >
          <div className="space-y-6">
            <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs font-semibold text-slate-500 uppercase">{t('customer_name')}</p>
                <p className="text-sm font-bold text-slate-900 mt-1">
                  {selectedUser ? selectedUser.fullName : (
                    <span className="italic text-slate-400">{t('loading_ellipsis')}</span>
                  )}
                </p>
              </div>
              <div>
                <p className="text-xs font-semibold text-slate-500 uppercase">{t('mobile_number')}</p>
                <p className="text-sm font-bold text-slate-900 mt-1">
                  {selectedUser ? selectedUser.mobileNumber : "—"}
                </p>
              </div>
              <div className="col-span-2">
                <p className="text-xs font-semibold text-slate-500 uppercase">{t('email')}</p>
                <p className="text-sm font-bold text-slate-900 mt-1">{selectedUser?.email || selectedVisit.email || "—"}</p>
              </div>
            </div>

            <div className="bg-purple-50/50 p-4 rounded-xl border border-purple-100 grid grid-cols-2 gap-4">
              <div>
                <p className="text-xs font-semibold text-purple-600 uppercase">{t('preferred_date')}</p>
                <p className="text-sm font-bold text-purple-900 mt-1">{selectedVisit.preferredDate || t('not_provided')}</p>
              </div>
              <div>
                <p className="text-xs font-semibold text-purple-600 uppercase">{t('preferred_time')}</p>
                <p className="text-sm font-bold text-purple-900 mt-1">{selectedVisit.preferredTime || t('not_provided')}</p>
              </div>
            </div>

            {selectedVisit.projectId && (
              <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100">
                <p className="text-xs font-semibold text-blue-600 uppercase">{t('interested_project')}</p>
                <p className="text-sm font-bold text-blue-900 mt-1">
                  {projectName || selectedVisit.projectId}
                </p>
              </div>
            )}

            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase mb-2">{t('message')}</p>
              <div className="p-4 bg-slate-50 rounded-xl border border-slate-100 text-sm text-slate-700 leading-relaxed">
                {selectedVisit.message || t('no_message_provided')}
              </div>
            </div>

            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase mb-2">{t('update_status')}</p>
              <Select
                options={[
                  { value: 'NEW', label: t('new_status') },
                  { value: 'CONFIRMED', label: t('confirmed') },
                  { value: 'COMPLETED', label: t('completed') },
                  { value: 'CANCELLED', label: t('cancelled') },
                ]}
                value={selectedVisit.status}
                onChange={(e) => handleStatusUpdate(e.target.value)}
                disabled={updating}
              />
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}

export default function SiteVisitsPage() {
  return (
    <Suspense fallback={<ShimmerTable rows={8} />}>
      <SiteVisitsContent />
    </Suspense>
  );
}
