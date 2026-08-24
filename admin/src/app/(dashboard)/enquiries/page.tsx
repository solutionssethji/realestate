"use client";

import { useState, useEffect, Suspense } from "react";
import { doc, updateDoc, getDoc, collection, getDocs } from "firebase/firestore";
import { db } from "@/lib/firebase";
import api from "@/lib/api";
import { useServerPagination } from "@/hooks/useServerPagination";
import { PhoneIncoming, Loader2, Search, Eye, User } from "lucide-react";
import { toast } from "react-hot-toast";
import { useSearchParams } from "next/navigation";
import { useLanguage } from '@/context/LanguageContext';
import { PageHeader } from "@/components/ui/PageHeader";
import { DataTable } from "@/components/ui/DataTable";
import { ShimmerTable } from "@/components/ui/Shimmer";
import { EmptyState } from "@/components/ui/EmptyState";
import { Button } from "@/components/ui/Button";
import { Modal } from "@/components/ui/Modal";
import { Select } from "@/components/ui/Select";
import { formatDateTime } from "@/lib/formatters";

type Enquiry = {
  id: string;
  customerId: string;
  projectId?: string;
  plotId?: string;
  plotRequirement?: string;
  budget?: string;
  message?: string;
  status: string;
  createdAt: any;
};

type UserInfo = {
  fullName: string;
  mobileNumber: string;
  email?: string;
};

const PAGE_SIZE = 15;

