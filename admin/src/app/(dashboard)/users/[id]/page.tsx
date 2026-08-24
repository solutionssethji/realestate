"use client";

import { useState, useEffect, use } from "react";
import { doc, getDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import api from "@/lib/api";
import { PageHeader } from "@/components/ui/PageHeader";
import { User, Phone, Mail, ShieldAlert, ShieldCheck, FileText, Calendar, MessageSquare, Bookmark, CreditCard } from "lucide-react";
import { toast } from "react-hot-toast";
import { formatDateTime, formatCurrency } from "@/lib/formatters";
import Link from "next/link";

export default function UserDetailsPage({ params: paramsPromise }: { params: Promise<{ id: string }> }) {
  const params = use(paramsPromise);
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [enquiries, setEnquiries] = useState<any[]>([]);
  const [siteVisits, setSiteVisits] = useState<any[]>([]);
  const [bookings, setBookings] = useState<any[]>([]);
  const [activeTab, setActiveTab] = useState("activity"); // 'activity' | 'kyc'

  useEffect(() => {
    async function loadData() {
      try {
        const docSnap = await getDoc(doc(db, "users", params.id));
        if (docSnap.exists()) {
          setUser({ id: docSnap.id, ...docSnap.data() });
        } else {
          toast.error("User not found");
          setLoading(false);
          return;
        }

        // Fetch user activity (no sortField to avoid composite index requirement)
        const filter = [{ field: "customerId", operator: "==", value: params.id }];
        const [enqRes, visitRes, bookRes] = await Promise.allSettled([
          api.get('/enquiries', { filters: filter }),
          api.get('/site-visits', { filters: filter }),
          api.get('/bookings', { filters: filter })
        ]);

        if (enqRes.status === 'fulfilled' && enqRes.value.data.success)
          setEnquiries(enqRes.value.data.data);
        if (visitRes.status === 'fulfilled' && visitRes.value.data.success)
          setSiteVisits(visitRes.value.data.data);
        if (bookRes.status === 'fulfilled' && bookRes.value.data.success)
          setBookings(bookRes.value.data.data);

      } catch (error) {
        console.error(error);
        toast.error("Failed to load user data");
      } finally {
        setLoading(false);
      }
    }
    loadData();
  }, [params.id]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl font-semibold text-slate-800">User not found</h2>
      </div>
    );
  }

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title="User Profile"
        breadcrumbs={[
          { label: "Dashboard", href: "/dashboard" },
          { label: "Users", href: "/users" },
          { label: user.fullName || "User Details" }
        ]}
      />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="col-span-1">
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col items-center text-center">
            <div className="h-24 w-24 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center text-3xl font-bold mb-4">
              {user.fullName?.charAt(0) || <User className="h-10 w-10" />}
            </div>
            <h2 className="text-xl font-bold text-slate-900">{user.fullName}</h2>
            <div className={`mt-2 px-3 py-1 rounded-full text-xs font-bold flex items-center gap-1 ${user.status === 'BLOCKED' ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'
              }`}>
              {user.status === 'BLOCKED' ? <ShieldAlert className="h-3 w-3" /> : <ShieldCheck className="h-3 w-3" />}
              {user.status === 'BLOCKED' ? 'BLOCKED' : 'ACTIVE'}
            </div>
          </div>

          <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 mt-6">
            <h3 className="text-sm font-semibold text-slate-900 mb-4 border-b border-slate-100 pb-2">Contact Details</h3>
            <div className="space-y-4">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-slate-50 rounded-lg text-slate-400">
                  <Phone className="h-4 w-4" />
                </div>
                <div>
                  <p className="text-xs font-medium text-slate-500">Mobile Number</p>
                  <p className="text-sm font-semibold text-slate-900">{user.mobileNumber || 'N/A'}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="p-2 bg-slate-50 rounded-lg text-slate-400">
                  <Mail className="h-4 w-4" />
                </div>
                <div>
                  <p className="text-xs font-medium text-slate-500">Email</p>
                  <p className="text-sm font-semibold text-slate-900">{user.email || 'N/A'}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="col-span-1 md:col-span-2">
          <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
            <div className="flex border-b border-slate-100">
              <button
                onClick={() => setActiveTab('activity')}
                className={`flex-1 py-4 text-sm font-semibold text-center transition-colors ${activeTab === 'activity' ? 'bg-slate-50 text-blue-600 border-b-2 border-blue-600' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-700'}`}
              >
                Activity History
              </button>
              <button
                onClick={() => setActiveTab('kyc')}
                className={`flex-1 py-4 text-sm font-semibold text-center transition-colors ${activeTab === 'kyc' ? 'bg-slate-50 text-blue-600 border-b-2 border-blue-600' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-700'}`}
              >
                KYC & Documents
              </button>
            </div>

            <div className="p-6">
              {activeTab === 'activity' && (
                <div className="space-y-8">
                  {/* Bookings */}
                  <div>
                    <h3 className="text-md font-bold text-slate-900 mb-4 flex items-center gap-2">
                      <Bookmark className="h-5 w-5 text-blue-500" /> Purchased Plots ({bookings.length})
                    </h3>
                    {bookings.length === 0 ? (
                      <p className="text-sm text-slate-500">No plots purchased yet.</p>
                    ) : (
                      <div className="space-y-3">
                        {bookings.map(b => (
                          <Link href={`/bookings/${b.id}`} key={b.id} className="block p-4 rounded-xl border border-slate-100 hover:border-blue-200 hover:shadow-sm transition-all group">
                            <div className="flex justify-between items-start">
                              <div>
                                <p className="font-semibold text-slate-900 group-hover:text-blue-600 transition-colors">{b.projectName}</p>
                                <p className="text-sm text-slate-500 mt-0.5">Plot {b.plotNumber}</p>
                              </div>
                              <div className="text-right">
                                <p className="text-sm font-bold text-slate-900">{formatCurrency(b.totalAmount || 0)}</p>
                                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full mt-1 inline-block uppercase ${b.status === 'SOLD' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'}`}>{b.status}</span>
                              </div>
                            </div>
                          </Link>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Site Visits */}
                  <div>
                    <h3 className="text-md font-bold text-slate-900 mb-4 flex items-center gap-2">
                      <Calendar className="h-5 w-5 text-indigo-500" /> Site Visits ({siteVisits.length})
                    </h3>
                    {siteVisits.length === 0 ? (
                      <p className="text-sm text-slate-500">No site visits scheduled.</p>
                    ) : (
                      <div className="space-y-3">
                        {siteVisits.map(v => (
                          <div key={v.id} className="p-3 bg-slate-50 rounded-xl border border-slate-100 flex justify-between items-center">
                            <div>
                              <p className="text-sm font-semibold text-slate-900">{v.projectName || 'General Visit'}</p>
                              <p className="text-xs text-slate-500 mt-0.5">Requested for: {formatDateTime(v.preferredDate)}</p>
                            </div>
                            <span className="text-xs font-bold bg-slate-200 text-slate-700 px-2 py-1 rounded-full">{v.status}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Enquiries */}
                  <div>
                    <h3 className="text-md font-bold text-slate-900 mb-4 flex items-center gap-2">
                      <MessageSquare className="h-5 w-5 text-green-500" /> Enquiries ({enquiries.length})
                    </h3>
                    {enquiries.length === 0 ? (
                      <p className="text-sm text-slate-500">No enquiries submitted.</p>
                    ) : (
                      <div className="space-y-3">
                        {enquiries.map(e => (
                          <div key={e.id} className="p-3 bg-slate-50 rounded-xl border border-slate-100">
                            <div className="flex justify-between items-start mb-2">
                              <p className="text-sm font-semibold text-slate-900">{e.projectName || 'General Enquiry'}</p>
                              <span className="text-xs font-bold bg-slate-200 text-slate-700 px-2 py-1 rounded-full">{e.status}</span>
                            </div>
                            <p className="text-xs text-slate-600 line-clamp-2">{e.message}</p>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              )}

              {activeTab === 'kyc' && (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-sm font-semibold text-slate-900 mb-3 flex items-center gap-2">
                      <FileText className="h-4 w-4 text-blue-500" /> Identity Documents
                    </h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div className="p-4 bg-slate-50 rounded-xl border border-slate-100">
                        <p className="text-xs text-slate-500 font-medium mb-1 uppercase">PAN Card</p>
                        <p className="font-semibold text-slate-900">{user.panNumber || 'Not Provided'}</p>
                        {user.panPhotoUrl && (
                          <a href={user.panPhotoUrl} target="_blank" rel="noopener noreferrer" className="text-xs text-blue-600 font-medium hover:underline mt-2 inline-block">
                            View Document
                          </a>
                        )}
                      </div>
                      <div className="p-4 bg-slate-50 rounded-xl border border-slate-100">
                        <p className="text-xs text-slate-500 font-medium mb-1 uppercase">Aadhar Card</p>
                        <p className="font-semibold text-slate-900">{user.aadharNumber || 'Not Provided'}</p>
                        {user.aadharPhotoUrl && (
                          <a href={user.aadharPhotoUrl} target="_blank" rel="noopener noreferrer" className="text-xs text-blue-600 font-medium hover:underline mt-2 inline-block">
                            View Document
                          </a>
                        )}
                      </div>
                    </div>
                  </div>

                  <div>
                    <h3 className="text-sm font-semibold text-slate-900 mb-3 flex items-center gap-2">
                      <CreditCard className="h-4 w-4 text-blue-500" /> Bank Details
                    </h3>
                    <div className="p-4 bg-slate-50 rounded-xl border border-slate-100">
                      {user.bankDetails ? (
                        <div className="space-y-2 text-sm">
                          <p><span className="text-slate-500">Bank Name:</span> <span className="font-medium text-slate-900">{user.bankDetails.bankName || 'N/A'}</span></p>
                          <p><span className="text-slate-500">Account No:</span> <span className="font-medium text-slate-900">{user.bankDetails.accountNumber || 'N/A'}</span></p>
                          <p><span className="text-slate-500">IFSC Code:</span> <span className="font-medium text-slate-900">{user.bankDetails.ifscCode || 'N/A'}</span></p>
                        </div>
                      ) : (
                        <p className="text-sm text-slate-500">Bank details not provided.</p>
                      )}
                    </div>
                  </div>

                  {(!user.panNumber && !user.aadharNumber && !user.bankDetails) && (
                    <div className="p-6 bg-yellow-50 text-yellow-800 rounded-xl border border-yellow-100 text-center text-sm font-medium">
                      No KYC documents have been uploaded by this user yet.
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
