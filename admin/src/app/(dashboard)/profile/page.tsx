"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/context/AuthContext";
import { db, auth, storage } from "@/lib/firebase";
import { doc, getDoc, updateDoc } from "firebase/firestore";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { toast } from "react-hot-toast";
import { Loader2, Save, User, FileText, Building2, Briefcase, Camera } from "lucide-react";
import { PageHeader } from "@/components/ui/PageHeader";
import { Button } from "@/components/ui/Button";
import getCroppedImg from "@/lib/cropImage";
import Cropper from "react-easy-crop";
import { Modal } from "@/components/ui/Modal";

export default function ProfilePage() {
  const { user, updateUser } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const [formData, setFormData] = useState({
    fullName: "",
    mobileNumber: "",
    whatsappNumber: "",
    firmName: "",
    panNumber: "",
    aadharNumber: "",
    bankAccountNumber: "",
    ifscCode: "",
    bankName: "",
    photoURL: "",
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  // Image cropping state
  const [imageToCrop, setImageToCrop] = useState<string | null>(null);
  const [isCropModalOpen, setIsCropModalOpen] = useState(false);
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<any>(null);
  const [profileImage, setProfileImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);

  // ── Validation (same logic as Add Agent page) ──────────────────────
  const validateField = (name: string, value: string): string => {
    switch (name) {
      case "fullName":
        return value.trim() ? "" : "Full name is required";
      case "mobileNumber":
      case "whatsappNumber": {
        const phoneRegex = /^[0-9]{10}$/;
        if (!value) return "Number is required";
        if (!phoneRegex.test(value)) return "Enter a valid 10-digit number";
        return "";
      }
      case "panNumber": {
        const panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
        if (!value) return "PAN number is required";
        if (!panRegex.test(value.toUpperCase())) return "Enter a valid PAN (e.g. ABCDE1234F)";
        return "";
      }
      case "aadharNumber": {
        const aadharRegex = /^\d{12}$/;
        if (!value) return "Aadhaar number is required";
        if (!aadharRegex.test(value.replace(/\s/g, ""))) return "Enter a valid 12-digit Aadhaar";
        return "";
      }
      case "ifscCode": {
        const ifscRegex = /^[A-Z]{4}0[A-Z0-9]{6}$/;
        if (!value) return "IFSC code is required";
        if (!ifscRegex.test(value.toUpperCase())) return "Enter a valid IFSC code";
        return "";
      }
      case "bankAccountNumber": {
        const accRegex = /^\d{9,18}$/;
        if (!value) return "Account number is required";
        if (!accRegex.test(value)) return "Enter a valid bank account number";
        return "";
      }
      case "bankName":
        return value.trim() ? "" : "Bank name is required";
      default:
        return "";
    }
  };

  // ── Load profile from Firestore ───────────────────────────────────
  useEffect(() => {
    async function fetchProfile() {
      if (!auth.currentUser || !user?.role) return;
      try {
        const col = user.role === "ADMIN" ? "admins" : "agents";
        const snap = await getDoc(doc(db, col, auth.currentUser.uid));
        if (snap.exists()) {
          const d = snap.data();
          setFormData({
            fullName: d.fullName || "",
            mobileNumber: d.mobileNumber || "",
            whatsappNumber: d.whatsappNumber || "",
            firmName: d.firmName || "",
            panNumber: d.panNumber || "",
            aadharNumber: d.aadharNumber || "",
            bankAccountNumber: d.bankAccountNumber || "",
            ifscCode: d.ifscCode || "",
            bankName: d.bankName || "",
            photoURL: d.photoURL || "",
          });
          if (d.photoURL) setImagePreview(d.photoURL);
        }
      } catch (e) {
        toast.error("Failed to load profile data");
      } finally {
        setLoading(false);
      }
    }
    fetchProfile();
  }, [user]);

  // ── Input change handler ──────────────────────────────────────────
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    let formatted = value;
    if (name === "panNumber" || name === "ifscCode") formatted = value.toUpperCase();
    if (["mobileNumber", "whatsappNumber", "aadharNumber", "bankAccountNumber"].includes(name)) {
      formatted = value.replace(/\D/g, "");
    }
    setFormData((prev) => ({ ...prev, [name]: formatted }));
    setErrors((prev) => ({ ...prev, [name]: validateField(name, formatted) }));
  };

  const handleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setErrors((prev) => ({ ...prev, [name]: validateField(name, value) }));
  };

  // ── Image cropping ────────────────────────────────────────────────
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setImageToCrop(URL.createObjectURL(e.target.files[0]));
      setIsCropModalOpen(true);
      e.target.value = "";
    }
  };

  const onCropComplete = (_: any, pixels: any) => setCroppedAreaPixels(pixels);

  const handleCropConfirm = async () => {
    if (imageToCrop && croppedAreaPixels) {
      try {
        const cropped = await getCroppedImg(imageToCrop, croppedAreaPixels, 0);
        if (cropped) {
          setProfileImage(cropped);
          setImagePreview(URL.createObjectURL(cropped));
        }
      } catch (e) {
        console.error(e);
      }
    }
    setIsCropModalOpen(false);
  };

  // ── Submit ────────────────────────────────────────────────────────
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validate all required fields
    const requiredFields = ["fullName", "mobileNumber", "whatsappNumber", "panNumber", "aadharNumber", "bankAccountNumber", "ifscCode", "bankName"];
    const newErrors: Record<string, string> = {};
    requiredFields.forEach((key) => {
      const err = validateField(key, formData[key as keyof typeof formData]);
      if (err) newErrors[key] = err;
    });

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error("Please fix the validation errors before saving.");
      return;
    }

    if (!auth.currentUser || !user?.role) return;
    setSaving(true);

    try {
      const updates: any = { ...formData };

      if (profileImage) {
        const storageRef = ref(storage, `agents/${auth.currentUser.uid}/profile.jpg`);
        await uploadBytes(storageRef, profileImage);
        updates.photoURL = await getDownloadURL(storageRef);
      }

      const col = user.role === "ADMIN" ? "admins" : "agents";
      await updateDoc(doc(db, col, auth.currentUser.uid), {
        ...updates,
        updatedAt: new Date().toISOString(),
      });

      setFormData((prev) => ({ ...prev, photoURL: updates.photoURL || "" }));
      setProfileImage(null);
      if (updateUser) {
        updateUser({ 
          name: updates.fullName,
          photoURL: updates.photoURL || ""
        });
      }
      toast.success("Profile updated successfully!");
    } catch (error) {
      console.error(error);
      toast.error("Failed to update profile");
    } finally {
      setSaving(false);
    }
  };

  const removeProfilePhoto = async () => {
    if (!auth.currentUser || !user?.role) return;
    setSaving(true);
    try {
      const col = user.role === "ADMIN" ? "admins" : "agents";
      await updateDoc(doc(db, col, auth.currentUser.uid), {
        photoURL: "",
        updatedAt: new Date().toISOString(),
      });
      setFormData(prev => ({ ...prev, photoURL: "" })); 
      setImagePreview(null);
      if (updateUser) updateUser({ photoURL: "" });
      toast.success("Profile photo removed!");
    } catch (error) {
      console.error(error);
      toast.error("Failed to remove profile photo");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-blue-500" />
      </div>
    );
  }

  const inputCls = (field: string) =>
    `w-full px-4 py-2.5 bg-slate-50 border ${errors[field] ? "border-red-500 bg-red-50/30" : "border-slate-200"} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all`;

  return (
    <div className="space-y-6 pb-12">
      <PageHeader
        title="My Profile"
        breadcrumbs={[{ label: "Dashboard", href: "/dashboard" }, { label: "Profile" }]}
      />

      <form onSubmit={handleSubmit} className="space-y-6">

        {/* ── Personal Info ── */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-6 border-b border-slate-100 bg-slate-50/50">
            <h3 className="text-lg font-semibold text-slate-900 flex items-center">
              <User className="w-5 h-5 mr-2 text-blue-600" />
              Personal Information
            </h3>
          </div>
          <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">

            {/* Photo */}
            <div className="col-span-1 md:col-span-2 flex items-center gap-6">
              <div className="relative">
                <div className="w-24 h-24 rounded-full bg-slate-100 border-2 border-dashed border-slate-300 flex items-center justify-center overflow-hidden">
                  {imagePreview
                    ? <img src={imagePreview} alt="Profile" className="w-full h-full object-cover" />
                    : <User className="w-10 h-10 text-slate-400" />}
                </div>
                <label className="absolute bottom-0 right-0 p-1.5 bg-blue-600 rounded-full text-white cursor-pointer hover:bg-blue-700 shadow-sm">
                  <Camera className="w-4 h-4" />
                  <input type="file" className="hidden" accept="image/*" onChange={handleImageChange} />
                </label>
              </div>
              <div>
                <p className="text-sm font-medium text-slate-700">Profile Photo</p>
                <p className="text-xs text-slate-500 mt-1">JPG or PNG (Max 5MB)</p>
                {profileImage && (
                  <button type="button" onClick={() => { setProfileImage(null); setImagePreview(formData.photoURL || null); }}
                    className="mt-1 text-xs text-red-500 hover:text-red-700 font-medium">
                    Remove new photo
                  </button>
                )}
                {!profileImage && formData.photoURL && (
                  <button type="button" onClick={removeProfilePhoto} disabled={saving}
                    className="mt-1 text-xs text-red-500 hover:text-red-700 font-medium disabled:opacity-50">
                    Remove profile photo
                  </button>
                )}
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">Full Name *</label>
              <input name="fullName" value={formData.fullName} onChange={handleChange} onBlur={handleBlur} required className={inputCls("fullName")} />
              {errors.fullName && <p className="text-red-500 text-xs mt-1">{errors.fullName}</p>}
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">Mobile Number *</label>
              <input name="mobileNumber" value={formData.mobileNumber} onChange={handleChange} onBlur={handleBlur} maxLength={10} className={inputCls("mobileNumber")} placeholder="10-digit number" />
              {errors.mobileNumber && <p className="text-red-500 text-xs mt-1">{errors.mobileNumber}</p>}
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">WhatsApp Number *</label>
              <input name="whatsappNumber" value={formData.whatsappNumber} onChange={handleChange} onBlur={handleBlur} maxLength={10} className={inputCls("whatsappNumber")} placeholder="10-digit number" />
              {errors.whatsappNumber && <p className="text-red-500 text-xs mt-1">{errors.whatsappNumber}</p>}
            </div>
          </div>
        </div>

        {/* ── Firm Info ── */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-6 border-b border-slate-100 bg-slate-50/50">
            <h3 className="text-lg font-semibold text-slate-900 flex items-center">
              <Briefcase className="w-5 h-5 mr-2 text-blue-600" />
              Agency / Firm Details
            </h3>
          </div>
          <div className="p-6">
            <label className="block text-sm font-semibold text-slate-700 mb-1.5">Firm / Company Name (Optional)</label>
            <input name="firmName" value={formData.firmName} onChange={handleChange} className={inputCls("firmName")} />
          </div>
        </div>

        {/* ── KYC ── */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-6 border-b border-slate-100 bg-slate-50/50">
            <h3 className="text-lg font-semibold text-slate-900 flex items-center">
              <FileText className="w-5 h-5 mr-2 text-blue-600" />
              KYC Documents
            </h3>
          </div>
          <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">PAN Card Number *</label>
              <input name="panNumber" value={formData.panNumber} onChange={handleChange} onBlur={handleBlur} maxLength={10} placeholder="ABCDE1234F" className={`${inputCls("panNumber")} uppercase`} />
              {errors.panNumber && <p className="text-red-500 text-xs mt-1">{errors.panNumber}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">Aadhaar Number *</label>
              <input name="aadharNumber" value={formData.aadharNumber} onChange={handleChange} onBlur={handleBlur} maxLength={12} placeholder="123456789012" className={inputCls("aadharNumber")} />
              {errors.aadharNumber && <p className="text-red-500 text-xs mt-1">{errors.aadharNumber}</p>}
            </div>
          </div>
        </div>

        {/* ── Bank Details ── */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
          <div className="p-6 border-b border-slate-100 bg-slate-50/50">
            <h3 className="text-lg font-semibold text-slate-900 flex items-center">
              <Building2 className="w-5 h-5 mr-2 text-blue-600" />
              Bank Details
            </h3>
          </div>
          <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">Bank Name *</label>
              <input name="bankName" value={formData.bankName} onChange={handleChange} onBlur={handleBlur} className={inputCls("bankName")} />
              {errors.bankName && <p className="text-red-500 text-xs mt-1">{errors.bankName}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">Account Number *</label>
              <input name="bankAccountNumber" value={formData.bankAccountNumber} onChange={handleChange} onBlur={handleBlur} className={inputCls("bankAccountNumber")} />
              {errors.bankAccountNumber && <p className="text-red-500 text-xs mt-1">{errors.bankAccountNumber}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">IFSC Code *</label>
              <input name="ifscCode" value={formData.ifscCode} onChange={handleChange} onBlur={handleBlur} maxLength={11} placeholder="SBIN0001234" className={`${inputCls("ifscCode")} uppercase`} />
              {errors.ifscCode && <p className="text-red-500 text-xs mt-1">{errors.ifscCode}</p>}
            </div>
          </div>
        </div>

        <div className="flex justify-end pt-2">
          <Button
            type="submit"
            disabled={saving}
            icon={saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
          >
            {saving ? "Saving..." : "Save Profile"}
          </Button>
        </div>
      </form>

      {/* Image Crop Modal */}
      <Modal
        isOpen={isCropModalOpen}
        onClose={() => setIsCropModalOpen(false)}
        title="Crop Profile Image"
        maxWidth="lg"
        footer={
          <>
            <button onClick={() => setIsCropModalOpen(false)} className="px-4 py-2 text-slate-600 hover:bg-slate-200 rounded-lg transition-colors font-medium">
              Cancel
            </button>
            <button onClick={handleCropConfirm} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium">
              Crop & Save
            </button>
          </>
        }
      >
        <div className="relative w-full h-[400px] bg-slate-900 rounded-xl overflow-hidden">
          {imageToCrop && (
            <Cropper
              image={imageToCrop}
              crop={crop}
              zoom={zoom}
              aspect={1}
              onCropChange={setCrop}
              onCropComplete={onCropComplete}
              onZoomChange={setZoom}
            />
          )}
        </div>
      </Modal>
    </div>
  );
}
