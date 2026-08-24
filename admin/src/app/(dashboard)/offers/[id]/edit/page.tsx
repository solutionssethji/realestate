"use client";

import { useState, useEffect, use } from "react";
import { useRouter } from "next/navigation";
import { collection, doc, getDoc, getDocs, updateDoc, query, where } from "firebase/firestore";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { db, storage } from "@/lib/firebase";
import getCroppedImg from "@/lib/cropImage";
import Cropper from "react-easy-crop";
import { Modal } from "@/components/ui/Modal";
import { PageHeader } from "@/components/ui/PageHeader";
import { Tag, Calendar, Percent, IndianRupee, CheckCircle, Image as ImageIcon, FileText } from "lucide-react";
import { toast } from "react-hot-toast";

export default function EditOfferPage({ params }: { params: any }) {
  const router = useRouter();

  const unwrappedParams = typeof params.then === 'function' ? use(params as Promise<any>) : params;
  const offerId = unwrappedParams.id;

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // Projects fetch
  const [projects, setProjects] = useState<any[]>([]);

  useEffect(() => {
    async function fetchProjects() {
      const q = query(collection(db, "projects"), where("isActive", "==", true));
      const snap = await getDocs(q);
      const list = snap.docs.map(d => ({ id: d.id, name: d.data().name }));
      setProjects(list);
    }
    fetchProjects();
  }, []);

  // Image states
  const [offerImage, setOfferImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [imageToCrop, setImageToCrop] = useState<string | null>(null);
  const [isCropModalOpen, setIsCropModalOpen] = useState(false);
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<any>(null);

  const [formData, setFormData] = useState({
    titleEn: "",
    titleHi: "",
    descriptionEn: "",
    descriptionHi: "",
    code: "",
    discountType: "PERCENTAGE",
    discountValue: "",
    projectId: "global", // 'global' or actual ID
    startDate: "",
    endDate: "",
    status: "ACTIVE"
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (offerId) {
      loadOffer(offerId);
    }
  }, [offerId]);

  async function loadOffer(id: string) {
    try {
      const docSnap = await getDoc(doc(db, "offers", id));
      if (docSnap.exists()) {
        const data = docSnap.data();

        setFormData({
          titleEn: data.title?.en || "",
          titleHi: data.title?.hi || "",
          descriptionEn: data.description?.en || (typeof data.description === 'string' ? data.description : ""),
          descriptionHi: data.description?.hi || "",
          code: data.code || "",
          discountType: data.discountType || "PERCENTAGE",
          discountValue: data.discountValue?.toString() || "",
          projectId: data.projectId || "global",
          startDate: data.startDate || "",
          endDate: data.endDate || "",
          status: data.status || "ACTIVE"
        });

        if (data.offerImage) {
          setImagePreview(data.offerImage);
        }
      } else {
        toast.error("Offer not found");
        router.push("/offers");
      }
    } catch (error: any) {
      console.error(error);
      toast.error(`Failed to load offer details: ${error.message}`);
    } finally {
      setLoading(false);
    }
  }

  const validateField = (name: string, value: string, currentFormData = formData) => {
    let error = "";
    if (name.includes("title") || name.includes("description") || name === "code" || name === "discountValue" || name === "startDate" || name === "endDate") {
      if (!value.trim()) {
        error = "This field is required";
      }
    }
    if (name === "discountValue" && value.trim() && currentFormData.discountType === "PERCENTAGE") {
      if (parseFloat(value) > 100) {
        error = "Percentage cannot exceed 100";
      }
    }
    return error;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    let formattedValue = value;
    if (name === "code") {
      formattedValue = value.toUpperCase().replace(/\s/g, "");
    }
    const updatedFormData = { ...formData, [name]: formattedValue };
    
    // If discountType changes, re-validate discountValue
    if (name === "discountType") {
      setErrors(prev => ({ 
        ...prev, 
        discountValue: validateField("discountValue", updatedFormData.discountValue, updatedFormData) 
      }));
    }

    setFormData(updatedFormData);
    setErrors(prev => ({ ...prev, [name]: validateField(name, formattedValue, updatedFormData) }));
  };

  const handleBlur = (e: React.FocusEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setErrors(prev => ({ ...prev, [name]: validateField(name, value, formData) }));
  };

  // Image handlers
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setImageToCrop(URL.createObjectURL(e.target.files[0]));
      setIsCropModalOpen(true);
      e.target.value = "";
    }
  };
  const onCropComplete = (_: any, croppedAreaPixels: any) => setCroppedAreaPixels(croppedAreaPixels);
  const handleCropConfirm = async () => {
    if (imageToCrop && croppedAreaPixels) {
      try {
        const croppedFile = await getCroppedImg(imageToCrop, croppedAreaPixels, 0);
        if (croppedFile) {
          setOfferImage(croppedFile);
          setImagePreview(URL.createObjectURL(croppedFile));
          setErrors(prev => ({ ...prev, offerImage: "" }));
        }
      } catch (e) {
        console.error(e);
      }
    }
    setIsCropModalOpen(false);
  };
  const handleRemoveImage = () => {
    setOfferImage(null);
    setImagePreview(null);
    setImageToCrop(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const newErrors: Record<string, string> = {};
    Object.keys(formData).forEach(key => {
      const err = validateField(key, formData[key as keyof typeof formData] as string, formData);
      if (err) newErrors[key] = err;
    });

    if (!imagePreview) newErrors.offerImage = "Offer image is required";

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error("Please fix all required fields.");
      return;
    }

    setSaving(true);
    try {
      const docRef = doc(db, "offers", offerId);

      let photoURL = imagePreview; // might be existing URL

      // If a new file was uploaded, upload to storage
      if (offerImage) {
        const storageRef = ref(storage, `offers/${offerId}/image.jpg`);
        await uploadBytes(storageRef, offerImage);
        photoURL = await getDownloadURL(storageRef);
      }

      await updateDoc(docRef, {
        code: formData.code,
        title: { en: formData.titleEn, hi: formData.titleHi },
        description: { en: formData.descriptionEn, hi: formData.descriptionHi },
        discountType: formData.discountType,
        discountValue: parseFloat(formData.discountValue),
        projectId: formData.projectId === "global" ? "" : formData.projectId,
        startDate: formData.startDate,
        endDate: formData.endDate,
        status: formData.status,
        offerImage: photoURL,
        updatedAt: new Date().toISOString()
      });

      toast.success("Offer updated successfully!");
      router.push("/offers");
    } catch (error: any) {
      console.error(error);
      toast.error(error.message || "Failed to update offer.");
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6 pb-12">
      <PageHeader
        title="Edit Offer"
        breadcrumbs={[
          { label: "Dashboard", href: "/dashboard" },
          { label: "Offers", href: "/offers" },
          { label: "Edit Offer" }
        ]}
      />

      <form onSubmit={handleSubmit} className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100 space-y-8">

        {/* Basic Details */}
        <div>
          <h2 className="text-lg font-bold text-slate-900 mb-6 flex items-center gap-2">
            <FileText className="h-5 w-5 text-blue-600" /> Basic Details
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Title*</label>
              <input type="text" name="titleEn" value={formData.titleEn} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.titleEn ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all`} />
              {errors.titleEn && <p className="text-red-500 text-xs mt-1">{errors.titleEn}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">ऑफ़र शीर्षक  *</label>
              <input type="text" name="titleHi" value={formData.titleHi} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.titleHi ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all`} />
              {errors.titleHi && <p className="text-red-500 text-xs mt-1">{errors.titleHi}</p>}
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-slate-700 mb-2">Description*</label>
              <textarea name="descriptionEn" rows={3} value={formData.descriptionEn} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.descriptionEn ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all`} />
              {errors.descriptionEn && <p className="text-red-500 text-xs mt-1">{errors.descriptionEn}</p>}
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-slate-700 mb-2">विवरण *</label>
              <textarea name="descriptionHi" rows={3} value={formData.descriptionHi} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.descriptionHi ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all`} />
              {errors.descriptionHi && <p className="text-red-500 text-xs mt-1">{errors.descriptionHi}</p>}
            </div>
          </div>
        </div>

        {/* Image */}
        <div className="pt-6 border-t border-slate-100">
          <h2 className="text-lg font-bold text-slate-900 mb-6 flex items-center gap-2">
            <ImageIcon className="h-5 w-5 text-blue-600" /> Offer Banner Image *
          </h2>
          <div className="flex flex-col gap-4">
            <div className={`w-full md:w-[480px] h-[270px] rounded-xl border-2 border-dashed flex items-center justify-center bg-slate-50 overflow-hidden ${errors.offerImage ? 'border-red-500' : 'border-slate-300'}`}>
              {imagePreview ? (
                <img src={imagePreview} alt="Preview" className="h-full w-full object-cover" />
              ) : (
                <div className="text-center text-slate-400">
                  <ImageIcon className="h-10 w-10 mx-auto mb-2 opacity-50" />
                  <span className="text-sm font-medium">16:9 Aspect Ratio</span>
                </div>
              )}
            </div>
            <div className="flex items-center space-x-4">
              <input type="file" accept="image/*" onChange={handleImageChange} className="block w-full max-w-sm text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" />
              {imagePreview && (
                <button type="button" onClick={handleRemoveImage} className="px-3 py-1.5 text-sm text-red-600 bg-red-50 hover:bg-red-100 rounded-full font-medium transition-colors">
                  Remove
                </button>
              )}
            </div>
            {errors.offerImage && <p className="text-red-500 text-xs">{errors.offerImage}</p>}
          </div>
        </div>

        {/* Discount & Applicability */}
        <div className="pt-6 border-t border-slate-100">
          <h2 className="text-lg font-bold text-slate-900 mb-6 flex items-center gap-2">
            <Tag className="h-5 w-5 text-blue-600" /> Offer Configuration
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Applicable Project *</label>
              <select name="projectId" value={formData.projectId} onChange={handleChange} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all">
                <option value="global">Global (All Projects)</option>
                {projects.map(p => (
                  <option key={p.id} value={p.id}>{p.name?.en || p.name}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Promo Code (Cannot be changed)</label>
              <input type="text" name="code" value={formData.code} disabled className="w-full px-4 py-2.5 bg-slate-100 border border-slate-200 rounded-xl text-slate-500 font-bold uppercase tracking-wide cursor-not-allowed" />
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Discount Type *</label>
              <div className="flex gap-4">
                <label className={`flex-1 flex items-center justify-center gap-2 p-3 border rounded-xl cursor-pointer transition-all ${formData.discountType === 'PERCENTAGE' ? 'border-blue-600 bg-blue-50 text-blue-700' : 'border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100'}`}>
                  <input type="radio" name="discountType" value="PERCENTAGE" checked={formData.discountType === 'PERCENTAGE'} onChange={handleChange} className="hidden" />
                  <Percent className="h-4 w-4" />
                  <span className="font-semibold">Percentage (%)</span>
                </label>
                <label className={`flex-1 flex items-center justify-center gap-2 p-3 border rounded-xl cursor-pointer transition-all ${formData.discountType === 'FLAT' ? 'border-blue-600 bg-blue-50 text-blue-700' : 'border-slate-200 bg-slate-50 text-slate-600 hover:bg-slate-100'}`}>
                  <input type="radio" name="discountType" value="FLAT" checked={formData.discountType === 'FLAT'} onChange={handleChange} className="hidden" />
                  <IndianRupee className="h-4 w-4" />
                  <span className="font-semibold">Flat (₹)</span>
                </label>
              </div>
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Discount Value *</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  {formData.discountType === 'PERCENTAGE' ? <Percent className="h-4 w-4 text-slate-400" /> : <IndianRupee className="h-4 w-4 text-slate-400" />}
                </div>
                <input type="number" name="discountValue" min="0" max={formData.discountType === 'PERCENTAGE' ? "100" : undefined} step="0.01" value={formData.discountValue} onChange={handleChange} onBlur={handleBlur} placeholder={formData.discountType === 'PERCENTAGE' ? '10' : '50000'} className={`w-full pl-10 pr-4 py-2.5 bg-slate-50 border ${errors.discountValue ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 font-semibold transition-all`} />
              </div>
              {errors.discountValue && <p className="text-red-500 text-xs mt-1">{errors.discountValue}</p>}
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2 flex items-center gap-2">
                <Calendar className="h-4 w-4 text-slate-400" /> Start Date *
              </label>
              <input type="date" name="startDate" value={formData.startDate} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.startDate ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all`} />
              {errors.startDate && <p className="text-red-500 text-xs mt-1">{errors.startDate}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2 flex items-center gap-2">
                <Calendar className="h-4 w-4 text-slate-400" /> End Date *
              </label>
              <input type="date" name="endDate" value={formData.endDate} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.endDate ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all`} />
              {errors.endDate && <p className="text-red-500 text-xs mt-1">{errors.endDate}</p>}
            </div>
          </div>
        </div>

        {/* Status */}
        <div className="pt-6 border-t border-slate-100">
          <label className="block text-sm font-semibold text-slate-700 mb-2">Offer Status *</label>
          <select name="status" value={formData.status} onChange={handleChange} className="w-full md:w-1/2 px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all">
            <option value="ACTIVE">Active</option>
            <option value="INACTIVE">Inactive</option>
            <option value="EXPIRED">Expired</option>
          </select>
          <p className="text-xs text-slate-500 mt-2">Only Active offers can be applied by users.</p>
        </div>

        <div className="flex items-center justify-end gap-4 pt-4 border-t border-slate-100">
          <button type="button" onClick={() => router.back()} className="px-6 py-3 text-slate-600 font-semibold hover:bg-slate-100 rounded-xl transition-colors">
            Cancel
          </button>
          <button type="submit" disabled={saving} className="inline-flex items-center px-8 py-3 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 transition-colors shadow-sm shadow-blue-200 disabled:opacity-70 disabled:cursor-not-allowed">
            {saving ? (
              <><div className="h-5 w-5 mr-2 animate-spin rounded-full border-b-2 border-white"></div> Saving...</>
            ) : (
              <><CheckCircle className="h-5 w-5 mr-2" /> Update Offer</>
            )}
          </button>
        </div>
      </form>

      <Modal
        isOpen={isCropModalOpen}
        onClose={() => setIsCropModalOpen(false)}
        title="Crop Offer Image"
        maxWidth="2xl"
        footer={
          <>
            <button onClick={() => setIsCropModalOpen(false)} className="px-4 py-2 text-slate-600 hover:bg-slate-200 rounded-lg transition-colors font-medium">Cancel</button>
            <button onClick={handleCropConfirm} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium">Crop & Save</button>
          </>
        }
      >
        <div className="relative w-full h-[450px] bg-slate-900 rounded-xl overflow-hidden">
          {imageToCrop && (
            <Cropper
              image={imageToCrop}
              crop={crop}
              zoom={zoom}
              aspect={16 / 9}
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
