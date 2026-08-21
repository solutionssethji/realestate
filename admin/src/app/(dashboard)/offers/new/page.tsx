/* eslint-disable react-hooks/immutability */
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client";

import { useState, useEffect } from "react";
import api from "@/lib/api";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import { useLanguage } from '@/context/LanguageContext';
import { storage } from "@/lib/firebase";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { resizeImage } from "@/lib/imageUtils";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { Select } from "@/components/ui/Select";
import { Button } from "@/components/ui/Button";
import { PageHeader } from "@/components/ui/PageHeader";

export default function NewOfferPage() {
  const { t } = useLanguage();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [projects, setProjects] = useState([]);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const [formData, setFormData] = useState({
    projectId: "",
    title: { en: "", hi: "" },
    description: { en: "", hi: "" },
    image: "",
    startDate: "",
    endDate: "",
    discountType: "PERCENTAGE",
    discountValue: "",
    active: true,
  });

  useEffect(() => {
    api.get("/projects").then(res => setProjects(res.data.data || [])).catch(console.error);
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const value = e.target.type === 'checkbox' ? (e.target as HTMLInputElement).checked : e.target.value;
    setFormData({ ...formData, [e.target.name]: value });
    if (errors[e.target.name]) {
      setErrors({ ...errors, [e.target.name]: "" });
    }
  };

  const handleNestedChange = (field: 'title' | 'description', lang: 'en' | 'hi', value: string) => {
    setFormData({
      ...formData,
      [field]: { ...formData[field], [lang]: value }
    });
    if (errors[`${field}_${lang}`]) {
      setErrors({ ...errors, [`${field}_${lang}`]: "" });
    }
  };

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    const newErrors: Record<string, string> = {};
    if (!formData.title.en?.trim()) newErrors.title_en = "English title is required";
    if (!formData.title.hi?.trim()) newErrors.title_hi = "Hindi title is required";
    if (!formData.description.en?.trim()) newErrors.description_en = "English description is required";
    if (!formData.description.hi?.trim()) newErrors.description_hi = "Hindi description is required";
    if (!formData.startDate) newErrors.startDate = "Start date is required";
    if (!formData.endDate) newErrors.endDate = "End date is required";
    if (!formData.discountValue) newErrors.discountValue = "Discount value is required";
    if (!formData.image && !imageFile) newErrors.image = "Offer image is required";

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    setErrors({});

    setLoading(true);

    try {
      let finalImageUrl = formData.image;

      // Upload image to Firebase Storage if a new file was selected
      if (imageFile) {
        // Compress and resize the image before uploading
        const optimizedFile = await resizeImage(imageFile, 1920, 1080, 0.85);

        const fileExt = optimizedFile.name.split('.').pop() || 'jpg';
        const fileName = `offer_${Date.now()}.${fileExt}`;
        const storageRef = ref(storage, `offers/${fileName}`);
        const snapshot = await uploadBytes(storageRef, optimizedFile);
        finalImageUrl = await getDownloadURL(snapshot.ref);
      }

      const payload = {
        ...formData,
        image: finalImageUrl,
        projectId: formData.projectId || undefined,
        startDate: new Date(formData.startDate).toISOString(),
        endDate: new Date(formData.endDate).toISOString(),
        discountType: formData.discountType,
        discountValue: Number(formData.discountValue) || 0,
      };

      await api.post("/offers", payload);
      toast.success("Offer created successfully!");
      router.push("/offers");
      router.refresh();
    } catch (err: any) {
      console.error("Save offer error:", err);
      const errorMessage = err?.response?.data?.message ||
        err?.message ||
        "Failed to save offer.";
      toast.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="space-y-6 pb-12">
      <PageHeader
        title={t('new_offer')}
        breadcrumbs={[{ label: "Dashboard", href: "/dashboard" }, { label: "Offers", href: "/offers" }, { label: "New Offer" }]}
      />

      <form onSubmit={handleSubmit} noValidate className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Offer Details</CardTitle>
            <CardDescription>Provide the promotional message and target project.</CardDescription>
          </CardHeader>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="md:col-span-2">
              <Select
                label="Target Project"
                name="projectId"
                value={formData.projectId}
                onChange={handleChange}
                options={[
                  { value: "", label: t('global_offer') },
                  ...projects.map((p: any) => ({ value: p.id, label: typeof p.name === 'string' ? p.name : (p.name?.en || 'Unnamed Project') }))
                ]}
                helperText="Leave empty to make this a global offer across all projects."
              />
            </div>

            <div className="md:col-span-1">
              <Select
                label="Discount Type"
                name="discountType"
                value={formData.discountType}
                onChange={handleChange}
                options={[
                  { value: "PERCENTAGE", label: "Percentage (%)" },
                  { value: "FLAT", label: "Flat Amount (₹)" }
                ]}
              />
            </div>
            <div className="md:col-span-1">
              <Input
                label="Discount Value"
                name="discountValue"
                type="number"
                required
                value={formData.discountValue}
                onChange={handleChange}
                error={errors.discountValue}
                placeholder="e.g. 10"
              />
            </div>

            {/* ENGLISH SECTION */}
            <div className="md:col-span-2 space-y-4">
              <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('english')}</h4>

              <Input
                label="Offer Title"
                name="title_en"
                required
                value={formData.title.en}
                onChange={(e) => handleNestedChange('title', 'en', e.target.value)}
                error={errors.title_en}
                placeholder="e.g. Diwali Dhamaka 20% Off"
              />

              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Description<span className="text-red-500">*</span></label>
                <textarea
                  required
                  rows={3}
                  value={formData.description.en}
                  onChange={(e) => handleNestedChange('description', 'en', e.target.value)}
                  placeholder="Details of the offer in English..."
                  className={`block w-full px-4 py-2.5 bg-white border ${errors.description_en ? 'border-red-300 bg-red-50/50 focus:ring-red-500' : 'border-slate-200 focus:ring-blue-500'} rounded-xl text-slate-900 focus:outline-none focus:ring-2 transition-all shadow-sm resize-none`}
                />
                {errors.description_en && (
                  <p className="mt-1.5 text-sm text-red-600 font-medium animate-in fade-in slide-in-from-top-1">
                    {errors.description_en}
                  </p>
                )}
              </div>
            </div>

            {/* HINDI SECTION */}
            <div className="md:col-span-2 space-y-4 pt-4 border-t border-slate-100">
              <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('hindi')}</h4>

              <Input
                label="ऑफ़र शीर्षक "
                name="title_hi"
                required
                value={formData.title.hi}
                onChange={(e) => handleNestedChange('title', 'hi', e.target.value)}
                error={errors.title_hi}
                placeholder="e.g. दिवाली धमाका २०% छूट"
              />

              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1.5">विवरण  <span className="text-red-500">*</span></label>
                <textarea
                  required
                  rows={3}
                  value={formData.description.hi}
                  onChange={(e) => handleNestedChange('description', 'hi', e.target.value)}
                  placeholder="Details of the offer in Hindi..."
                  className={`block w-full px-4 py-2.5 bg-white border ${errors.description_hi ? 'border-red-300 bg-red-50/50 focus:ring-red-500' : 'border-slate-200 focus:ring-blue-500'} rounded-xl text-slate-900 focus:outline-none focus:ring-2 transition-all shadow-sm resize-none`}
                />
                {errors.description_hi && (
                  <p className="mt-1.5 text-sm text-red-600 font-medium animate-in fade-in slide-in-from-top-1">
                    {errors.description_hi}
                  </p>
                )}
              </div>
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-slate-700 mb-1.5">Offer Image *</label>
              <input
                type="file"
                accept="image/*"
                required={!formData.image}
                onChange={(e) => {
                  if (e.target.files && e.target.files.length > 0) {
                    const file = e.target.files[0];
                    if (file.size > 5 * 1024 * 1024) {
                      toast.error("Image size must be less than 5MB");
                      e.target.value = "";
                      setImageFile(null);
                      return;
                    }
                    setImageFile(file);
                    if (errors.image) setErrors({ ...errors, image: "" });
                  }
                }}
                className="block w-full text-sm text-slate-500
                  file:mr-4 file:py-2 file:px-4
                  file:rounded-xl file:border-0
                  file:text-sm file:font-semibold
                  file:bg-blue-50 file:text-blue-700
                  hover:file:bg-blue-100 transition-colors"
              />
              <p className="mt-1.5 text-xs text-slate-500 font-medium">Max file size: 5MB. Recommended resolution: 1920x1080px (Image will be automatically optimized).</p>
              {errors.image && (
                <p className="mt-1.5 text-sm text-red-600 font-medium animate-in fade-in slide-in-from-top-1">
                  {errors.image}
                </p>
              )}
              {formData.image && !imageFile && (
                <p className="mt-2 text-sm text-slate-500">Current image uploaded.</p>
              )}
              {imageFile && (
                <p className="mt-2 text-sm text-blue-600">New image selected: {imageFile.name} ({(imageFile.size / (1024 * 1024)).toFixed(2)} MB)</p>
              )}
            </div>
          </div>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Validity & Status</CardTitle>
            <CardDescription>When should this offer be visible?</CardDescription>
          </CardHeader>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Input
              label="Start Date"
              type="date"
              name="startDate"
              required
              value={formData.startDate}
              onChange={handleChange}
              error={errors.startDate}
            />
            <Input
              label="End Date"
              type="date"
              name="endDate"
              required
              value={formData.endDate}
              onChange={handleChange}
              error={errors.endDate}
            />
            <div className="md:col-span-2">
              <label className="flex items-center space-x-3 p-4 border border-slate-200 rounded-xl cursor-pointer hover:bg-slate-50 transition-colors">
                <input
                  type="checkbox"
                  name="active"
                  checked={formData.active}
                  onChange={handleChange}
                  className="h-5 w-5 text-blue-600 focus:ring-blue-500 border-slate-300 rounded cursor-pointer"
                />
                <div>
                  <span className="block text-sm font-semibold text-slate-900">Active Status</span>
                  <span className="block text-xs text-slate-500 mt-0.5">If checked, the offer will be visible to users during the validity period.</span>
                </div>
              </label>
            </div>
          </div>
        </Card>

        <div className="flex items-center justify-end space-x-4 pt-4">
          <Button
            type="button"
            variant="secondary"
            onClick={() => router.push("/offers")}
          >
            Cancel
          </Button>
          <Button
            type="submit"
            isLoading={loading}
          >
            Save Offer
          </Button>
        </div>
      </form>
    </div>
  );
}
