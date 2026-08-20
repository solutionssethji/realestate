/* eslint-disable react-hooks/immutability */
"use client";

import { useState, useEffect } from "react";
import api from "@/lib/api";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import { useLanguage } from '@/context/LanguageContext';
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { Select } from "@/components/ui/Select";
import { Button } from "@/components/ui/Button";

interface PlotFormProps {
  initialData?: any;
  isEdit?: boolean;
}

export default function PlotForm({ initialData, isEdit = false }: PlotFormProps) {
  const { t } = useLanguage();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [projects, setProjects] = useState([]);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const [formData, setFormData] = useState({
    projectId: initialData?.projectId || "",
    plotNumber: initialData?.plotNumber || "",
    size: initialData?.size || "",
    dimensions: initialData?.dimensions || "",
    facing: typeof initialData?.facing === 'string' ? { en: initialData.facing, hi: "" } : { en: initialData?.facing?.en || "", hi: initialData?.facing?.hi || "" },
    road: typeof initialData?.road === 'string' ? { en: initialData.road, hi: "" } : { en: initialData?.road?.en || "", hi: initialData?.road?.hi || "" },
    price: initialData?.price || "",
    status: initialData?.status || "AVAILABLE",
    isActive: initialData?.isActive !== false,
  });

  useEffect(() => {
    api.get("/projects").then(res => setProjects(res.data.data || [])).catch(console.error);
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    if (errors[e.target.name]) {
      setErrors({ ...errors, [e.target.name]: "" });
    }
  };

  const handleNestedChange = (field: 'facing' | 'road', lang: 'en' | 'hi', value: string) => {
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
    if (!formData.projectId) newErrors.projectId = "Project is required";
    if (!formData.plotNumber?.trim()) newErrors.plotNumber = "Plot number is required";
    if (!formData.size?.toString().trim()) newErrors.size = "Size is required";
    if (!formData.dimensions?.trim()) newErrors.dimensions = "Dimensions are required";
    if (!formData.facing.en?.trim()) newErrors.facing_en = "English facing is required";
    if (!formData.facing.hi?.trim()) newErrors.facing_hi = "Hindi facing is required";
    if (!formData.road.en?.trim()) newErrors.road_en = "English road is required";
    if (!formData.road.hi?.trim()) newErrors.road_hi = "Hindi road is required";
    if (!formData.price?.toString().trim()) newErrors.price = "Price is required";

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }
    setErrors({});

    setLoading(true);

    try {
      const payload = {
        ...formData,
        size: parseFloat(formData.size as string),
        price: parseFloat(formData.price as string),
      };

      if (isEdit) {
        await api.put(`/plots/${initialData.id}`, payload);
        toast.success("Plot updated successfully!");
      } else {
        await api.post("/plots", payload);
        toast.success("Plot created successfully!");
      }

      router.push("/plots");
      router.refresh();
    } catch (err: any) {
      console.error("Save plot error:", err);
      const errorMessage = err?.response?.data?.message ||
        err?.message ||
        "Failed to save plot. Check console for details.";
      toast.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-6 pb-12">
      <Card>
        <CardHeader>
          <CardTitle>Plot Details</CardTitle>
          <CardDescription>Assign the plot to a project and provide its identifier.</CardDescription>
        </CardHeader>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Select
            label="Project"
            name="projectId"
            required
            value={formData.projectId}
            onChange={handleChange}
            error={errors.projectId}
            options={[
              { value: "", label: t('select_a_project') },
              ...projects.map((p: any) => ({ value: p.id, label: typeof p.name === 'string' ? p.name : (p.name?.en || 'Unnamed Project') }))
            ]}
          />
          <Input
            label="Plot Number"
            name="plotNumber"
            required
            value={formData.plotNumber}
            onChange={handleChange}
            error={errors.plotNumber}
            placeholder="e.g. A-101"
          />
        </div>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Pricing & Status</CardTitle>
          <CardDescription>Set the size, price, and current availability.</CardDescription>
        </CardHeader>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Input
            label="Size (sq.yd)"
            type="number"
            step="any"
            name="size"
            required
            value={formData.size}
            onChange={handleChange}
            error={errors.size}
            placeholder="e.g. 150"
          />
          <Input
            label="Dimensions"
            name="dimensions"
            required
            value={formData.dimensions}
            onChange={handleChange}
            error={errors.dimensions}
            placeholder="e.g. 30x45"
          />
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          {/* ENGLISH SECTION */}
          <div className="md:col-span-2 space-y-4">
            <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('english')}</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Input
                label="Facing"
                name="facing_en"
                required
                value={formData.facing.en}
                onChange={(e) => handleNestedChange('facing', 'en', e.target.value)}
                error={errors.facing_en}
                placeholder="e.g. North-East"
              />
              <Input
                label="Road"
                name="road_en"
                required
                value={formData.road.en}
                onChange={(e) => handleNestedChange('road', 'en', e.target.value)}
                error={errors.road_en}
                placeholder="e.g. 40 ft"
              />
            </div>
          </div>

          {/* HINDI SECTION */}
          <div className="md:col-span-2 space-y-4 pt-4 border-t border-slate-100">
            <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('hindi')}</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Input
                label="दिशा "
                name="facing_hi"
                required
                value={formData.facing.hi}
                onChange={(e) => handleNestedChange('facing', 'hi', e.target.value)}
                error={errors.facing_hi}
                placeholder="e.g. उत्तर-पूर्व"
              />
              <Input
                label="सड़क "
                name="road_hi"
                required
                value={formData.road.hi}
                onChange={(e) => handleNestedChange('road', 'hi', e.target.value)}
                error={errors.road_hi}
                placeholder="e.g. 40 फीट"
              />
            </div>
          </div>

          <div className="md:col-span-2 pt-4 border-t border-slate-100">
            <Input
              label="Price (₹)"
              type="number"
              step="any"
              name="price"
              required
              value={formData.price}
              onChange={handleChange}
              error={errors.price}
              placeholder="e.g. 4500000"
            />
          </div>
          <div className="md:col-span-2">
            <Select
              label="Availability Status"
              name="status"
              value={formData.status}
              onChange={handleChange}
              error={errors.status}
              options={[
                { value: "AVAILABLE", label: "🟢 Available" },
                { value: "HOLD", label: "🟡 Hold" },
                { value: "BOOKED_SOLD", label: "🔴 Booked/Sold" },
              ]}
            />
          </div>

          <div className="md:col-span-2 flex items-center justify-between p-4 bg-slate-50 rounded-xl border border-slate-200 mt-2">
            <div>
              <h4 className="text-sm font-semibold text-slate-900">Visibility</h4>
              <p className="text-xs text-slate-500 mt-0.5">Enable or disable this plot on the public app</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input
                type="checkbox"
                name="isActive"
                checked={formData.isActive}
                onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-slate-300 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
              <span className="ml-3 text-sm font-medium text-slate-700">{formData.isActive ? 'Active' : 'Disabled'}</span>
            </label>
          </div>

        </div>
      </Card>

      <div className="flex items-center justify-end space-x-4 pt-4">
        <Button
          type="button"
          variant="secondary"
          onClick={() => router.push("/plots")}
        >
          Cancel
        </Button>
        <Button
          type="submit"
          isLoading={loading}
        >
          Save Plot
        </Button>
      </div>
    </form>
  );
}