function EnquiriesContent() {
  const { t } = useLanguage();
  const searchParams = useSearchParams();
  const notificationId = searchParams.get('id');

  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");

  const [selectedEnquiry, setSelectedEnquiry] = useState<Enquiry | null>(null);
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
    data: enquiries,
    setData: setEnquiries,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage
  } = useServerPagination({
    endpoint: "/enquiries",
    searchField: "customerId",
    searchQuery,
    filters,
    capitalizeSearch: false
  });

  // Batch-fetch user and project info when enquiries change
  useEffect(() => {
    if (!enquiries || enquiries.length === 0) return;

    // Fetch users
    const userIdsToFetch = [
      ...new Set(
        enquiries
          .map((e: Enquiry) => e.customerId)
          .filter((id: string) => id && !userCache[id])
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
        enquiries
          .map((e: Enquiry) => e.projectId)
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
  }, [enquiries]);

  useEffect(() => {
    if (notificationId) {
      loadSpecificEnquiry(notificationId);
    }
  }, [notificationId]);

  const loadSpecificEnquiry = async (id: string) => {
    try {
      const docSnap = await getDoc(doc(db, "enquiries", id));
      if (docSnap.exists()) {
        const enq = { id: docSnap.id, ...docSnap.data() } as Enquiry;
        setSelectedEnquiry(enq);
        // Also fetch user if not in cache
        if (enq.customerId && !userCache[enq.customerId]) {
          const userSnap = await getDoc(doc(db, "users", enq.customerId));
          if (userSnap.exists()) {
            const d = userSnap.data();
            setUserCache((prev) => ({
              ...prev,
              [enq.customerId]: { fullName: d.fullName || d.name || "Unknown", mobileNumber: d.mobileNumber || "—", email: d.email }
            }));
          }
        }
        // Also fetch project if not in cache
        if (enq.projectId && !projectCache[enq.projectId]) {
          const projectSnap = await getDoc(doc(db, "projects", enq.projectId));
          if (projectSnap.exists()) {
            setProjectCache((prev) => ({
              ...prev,
              [enq.projectId!]: projectSnap.data()
            }));
          }
        }
      }
    } catch (error) {
      console.error("Failed to load specific enquiry", error);
    }
  };

  const [statusLoading, setStatusLoading] = useState<string | null>(null);

  const handleQuickStatusUpdate = async (id: string, newStatus: string) => {
    setStatusLoading(id);
    try {
      await updateDoc(doc(db, "enquiries", id), {
        status: newStatus,
        updatedAt: new Date().toISOString()
      });
      toast.success(t('enquiry_status_updated'));
      setEnquiries(enquiries.map((e: Enquiry) => e.id === id ? { ...e, status: newStatus } : e));
    } catch (error) {
      toast.error(t('failed_update_enquiry_status'));
    } finally {
      setStatusLoading(null);
    }
  };

  const handleStatusUpdate = async (newStatus: string) => {
    if (!selectedEnquiry) return;
    setUpdating(true);
    try {
      await updateDoc(doc(db, "enquiries", selectedEnquiry.id), {
        status: newStatus,
        updatedAt: new Date().toISOString()
      });
      toast.success(t('enquiry_status_updated'));
      setSelectedEnquiry({ ...selectedEnquiry, status: newStatus });
      setEnquiries(enquiries.map((e: Enquiry) => e.id === selectedEnquiry.id ? { ...e, status: newStatus } : e));
    } catch (error) {
      toast.error(t('failed_update_enquiry_status'));
    } finally {
      setUpdating(false);
    }
  };

  const columns = [
    {
      header: t('date'),
      key: "createdAt",
      render: (enq: Enquiry) => {
        const fullStr = formatDateTime(enq.createdAt);
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
      header: t('customer'),
      key: "customerId",
      render: (enq: Enquiry) => {
        const user = userCache[enq.customerId];
        return (
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-full bg-blue-50 flex items-center justify-center flex-shrink-0">
              <User className="h-4 w-4 text-blue-500" />
            </div>
            <div>
              <div className="font-bold text-slate-900">
                {user ? user.fullName : <span className="text-slate-400 italic text-xs">{t('loading_ellipsis')}</span>}
              </div>
              {user?.email && <div className="text-xs text-slate-500 mt-0.5">{user.email}</div>}
            </div>
          </div>
        );
      }
    },
    {
      header: t('mobile'),
      key: "mobileNumber",
      render: (enq: Enquiry) => {
        const user = userCache[enq.customerId];
        return (
          <span className="font-medium text-slate-700">
            {user ? user.mobileNumber : <span className="text-slate-300">—</span>}
          </span>
        );
      }
    },
    {
      header: t('project'),
      key: "project",
      render: (enq: Enquiry) => {
        const project = enq.projectId ? projectCache[enq.projectId] : null;
        const projectName = project?.name?.en || (typeof project?.name === 'string' ? project.name : null);
        
        return (
          <div>
            {projectName ? (
              <span className="font-bold text-blue-900">{projectName}</span>
            ) : enq.projectId ? (
              <span className="font-bold text-blue-900">{enq.projectId}</span>
            ) : enq.plotId ? (
              <span className="font-bold text-slate-700">{t('plot_id')}: {enq.plotId}</span>
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
      render: (enq: Enquiry) => (
        <div className="flex items-center space-x-2">
          {statusLoading === enq.id ? (
            <div className="h-5 w-5 animate-spin rounded-full border-b-2 border-blue-500"></div>
          ) : (
            <select
              value={enq.status}
              onChange={(e) => handleQuickStatusUpdate(enq.id, e.target.value)}
              className="text-xs font-bold rounded-full px-3 py-1 border outline-none appearance-none cursor-pointer transition-colors bg-slate-50 text-slate-700 border-slate-200 hover:bg-slate-100 pr-6 bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23000%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:0.5rem_0.5rem] bg-[position:right_0.5rem_center] bg-no-repeat"
            >
              <option value="NEW">{t('new_status')}</option>
              <option value="CONTACTED">{t('contacted')}</option>
              <option value="FOLLOW_UP">{t('follow_up')}</option>
              <option value="IN_PROGRESS">{t('in_progress')}</option>
              <option value="RESOLVED">{t('resolved')}</option>
              <option value="CLOSED">{t('closed')}</option>
            </select>
          )}
        </div>
      )
    },
    {
      header: t('actions'),
      key: "actions",
      render: (enq: Enquiry) => (
        <button
          onClick={() => setSelectedEnquiry(enq)}
          className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
        >
          <Eye className="h-5 w-5" />
        </button>
      )
    }
  ];

  const selectedUser = selectedEnquiry ? userCache[selectedEnquiry.customerId] : null;
  const selectedProject = (selectedEnquiry && selectedEnquiry.projectId) ? projectCache[selectedEnquiry.projectId] : null;
  const projectName = selectedProject?.name?.en || (typeof selectedProject?.name === 'string' ? selectedProject.name : null);

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('customer_enquiries')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('enquiries') }]}
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
            <option value="CONTACTED">{t('contacted')}</option>
            <option value="FOLLOW_UP">{t('follow_up')}</option>
            <option value="IN_PROGRESS">{t('in_progress')}</option>
            <option value="RESOLVED">{t('resolved')}</option>
            <option value="CLOSED">{t('closed')}</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
        {loading && enquiries.length === 0 ? (
          <ShimmerTable rows={8} />
        ) : (
          <DataTable
            columns={columns}
            data={enquiries}
            isServerSide={true}
            hasNextPage={hasNextPage}
            hasPrevPage={hasPrevPage}
            onNextPage={handleNextPage}
            onPrevPage={handlePrevPage}
            itemsPerPage={10}
            emptyState={
              <EmptyState
                icon={<PhoneIncoming className="h-12 w-12 text-slate-300" />}
                title={t('no_enquiries')}
                description={t('no_enquiries_desc')}
              />
            }
          />
        )}
      </div>

      {/* Details Modal */}
      {selectedEnquiry && (
        <Modal
          isOpen={!!selectedEnquiry}
          onClose={() => setSelectedEnquiry(null)}
          title={t('enquiry_details')}
          maxWidth="lg"
          footer={
            <Button variant="secondary" onClick={() => setSelectedEnquiry(null)}>
              {t('close')}
            </Button>
          }
        >
          <div className="space-y-6">
            {/* Customer Info — resolved from users collection */}
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
              {selectedUser?.email && (
                <div className="col-span-2">
                  <p className="text-xs font-semibold text-slate-500 uppercase">{t('email')}</p>
                  <p className="text-sm font-bold text-slate-900 mt-1">{selectedUser.email}</p>
                </div>
              )}
            </div>

            {(selectedEnquiry.projectId || selectedEnquiry.plotId || selectedEnquiry.plotRequirement || selectedEnquiry.budget) && (
              <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100 grid grid-cols-2 gap-4">
                {selectedEnquiry.projectId && (
                  <div>
                    <p className="text-xs font-semibold text-blue-600 uppercase">{t('project')}</p>
                    <p className="text-sm font-bold text-blue-900 mt-1">
                      {projectName || selectedEnquiry.projectId}
                    </p>
                  </div>
                )}
                {selectedEnquiry.plotId && (
                  <div>
                    <p className="text-xs font-semibold text-blue-600 uppercase">{t('plot_id')}</p>
                    <p className="text-sm font-bold text-blue-900 mt-1">{selectedEnquiry.plotId}</p>
                  </div>
                )}
                {selectedEnquiry.plotRequirement && (
                  <div className="col-span-2 sm:col-span-1">
                    <p className="text-xs font-semibold text-blue-600 uppercase">{t('plot_requirement')}</p>
                    <p className="text-sm font-bold text-blue-900 mt-1">{selectedEnquiry.plotRequirement}</p>
                  </div>
                )}
                {selectedEnquiry.budget && (
                  <div className="col-span-2 sm:col-span-1">
                    <p className="text-xs font-semibold text-blue-600 uppercase">{t('budget')}</p>
                    <p className="text-sm font-bold text-blue-900 mt-1">{selectedEnquiry.budget}</p>
                  </div>
                )}
              </div>
            )}

            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase mb-2">{t('message')}</p>
              <div className="p-4 bg-slate-50 rounded-xl border border-slate-100 text-sm text-slate-700 leading-relaxed">
                {selectedEnquiry.message || t('no_message_provided')}
              </div>
            </div>

            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase mb-2">{t('update_status')}</p>
              <Select
                options={[
                  { value: 'NEW', label: t('new_status') },
                  { value: 'CONTACTED', label: t('contacted') },
                  { value: 'FOLLOW_UP', label: t('follow_up') },
                  { value: 'IN_PROGRESS', label: t('in_progress') },
                  { value: 'RESOLVED', label: t('resolved') },
                  { value: 'CLOSED', label: t('closed') },
                ]}
                value={selectedEnquiry.status}
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

export default function EnquiriesPage() {
  return (
    <Suspense fallback={<ShimmerTable rows={8} />}>
      <EnquiriesContent />
    </Suspense>
  );
}
