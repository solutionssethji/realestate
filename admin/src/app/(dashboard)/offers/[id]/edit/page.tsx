"use client";

import { useState, useEffect, use } from "react";
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

export default function EditOfferPage({ params }: { params: Promise<{ id: string }> }) {
  const unwrappedParams = use(params);
  const id = unwrappedParams.id;
  const { t } = useLanguage();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [pageLoading, setPageLoading] = useState(true);
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
    active: true,
  });

  useEffect(() => {
    async function init() {
      try {
        const [projectsRes, offerRes] = await Promise.all([
          api.get("/projects"),
          api.get(`/offers/${id}`)
        ]);
        setProjects(projectsRes.data.data || []);

        const offer = offerRes.data.data;
        if (offer) {
          setFormData({
            projectId: offer.projectId || "",
            title: typeof offer.title === 'string' ? { en: offer.title, hi: "" } : { en: offer.title?.en || "", hi: offer.title?.hi || "" },
            description: typeof offer.description === 'string' ? { en: offer.description, hi: "" } : { en: offer.description?.en || "", hi: offer.description?.hi || "" },
            image: offer.image || "",
            startDate: offer.startDate ? new Date(offer.startDate).toISOString().split('T')[0] : "",
            endDate: offer.endDate ? new Date(offer.endDate).toISOString().split('T')[0] : "",
            active: offer.active !== false,
          });
        }
      } catch (err) {
        console.error(err);
        toast.error("Failed to load offer details");
        router.push("/offers");
      } finally {
        setPageLoading(false);
      }
    }
    init();
  }, [id, router]);

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

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    setErrors({});

    setLoading(true);

    try {
      let finalImageUrl = formData.image;

      if (imageFile) {
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
        projectId: formData.projectId || null, // Ensure null instead of "" for global
        startDate: new Date(formData.startDate).toISOString(),
        endDate: new Date(formData.endDate).toISOString(),
      };

      await api.put(`/offers/${id}`, payload);
      toast.success("Offer updated successfully!");
      router.push("/offers");
      router.refresh();
    } catch (err: any) {
      console.error("Save offer error:", err);
      toast.error(err?.response?.data?.message || err?.message || "Failed to save offer.");
    } finally {
      setLoading(false);
    }
  }

  if (pageLoading) return <div>Loading...</div>;

  return (
    <div className="space-y-6 pb-12">
      <PageHeader
        title="Edit Offer"
        breadcrumbs={[{ label: "Dashboard", href: "/dashboard" }, { label: "Offers", href: "/offers" }, { label: "Edit Offer" }]}
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
                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Description <span className="text-red-500">*</span></label>
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
                  }
                }}
                className="block w-full text-sm text-slate-500
                  file:mr-4 file:py-2 file:px-4
                  file:rounded-xl file:border-0
                  file:text-sm file:font-semibold
                  file:bg-blue-50 file:text-blue-700
                  hover:file:bg-blue-100 transition-colors"
              />
              <p className="mt-1.5 text-xs text-slate-500 font-medium">Max file size: 5MB. Recommended resolution: 1920x1080px.</p>
              {formData.image && !imageFile && (
                <div className="mt-2 text-sm text-slate-500 flex items-center">
                  Current image: <img src={formData.image} className="h-10 w-10 ml-2 rounded object-cover" alt="Current" />
                </div>
              )}
              {imageFile && (
                <p className="mt-2 text-sm text-blue-600">New image selected: {imageFile.name}</p>
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
          <Button type="button" variant="secondary" onClick={() => router.push("/offers")}>Cancel</Button>
          <Button type="submit" isLoading={loading}>Update Offer</Button>
        </div>
      </form>
    </div>
  );
}
