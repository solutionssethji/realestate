"use client";

import { useState, useEffect } from "react";
import { getSetting, saveSetting } from "@/lib/cmsService";
import { PageHeader } from "@/components/ui/PageHeader";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { toast } from "react-hot-toast";
import { Loader2, Info, Phone, FileText, Lock } from "lucide-react";
import { useLanguage } from '@/context/LanguageContext';
import { updatePassword, EmailAuthProvider, reauthenticateWithCredential } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { validateStrongPassword } from "@/lib/validators";

export default function SettingsDashboard() {
  const { t } = useLanguage();
  const [activeTab, setActiveTab] = useState("about");

  const tabs = [
    { id: "about", label: t('tab_about'), icon: Info },
    { id: "contact", label: t('tab_contact'), icon: Phone },
    { id: "legal", label: t('tab_legal'), icon: FileText },
    { id: "security", label: t('tab_security'), icon: Lock },
  ];

  return (
    <div className="space-y-6 pb-12">
      <PageHeader
        title={t('app_settings')}
        breadcrumbs={[{ label: t('dashboard'), href: "/dashboard" }, { label: t('settings') }]}
      />

      <div className="flex space-x-1 border-b border-slate-200 overflow-x-auto scrollbar-hide">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center px-4 py-3 text-sm font-medium border-b-2 transition-colors whitespace-nowrap ${activeTab === tab.id
                ? "border-blue-600 text-blue-600 bg-blue-50/50 rounded-t-lg"
                : "border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300"
                }`}
            >
              <Icon className="h-4 w-4 mr-2" />
              {tab.label}
            </button>
          );
        })}
      </div>

      <div className="pt-4">
        {activeTab === "about" && <AboutTab />}
        {activeTab === "contact" && <ContactTab />}
        {activeTab === "legal" && <LegalTab />}
        {activeTab === "security" && <SecurityTab />}
      </div>
    </div>
  );
}

const emptyBilingual = () => ({ en: "", hi: "" });

function AboutTab() {
  const { t } = useLanguage();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [aboutData, setAboutData] = useState({
    companyProfile: emptyBilingual(),
    mission: emptyBilingual(),
    vision: emptyBilingual(),
    whyChooseUs: emptyBilingual()
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    async function loadData() {
      const about = await getSetting("aboutCompany");
      if (about) {
        setAboutData({
          companyProfile: { ...emptyBilingual(), ...(about.companyProfile || {}) },
          mission: { ...emptyBilingual(), ...(about.mission || {}) },
          vision: { ...emptyBilingual(), ...(about.vision || {}) },
          whyChooseUs: { ...emptyBilingual(), ...(about.whyChooseUs || {}) },
        });
      }
      setLoading(false);
    }
    loadData();
  }, []);

  const handleNestedChange = (field: keyof typeof aboutData, lang: 'en' | 'hi', value: string) => {
    setAboutData(prev => ({
      ...prev,
      [field]: { ...prev[field], [lang]: value }
    }));
    const key = `${field}_${lang}`;
    setErrors(prev => ({ ...prev, [key]: value.trim() ? "" : "Required field" }));
  };

  const handleNestedBlur = (field: keyof typeof aboutData, lang: 'en' | 'hi', value: string) => {
    const key = `${field}_${lang}`;
    setErrors(prev => ({ ...prev, [key]: value.trim() ? "" : "Required field" }));
  };

  const handleSave = async () => {
    const newErrors: Record<string, string> = {};
    const fields: (keyof typeof aboutData)[] = ["companyProfile", "vision", "mission", "whyChooseUs"];
    const langs: ("en" | "hi")[] = ["en", "hi"];

    fields.forEach(field => {
      langs.forEach(lang => {
        if (!aboutData[field][lang].trim()) newErrors[`${field}_${lang}`] = "Required field";
      });
    });

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error(t('fill_all_required_both_langs'));
      return;
    }
    setErrors({});
    setSaving(true);
    try {
      await saveSetting("aboutCompany", aboutData);
      toast.success(t('about_saved'));
    } catch (error) {
      toast.error(t('failed_save_data'));
    } finally {
      setSaving(false);
    }
  };

  const getTextareaClass = (hasError: boolean) =>
    `w-full px-4 py-3 rounded-xl border text-sm shadow-sm focus:outline-none focus:ring-2 transition-all duration-200 ${hasError ? 'border-red-300 focus:ring-red-500 bg-red-50/50' : 'border-slate-200 focus:ring-blue-500 focus:border-transparent bg-white'}`;

  if (loading) return <div className="flex h-32 items-center justify-center"><Loader2 className="h-6 w-6 animate-spin text-blue-500" /></div>;

  return (
    <Card>
      <div className="p-6 border-b border-slate-100">
        <h3 className="text-lg font-bold text-slate-900">{t('about_company')}</h3>
        <p className="text-sm text-slate-500 mt-1">{t('about_company_desc')}</p>
      </div>
      <div className="p-6 space-y-8">

        {/* ENGLISH SECTION */}
        <div className="space-y-6">
          <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('english')}</h4>
          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">{t('company_profile')} <span className="text-red-500">*</span></label>
              <textarea value={aboutData.companyProfile.en} onChange={e => handleNestedChange("companyProfile", "en", e.target.value)} onBlur={e => handleNestedBlur("companyProfile", "en", e.target.value)} rows={4} className={getTextareaClass(!!errors.companyProfile_en)} />
              {errors.companyProfile_en && <p className="text-sm text-red-600 font-medium">{errors.companyProfile_en}</p>}
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">{t('vision')} <span className="text-red-500">*</span></label>
              <textarea value={aboutData.vision.en} onChange={e => handleNestedChange("vision", "en", e.target.value)} onBlur={e => handleNestedBlur("vision", "en", e.target.value)} rows={3} className={getTextareaClass(!!errors.vision_en)} />
              {errors.vision_en && <p className="text-sm text-red-600 font-medium">{errors.vision_en}</p>}
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">{t('mission')} <span className="text-red-500">*</span></label>
              <textarea value={aboutData.mission.en} onChange={e => handleNestedChange("mission", "en", e.target.value)} onBlur={e => handleNestedBlur("mission", "en", e.target.value)} rows={3} className={getTextareaClass(!!errors.mission_en)} />
              {errors.mission_en && <p className="text-sm text-red-600 font-medium">{errors.mission_en}</p>}
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">{t('why_choose_us')} <span className="text-red-500">*</span></label>
              <textarea value={aboutData.whyChooseUs.en} onChange={e => handleNestedChange("whyChooseUs", "en", e.target.value)} onBlur={e => handleNestedBlur("whyChooseUs", "en", e.target.value)} rows={4} className={getTextareaClass(!!errors.whyChooseUs_en)} />
              {errors.whyChooseUs_en && <p className="text-sm text-red-600 font-medium">{errors.whyChooseUs_en}</p>}
            </div>
          </div>
        </div>

        {/* HINDI SECTION */}
        <div className="space-y-6 pt-4 border-t border-slate-100">
          <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('hindi')}</h4>
          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">कंपनी प्रोफ़ाइल <span className="text-red-500">*</span></label>
              <textarea value={aboutData.companyProfile.hi} onChange={e => handleNestedChange("companyProfile", "hi", e.target.value)} onBlur={e => handleNestedBlur("companyProfile", "hi", e.target.value)} rows={4} className={getTextareaClass(!!errors.companyProfile_hi)} />
              {errors.companyProfile_hi && <p className="text-sm text-red-600 font-medium">{errors.companyProfile_hi}</p>}
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">दृष्टिकोण <span className="text-red-500">*</span></label>
              <textarea value={aboutData.vision.hi} onChange={e => handleNestedChange("vision", "hi", e.target.value)} onBlur={e => handleNestedBlur("vision", "hi", e.target.value)} rows={3} className={getTextareaClass(!!errors.vision_hi)} />
              {errors.vision_hi && <p className="text-sm text-red-600 font-medium">{errors.vision_hi}</p>}
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">उद्देश्य <span className="text-red-500">*</span></label>
              <textarea value={aboutData.mission.hi} onChange={e => handleNestedChange("mission", "hi", e.target.value)} onBlur={e => handleNestedBlur("mission", "hi", e.target.value)} rows={3} className={getTextareaClass(!!errors.mission_hi)} />
              {errors.mission_hi && <p className="text-sm text-red-600 font-medium">{errors.mission_hi}</p>}
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">हमें क्यों चुनें <span className="text-red-500">*</span></label>
              <textarea value={aboutData.whyChooseUs.hi} onChange={e => handleNestedChange("whyChooseUs", "hi", e.target.value)} onBlur={e => handleNestedBlur("whyChooseUs", "hi", e.target.value)} rows={4} className={getTextareaClass(!!errors.whyChooseUs_hi)} />
              {errors.whyChooseUs_hi && <p className="text-sm text-red-600 font-medium">{errors.whyChooseUs_hi}</p>}
            </div>
          </div>
        </div>

        <div className="flex justify-end pt-4">
          <Button onClick={handleSave} isLoading={saving}>{t('save_changes')}</Button>
        </div>
      </div>
    </Card>
  );
}

function ContactTab() {
  const { t } = useLanguage();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [contactData, setContactData] = useState({
    directCall: "",
    whatsapp: "",
    googleMaps: "",
    officeLocation: emptyBilingual(),
    contactNumber: ""
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    async function loadData() {
      const contact = await getSetting("contactUs");
      if (contact) {
        setContactData({
          directCall: contact.directCall || "",
          whatsapp: contact.whatsapp || "",
          googleMaps: contact.googleMaps || "",
          officeLocation: { ...emptyBilingual(), ...(contact.officeLocation || {}) },
          contactNumber: typeof contact.contactNumber === 'string' ? contact.contactNumber : (contact.contactNumber?.en || "")
        });
      }
      setLoading(false);
    }
    loadData();
  }, []);

  const handleNestedChange = (field: "officeLocation", lang: 'en' | 'hi', value: string) => {
    setContactData(prev => ({
      ...prev,
      [field]: { ...prev[field], [lang]: value }
    }));
    const key = `${field}_${lang}`;
    setErrors(prev => ({ ...prev, [key]: value.trim() ? "" : "Required" }));
  };

  const handleNestedBlur = (field: "officeLocation", lang: 'en' | 'hi', value: string) => {
    const key = `${field}_${lang}`;
    setErrors(prev => ({ ...prev, [key]: value.trim() ? "" : "Required" }));
  };

  const handleFieldChange = (field: keyof Omit<typeof contactData, 'officeLocation'>, value: string) => {
    setContactData(prev => ({ ...prev, [field]: value }));
    setErrors(prev => ({ ...prev, [field]: value.trim() ? "" : `${field.charAt(0).toUpperCase() + field.slice(1).replace(/([A-Z])/g, ' $1')} is required` }));
  };

  const handleFieldBlur = (field: keyof Omit<typeof contactData, 'officeLocation'>, value: string) => {
    setErrors(prev => ({ ...prev, [field]: value.trim() ? "" : `This field is required` }));
  };

  const handleSave = async () => {
    const newErrors: Record<string, string> = {};
    if (!contactData.directCall.trim()) newErrors.directCall = "Direct Call is required";
    if (!contactData.whatsapp.trim()) newErrors.whatsapp = "WhatsApp is required";
    if (!contactData.googleMaps.trim()) newErrors.googleMaps = "Google Maps URL is required";
    if (!contactData.officeLocation.en.trim()) newErrors.officeLocation_en = "Required";
    if (!contactData.officeLocation.hi.trim()) newErrors.officeLocation_hi = "Required";
    if (!contactData.contactNumber.trim()) newErrors.contactNumber = "Required";

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error(t('fill_all_required'));
      return;
    }
    setErrors({});
    setSaving(true);
    try {
      await saveSetting("contactUs", contactData);
      toast.success(t('contact_saved'));
    } catch (error) {
      toast.error(t('failed_save_data'));
    } finally {
      setSaving(false);
    }
  };

  const getTextareaClass = (hasError: boolean) =>
    `w-full px-4 py-3 rounded-xl border text-sm shadow-sm focus:outline-none focus:ring-2 transition-all duration-200 ${hasError ? 'border-red-300 focus:ring-red-500 bg-red-50/50' : 'border-slate-200 focus:ring-blue-500 focus:border-transparent bg-white'}`;

  if (loading) return <div className="flex h-32 items-center justify-center"><Loader2 className="h-6 w-6 animate-spin text-blue-500" /></div>;

  return (
    <Card>
      <div className="p-6 border-b border-slate-100">
        <h3 className="text-lg font-bold text-slate-900">{t('contact_us')}</h3>
        <p className="text-sm text-slate-500 mt-1">{t('contact_us_desc')}</p>
      </div>
      <div className="p-6 space-y-8">
        <div className="space-y-4">
          <Input required label={t('direct_call_label')} value={contactData.directCall} error={errors.directCall} onChange={e => handleFieldChange('directCall', e.target.value)} onBlur={e => handleFieldBlur('directCall', e.target.value)} placeholder="e.g. +919876543210" />
          <Input required label={t('whatsapp_label')} value={contactData.whatsapp} error={errors.whatsapp} onChange={e => handleFieldChange('whatsapp', e.target.value)} onBlur={e => handleFieldBlur('whatsapp', e.target.value)} placeholder="e.g. 919876543210" />
          <Input required label={t('google_maps_label')} value={contactData.googleMaps} error={errors.googleMaps} onChange={e => handleFieldChange('googleMaps', e.target.value)} onBlur={e => handleFieldBlur('googleMaps', e.target.value)} placeholder="https://goo.gl/maps/..." />

          <div className="space-y-1.5 pt-2">
            <label className="block text-sm font-semibold text-slate-700">{t('contact_number')} <span className="text-red-500">*</span></label>
            <textarea value={contactData.contactNumber} onChange={e => { const val = e.target.value; setContactData(prev => ({ ...prev, contactNumber: val })); setErrors(prev => ({ ...prev, contactNumber: val.trim() ? "" : "Required" })); }} onBlur={e => { if (!e.target.value.trim()) setErrors(prev => ({ ...prev, contactNumber: "Required" })); }} rows={2} className={getTextareaClass(!!errors.contactNumber)} placeholder="+91 98765 43210" />
            {errors.contactNumber && <p className="text-sm text-red-600 font-medium">{errors.contactNumber}</p>}
          </div>
        </div>

        {/* ENGLISH SECTION */}
        <div className="space-y-4 pt-4 border-t border-slate-100">
          <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('english')}</h4>
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-slate-700">{t('office_location')} <span className="text-red-500">*</span></label>
            <textarea value={contactData.officeLocation.en} onChange={e => handleNestedChange("officeLocation", "en", e.target.value)} onBlur={e => handleNestedBlur("officeLocation", "en", e.target.value)} rows={3} className={getTextareaClass(!!errors.officeLocation_en)} />
            {errors.officeLocation_en && <p className="text-sm text-red-600 font-medium">{errors.officeLocation_en}</p>}
          </div>
        </div>

        {/* HINDI SECTION */}
        <div className="space-y-4 pt-4 border-t border-slate-100">
          <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('hindi')}</h4>
          <div className="space-y-1.5">
            <label className="block text-sm font-semibold text-slate-700">कार्यालय का स्थान <span className="text-red-500">*</span></label>
            <textarea value={contactData.officeLocation.hi} onChange={e => handleNestedChange("officeLocation", "hi", e.target.value)} onBlur={e => handleNestedBlur("officeLocation", "hi", e.target.value)} rows={3} className={getTextareaClass(!!errors.officeLocation_hi)} />
            {errors.officeLocation_hi && <p className="text-sm text-red-600 font-medium">{errors.officeLocation_hi}</p>}
          </div>
        </div>

        <div className="flex justify-end pt-4">
          <Button onClick={handleSave} isLoading={saving}>{t('save_changes')}</Button>
        </div>
      </div>
    </Card>
  );
}

function LegalTab() {
  const { t } = useLanguage();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [legalData, setLegalData] = useState({
    privacyPolicy: emptyBilingual(),
    termsAndConditions: emptyBilingual()
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    async function loadData() {
      const legal = await getSetting("legalPolicies");
      if (legal) {
        setLegalData({
          privacyPolicy: { ...emptyBilingual(), ...(legal.privacyPolicy || {}) },
          termsAndConditions: { ...emptyBilingual(), ...(legal.termsAndConditions || {}) }
        });
      }
      setLoading(false);
    }
    loadData();
  }, []);

  const handleNestedChange = (field: keyof typeof legalData, lang: 'en' | 'hi', value: string) => {
    setLegalData(prev => ({
      ...prev,
      [field]: { ...prev[field], [lang]: value }
    }));
    const key = `${field}_${lang}`;
    setErrors(prev => ({ ...prev, [key]: value.trim() ? "" : "Required field" }));
  };

  const handleNestedBlur = (field: keyof typeof legalData, lang: 'en' | 'hi', value: string) => {
    const key = `${field}_${lang}`;
    setErrors(prev => ({ ...prev, [key]: value.trim() ? "" : "Required field" }));
  };

  const handleSave = async () => {
    const newErrors: Record<string, string> = {};
    const fields: (keyof typeof legalData)[] = ["privacyPolicy", "termsAndConditions"];
    const langs: ("en" | "hi")[] = ["en", "hi"];

    fields.forEach(field => {
      langs.forEach(lang => {
        if (!legalData[field][lang].trim()) newErrors[`${field}_${lang}`] = "Required field";
      });
    });

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error(t('fill_all_required_both_langs'));
      return;
    }
    setErrors({});
    setSaving(true);
    try {
      await saveSetting("legalPolicies", legalData);
      toast.success(t('legal_saved'));
    } catch (error) {
      toast.error(t('failed_save_data'));
    } finally {
      setSaving(false);
    }
  };

  const getTextareaClass = (hasError: boolean) =>
    `w-full px-4 py-3 rounded-xl border text-sm shadow-sm focus:outline-none focus:ring-2 transition-all duration-200 ${hasError ? 'border-red-300 focus:ring-red-500 bg-red-50/50' : 'border-slate-200 focus:ring-blue-500 focus:border-transparent bg-white'}`;

  if (loading) return <div className="flex h-32 items-center justify-center"><Loader2 className="h-6 w-6 animate-spin text-blue-500" /></div>;

  return (
    <Card>
      <div className="p-6 border-b border-slate-100">
        <h3 className="text-lg font-bold text-slate-900">{t('legal_policies')}</h3>
        <p className="text-sm text-slate-500 mt-1">{t('legal_policies_desc')}</p>
      </div>
      <div className="p-6 space-y-8">

        {/* ENGLISH SECTION */}
        <div className="space-y-6">
          <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('english')}</h4>
          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">{t('terms_conditions')} <span className="text-red-500">*</span></label>
              <textarea value={legalData.termsAndConditions.en} onChange={e => handleNestedChange("termsAndConditions", "en", e.target.value)} onBlur={e => handleNestedBlur("termsAndConditions", "en", e.target.value)} rows={6} className={getTextareaClass(!!errors.termsAndConditions_en)} />
              {errors.termsAndConditions_en && <p className="text-sm text-red-600 font-medium">{errors.termsAndConditions_en}</p>}
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">{t('privacy_policy')} <span className="text-red-500">*</span></label>
              <textarea value={legalData.privacyPolicy.en} onChange={e => handleNestedChange("privacyPolicy", "en", e.target.value)} onBlur={e => handleNestedBlur("privacyPolicy", "en", e.target.value)} rows={6} className={getTextareaClass(!!errors.privacyPolicy_en)} />
              {errors.privacyPolicy_en && <p className="text-sm text-red-600 font-medium">{errors.privacyPolicy_en}</p>}
            </div>
          </div>
        </div>

        {/* HINDI SECTION */}
        <div className="space-y-6 pt-4 border-t border-slate-100">
          <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('hindi')}</h4>
          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">नियम एवं शर्तें <span className="text-red-500">*</span></label>
              <textarea value={legalData.termsAndConditions.hi} onChange={e => handleNestedChange("termsAndConditions", "hi", e.target.value)} onBlur={e => handleNestedBlur("termsAndConditions", "hi", e.target.value)} rows={6} className={getTextareaClass(!!errors.termsAndConditions_hi)} />
              {errors.termsAndConditions_hi && <p className="text-sm text-red-600 font-medium">{errors.termsAndConditions_hi}</p>}
            </div>
            <div className="space-y-1.5">
              <label className="block text-sm font-semibold text-slate-700">गोपनीयता नीति <span className="text-red-500">*</span></label>
              <textarea value={legalData.privacyPolicy.hi} onChange={e => handleNestedChange("privacyPolicy", "hi", e.target.value)} onBlur={e => handleNestedBlur("privacyPolicy", "hi", e.target.value)} rows={6} className={getTextareaClass(!!errors.privacyPolicy_hi)} />
              {errors.privacyPolicy_hi && <p className="text-sm text-red-600 font-medium">{errors.privacyPolicy_hi}</p>}
            </div>
          </div>
        </div>

        <div className="flex justify-end pt-4">
          <Button onClick={handleSave} isLoading={saving}>{t('save_changes')}</Button>
        </div>
      </div>
    </Card>
  );
}

function SecurityTab() {
  const { t } = useLanguage();
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleUpdatePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    const newErrors: Record<string, string> = {};
    if (!currentPassword) newErrors.currentPassword = t('current_password_required');
    if (!newPassword) newErrors.newPassword = t('new_password_required');
    if (!confirmPassword) newErrors.confirmPassword = t('please_confirm_password');
    
    if (newPassword) {
      const passwordError = validateStrongPassword(newPassword);
      if (passwordError) {
        newErrors.newPassword = passwordError;
      }
    }
    
    if (newPassword && confirmPassword && newPassword !== confirmPassword) {
      newErrors.confirmPassword = t('new_passwords_no_match');
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error(t('fix_validation_errors'));
      return;
    }

    const user = auth.currentUser;
    if (!user || !user.email) {
      toast.error(t('user_not_found_login'));
      return;
    }

    setErrors({});
    setLoading(true);
    try {
      // Re-authenticate first
      const credential = EmailAuthProvider.credential(user.email, currentPassword);
      await reauthenticateWithCredential(user, credential);

      // Update password
      await updatePassword(user, newPassword);
      toast.success(t('password_updated'));
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
    } catch (error: any) {
      console.error(error);
      if (error.code === 'auth/invalid-credential') {
        toast.error(t('incorrect_current_password'));
        setErrors({ currentPassword: t('incorrect_current_password') });
      } else if (error.code === 'auth/requires-recent-login') {
        toast.error(t('relogin_change_password'));
      } else {
        toast.error(error.message || t('failed_update_password'));
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="p-6">
      <h3 className="text-lg font-semibold text-slate-800 mb-4">{t('change_password')}</h3>
      <form onSubmit={handleUpdatePassword} noValidate className="space-y-6 max-w-md">
        <Input
          label={t('current_password')}
          type="password"
          required
          value={currentPassword}
          error={errors.currentPassword}
          onChange={(e) => {
            const val = e.target.value;
            setCurrentPassword(val);
            if (!val) {
              setErrors(prev => ({ ...prev, currentPassword: t('current_password_required') }));
            } else {
              setErrors(prev => { const next = { ...prev }; delete next.currentPassword; return next; });
            }
          }}
          onBlur={() => {
            if (!currentPassword) {
              setErrors(prev => ({ ...prev, currentPassword: t('current_password_required') }));
            }
          }}
        />
        <Input
          label={t('new_password')}
          type="password"
          required
          value={newPassword}
          error={errors.newPassword}
          onChange={(e) => {
            const val = e.target.value;
            setNewPassword(val);
            if (!val) {
              setErrors(prev => ({ ...prev, newPassword: t('new_password_required') }));
            } else {
              const err = validateStrongPassword(val);
              if (err) {
                setErrors(prev => ({ ...prev, newPassword: err }));
              } else {
                setErrors(prev => { const next = { ...prev }; delete next.newPassword; return next; });
              }
            }
            
            if (confirmPassword && val !== confirmPassword) {
              setErrors(prev => ({ ...prev, confirmPassword: t('new_passwords_no_match') }));
            } else if (confirmPassword && val === confirmPassword) {
              setErrors(prev => { const next = { ...prev }; delete next.confirmPassword; return next; });
            }
          }}
          onBlur={() => {
            if (!newPassword) {
              setErrors(prev => ({ ...prev, newPassword: t('new_password_required') }));
            } else {
              const err = validateStrongPassword(newPassword);
              if (err) {
                setErrors(prev => ({ ...prev, newPassword: err }));
              }
            }
          }}
        />
        <Input
          label={t('confirm_new_password')}
          type="password"
          required
          value={confirmPassword}
          error={errors.confirmPassword}
          onChange={(e) => {
            const val = e.target.value;
            setConfirmPassword(val);
            if (!val) {
              setErrors(prev => ({ ...prev, confirmPassword: t('please_confirm_password') }));
            } else if (val !== newPassword) {
              setErrors(prev => ({ ...prev, confirmPassword: t('new_passwords_no_match') }));
            } else {
              setErrors(prev => { const next = { ...prev }; delete next.confirmPassword; return next; });
            }
          }}
          onBlur={() => {
            if (!confirmPassword) {
              setErrors(prev => ({ ...prev, confirmPassword: t('please_confirm_password') }));
            } else if (confirmPassword !== newPassword) {
              setErrors(prev => ({ ...prev, confirmPassword: t('new_passwords_no_match') }));
            }
          }}
        />
        
        <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100">
          <p className="text-sm text-blue-800 font-medium mb-1">{t('password_requirements')}</p>
          <ul className="text-xs text-blue-600/80 list-disc list-inside space-y-0.5">
            <li>{t('password_req_length')}</li>
            <li>{t('password_req_case')}</li>
            <li>{t('password_req_special')}</li>
          </ul>
        </div>

        <div className="pt-2">
          <Button type="submit" isLoading={loading} className="w-full">
            {t('update_password')}
          </Button>
        </div>
      </form>
    </Card>
  );
}
