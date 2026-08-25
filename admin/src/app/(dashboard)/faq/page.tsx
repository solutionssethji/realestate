"use client";

import { useState, useEffect } from "react";
import { collection, getDocs, doc, setDoc, deleteDoc, updateDoc, query } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { HelpCircle, Plus, Edit2, Trash2, Loader2, Save, Eye, EyeOff } from "lucide-react";
import { toast } from "react-hot-toast";
import { useLanguage } from '@/context/LanguageContext';
import { PageHeader } from "@/components/ui/PageHeader";
import { Button } from "@/components/ui/Button";
import { Modal } from "@/components/ui/Modal";
import { ConfirmModal } from "@/components/ui/ConfirmModal";

type Faq = {
  id: string;
  question: { en: string; hi: string };
  answer: { en: string; hi: string };
  active: boolean;
};

export default function FaqPage() {
  const { t } = useLanguage();
  const [faqs, setFaqs] = useState<Faq[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [saving, setSaving] = useState(false);

  const [confirmModal, setConfirmModal] = useState<{
    isOpen: boolean;
    id: string;
  }>({ isOpen: false, id: "" });
  const [deleteLoading, setDeleteLoading] = useState(false);

  // Form State
  const [editingId, setEditingId] = useState<string | null>(null);
  const [qEn, setQEn] = useState("");
  const [qHi, setQHi] = useState("");
  const [aEn, setAEn] = useState("");
  const [aHi, setAHi] = useState("");
  const [isActive, setIsActive] = useState(true);
  const [errors, setErrors] = useState<{ qEn?: string, aEn?: string, qHi?: string, aHi?: string }>({});

  useEffect(() => {
    fetchFaqs();
  }, []);

  const fetchFaqs = async () => {
    setLoading(true);
    try {
      const q = query(collection(db, "faqs"));
      const snapshot = await getDocs(q);
      const fetched: Faq[] = [];
      snapshot.forEach((doc) => {
        fetched.push({ id: doc.id, ...doc.data() } as Faq);
      });
      setFaqs(fetched);
    } catch (error: any) {
      console.error(error);
      // Suppress missing index or permission errors if collection is empty
      if (error?.code !== 'permission-denied') {
        toast.error(error?.message || t('failed_save_faq'));
      }
    } finally {
      setLoading(false);
    }
  };

  const openNewFaqModal = () => {
    setEditingId(null);
    setQEn("");
    setQHi("");
    setAEn("");
    setAHi("");
    setIsActive(true);
    setErrors({});
    setIsModalOpen(true);
  };

  const openEditModal = (faq: Faq) => {
    setEditingId(faq.id);
    setQEn(faq.question?.en || "");
    setQHi(faq.question?.hi || "");
    setAEn(faq.answer?.en || "");
    setAHi(faq.answer?.hi || "");
    setAHi(faq.answer?.hi || "");
    setIsActive(faq.active ?? true);
    setErrors({});
    setIsModalOpen(true);
  };

  const handleSave = async () => {
    const newErrors: { qEn?: string, aEn?: string, qHi?: string, aHi?: string } = {};
    if (!qEn.trim()) newErrors.qEn = "English question is required";
    if (!aEn.trim()) newErrors.aEn = "English answer is required";
    if (!qHi.trim()) newErrors.qHi = "Hindi question is required";
    if (!aHi.trim()) newErrors.aHi = "Hindi answer is required";

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    setErrors({});

    setSaving(true);
    try {
      const faqRef = editingId ? doc(db, "faqs", editingId) : doc(collection(db, "faqs"));
      await setDoc(faqRef, {
        question: { en: qEn, hi: qHi },
        answer: { en: aEn, hi: aHi },
        active: isActive,
        updatedAt: new Date().toISOString()
      }, { merge: true });

      toast.success(editingId ? t('faq_updated') : t('faq_created'));
      setIsModalOpen(false);
      fetchFaqs();
    } catch (error: any) {
      console.error(error);
      toast.error(error?.message || t('failed_save_faq'));
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    setConfirmModal({ isOpen: true, id });
  };

  const confirmDelete = async () => {
    try {
      setDeleteLoading(true);
      await deleteDoc(doc(db, "faqs", confirmModal.id));
      toast.success(t('faq_deleted'));
      setConfirmModal({ isOpen: false, id: "" });
      fetchFaqs();
    } catch (error: any) {
      toast.error(error?.message || t('failed_delete_faq'));
    } finally {
      setDeleteLoading(false);
    }
  };

  const handleToggleVisibility = async (faq: Faq) => {
    try {
      const isCurrentlyActive = faq.active !== false;
      const newStatus = !isCurrentlyActive;

      // Optimistic update
      setFaqs(faqs.map(f => f.id === faq.id ? { ...f, active: newStatus } : f));

      await updateDoc(doc(db, "faqs", faq.id), { active: newStatus, updatedAt: new Date().toISOString() });
      toast.success(newStatus ? t('faq_enabled') : t('faq_disabled'));
    } catch (error: any) {
      // Revert on error
      setFaqs(faqs.map(f => f.id === faq.id ? { ...f, active: faq.active } : f));
      toast.error(t('failed_update_faq_visibility'));
    }
  };

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title={t('faq_page_title')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('faqs') }]}
        actions={
          <Button onClick={openNewFaqModal} icon={<Plus className="h-4 w-4" />}>
            {t('add_faq')}
          </Button>
        }
      />

      {loading ? (
        <div className="flex justify-center p-12">
          <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
        </div>
      ) : faqs.length === 0 ? (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-12 text-center">
          <HelpCircle className="mx-auto h-12 w-12 text-slate-300 mb-4" />
          <h3 className="text-lg font-medium text-slate-900">{t('no_faqs_found')}</h3>
          <p className="mt-1 text-sm text-slate-500">{t('faq_started_desc')}</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <table className="min-w-full divide-y divide-slate-200">
            <thead className="bg-slate-50">
              <tr>
                <th scope="col" className="px-6 py-4 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider">
                  {t('question_en')}
                </th>
                <th scope="col" className="px-6 py-4 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider">
                  {t('status')}
                </th>
                <th scope="col" className="px-6 py-4 text-right text-xs font-semibold text-slate-500 uppercase tracking-wider">
                  {t('actions')}
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-slate-200">
              {faqs.map((faq) => (
                <tr key={faq.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-6 py-4">
                    <div className="text-sm font-bold text-slate-900 line-clamp-1">{faq.question?.en}</div>
                    <div className="text-sm text-slate-500 line-clamp-1 mt-0.5">{faq.answer?.en}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2.5 py-1 inline-flex text-xs font-bold rounded-full ${faq.active ? 'bg-emerald-50 text-emerald-700' : 'bg-slate-100 text-slate-700'}`}>
                      {faq.active ? t('faq_active') : t('faq_hidden')}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button
                      onClick={() => handleToggleVisibility(faq)}
                      title={faq.active === false ? t('enable_faq') : t('disable_faq')}
                      className={`p-2 rounded-lg transition-colors mr-2 ${faq.active === false
                        ? "text-slate-400 hover:text-green-600 hover:bg-green-50"
                        : "text-blue-600 hover:text-orange-600 hover:bg-orange-50 bg-blue-50"
                        }`}
                    >
                      {faq.active === false ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                    <button onClick={() => openEditModal(faq)} className="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors mr-2">
                      <Edit2 className="h-4 w-4" />
                    </button>
                    <button onClick={() => handleDelete(faq.id)} className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors">
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingId ? t('edit_faq') : t('create_faq')}
        maxWidth="xl"
      >
        <div className="space-y-6">
          <div className="grid grid-cols-2 gap-4">
            <div className="col-span-2">
              <label className="block text-sm font-semibold text-slate-700 mb-1">{t('faq_status')}</label>
              <select
                value={isActive ? "true" : "false"}
                onChange={(e) => setIsActive(e.target.value === "true")}
                className="w-full px-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 outline-none"
              >
                <option value="true">{t('faq_active_visible')}</option>
                <option value="false">{t('faq_inactive_hidden')}</option>
              </select>
            </div>
          </div>

          <div className="border-t border-slate-100 pt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('english')}</h4>
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1">Question <span className="text-red-500">*</span></label>
                <input
                  type="text"
                  value={qEn}
                  onChange={(e) => {
                    const val = e.target.value;
                    setQEn(val);
                    setErrors(prev => ({ ...prev, qEn: val.trim() ? undefined : "English question is required" }));
                  }}
                  onBlur={(e) => {
                    if (!e.target.value.trim()) setErrors(prev => ({ ...prev, qEn: "English question is required" }));
                  }}
                  className={`w-full px-3 py-2 bg-slate-50 border ${errors.qEn ? 'border-red-500' : 'border-slate-200'} rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 outline-none`}
                  placeholder="e.g. How to book?"
                />
                {errors.qEn && <p className="text-red-500 text-xs mt-1 font-medium">{errors.qEn}</p>}
              </div>
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1">Answer <span className="text-red-500">*</span></label>
                <textarea
                  rows={4}
                  value={aEn}
                  onChange={(e) => {
                    const val = e.target.value;
                    setAEn(val);
                    setErrors(prev => ({ ...prev, aEn: val.trim() ? undefined : "English answer is required" }));
                  }}
                  onBlur={(e) => {
                    if (!e.target.value.trim()) setErrors(prev => ({ ...prev, aEn: "English answer is required" }));
                  }}
                  className={`w-full px-3 py-2 bg-slate-50 border ${errors.aEn ? 'border-red-500' : 'border-slate-200'} rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 outline-none resize-none`}
                  placeholder="Provide the answer here..."
                />
                {errors.aEn && <p className="text-red-500 text-xs mt-1 font-medium">{errors.aEn}</p>}
              </div>
            </div>

            <div className="space-y-4 pt-6 md:pt-0">
              <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('hindi')}</h4>
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1">प्रश्न  <span className="text-red-500">*</span></label>
                <input
                  type="text"
                  value={qHi}
                  onChange={(e) => {
                    const val = e.target.value;
                    setQHi(val);
                    setErrors(prev => ({ ...prev, qHi: val.trim() ? undefined : "Hindi question is required" }));
                  }}
                  onBlur={(e) => {
                    if (!e.target.value.trim()) setErrors(prev => ({ ...prev, qHi: "Hindi question is required" }));
                  }}
                  className={`w-full px-3 py-2 bg-slate-50 border ${errors.qHi ? 'border-red-300 focus:ring-red-500' : 'border-slate-200 focus:ring-blue-500'} rounded-xl text-sm focus:outline-none focus:ring-2 outline-none`}
                  placeholder="e.g. मैं प्लॉट कैसे बुक कर सकता हूं?"
                />
                {errors.qHi && <p className="mt-1 text-xs text-red-600">{errors.qHi}</p>}
              </div>
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1">उत्तर  <span className="text-red-500">*</span></label>
                <textarea
                  rows={4}
                  value={aHi}
                  onChange={(e) => {
                    const val = e.target.value;
                    setAHi(val);
                    setErrors(prev => ({ ...prev, aHi: val.trim() ? undefined : "Hindi answer is required" }));
                  }}
                  onBlur={(e) => {
                    if (!e.target.value.trim()) setErrors(prev => ({ ...prev, aHi: "Hindi answer is required" }));
                  }}
                  className={`w-full px-3 py-2 bg-slate-50 border ${errors.aHi ? 'border-red-300 focus:ring-red-500' : 'border-slate-200 focus:ring-blue-500'} rounded-xl text-sm focus:outline-none focus:ring-2 outline-none resize-none`}
                  placeholder="e.g. आप हमारी सेल्स टीम से संपर्क कर सकते हैं..."
                />
                {errors.aHi && <p className="mt-1 text-xs text-red-600">{errors.aHi}</p>}
              </div>
            </div>
          </div>

          <div className="flex justify-end space-x-3 pt-6 border-t border-slate-100 mt-6">
            <Button
              variant="secondary"
              onClick={() => setIsModalOpen(false)}
            >
              {t('cancel')}
            </Button>
            <Button
              onClick={handleSave}
              disabled={saving}
              icon={saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
            >
              {saving ? t('saving') : t('save_faq')}
            </Button>
          </div>
        </div>
      </Modal>

      <ConfirmModal
        isOpen={confirmModal.isOpen}
        onClose={() => setConfirmModal({ isOpen: false, id: "" })}
        onConfirm={confirmDelete}
        title={t('delete_faq')}
        message={t('delete_faq_confirm')}
        isDanger={true}
        confirmText={t('delete')}
        isLoading={deleteLoading}
      />
    </div>
  );
}
