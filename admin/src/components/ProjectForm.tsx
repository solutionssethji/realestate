/* eslint-disable react-hooks/immutability */
"use client";

import { useState } from "react";
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
import { X } from "lucide-react";

interface ProjectFormProps {
  initialData?: any;
  isEdit?: boolean;
}

export default function ProjectForm({ initialData, isEdit = false }: ProjectFormProps) {
  const { t } = useLanguage();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  // File states
  const [photoFiles, setPhotoFiles] = useState<File[]>([]);
  const [siteLayoutFile, setSiteLayoutFile] = useState<File | null>(null);

  const [formData, setFormData] = useState({
    name: typeof initialData?.name === 'string' ? { en: initialData.name, hi: "" } : { en: initialData?.name?.en || "", hi: initialData?.name?.hi || "" },
    projectVideo: initialData?.projectVideo || "",
    location: typeof initialData?.location === 'string' ? { en: initialData.location, hi: "" } : { en: initialData?.location?.en || "", hi: initialData?.location?.hi || "" },
    googleMap: initialData?.googleMap || "",
    availablePlots: initialData?.availablePlots || "",
    plotSize: typeof initialData?.plotSize === 'string' ? { en: initialData.plotSize, hi: "" } : { en: initialData?.plotSize?.en || "", hi: initialData?.plotSize?.hi || "" },
    plotPrice: typeof initialData?.plotPrice === 'string' ? { en: initialData.plotPrice, hi: "" } : { en: initialData?.plotPrice?.en || "", hi: initialData?.plotPrice?.hi || "" },
    roadWidth: typeof initialData?.roadWidth === 'string' ? { en: initialData.roadWidth, hi: "" } : { en: initialData?.roadWidth?.en || "", hi: initialData?.roadWidth?.hi || "" },
    developmentStatus: initialData?.developmentStatus || { en: "Upcoming", hi: "आगामी" },
    isActive: initialData?.isActive !== undefined ? initialData?.isActive : true,
    isFeatured: initialData?.isFeatured !== undefined ? initialData?.isFeatured : false,

    // Existing URLs from DB
    projectPhotos: initialData?.projectPhotos || [],
    siteLayout: initialData?.siteLayout || "",

    // Facilities
    facilities: initialData?.facilities || [],
  });

  const [customFacility, setCustomFacility] = useState({ en: "", hi: "" });

  const predefinedFacilities = [
    { en: '24×7 Security', hi: '24×7 सुरक्षा' },
    { en: 'Park', hi: 'पार्क' },
    { en: 'Temple', hi: 'मंदिर' },
    { en: 'Road', hi: 'सड़क' },
    { en: 'Street Lighting', hi: 'स्ट्रीट लाइट' },
    { en: 'Plantation/Greenery', hi: 'वृक्षारोपण/हरियाली' },
    { en: 'Water Facility', hi: 'पानी की सुविधा' },
  ];

  const toggleFacility = (facility: { en: string, hi: string }) => {
    const exists = formData.facilities.some((f: any) => f.en === facility.en);
    if (exists) {
      setFormData({ ...formData, facilities: formData.facilities.filter((f: any) => f.en !== facility.en) });
    } else {
      setFormData({ ...formData, facilities: [...formData.facilities, facility] });
    }
  };

  const addCustomFacility = () => {
    if (customFacility.en.trim() && customFacility.hi.trim()) {
      setFormData({ ...formData, facilities: [...formData.facilities, { ...customFacility }] });
      setCustomFacility({ en: "", hi: "" });
    }
  };

  const removeFacility = (index: number) => {
    const newFacs = [...formData.facilities];
    newFacs.splice(index, 1);
    setFormData({ ...formData, facilities: newFacs });
  };

  const validateField = (name: string, value: string) => {
    let error = "";
    switch (name) {
      case "name_en": if (!value.trim()) error = "English project name is required"; break;
      case "name_hi": if (!value.trim()) error = "Hindi project name is required"; break;
      case "location_en": if (!value.trim()) error = "English location is required"; break;
      case "location_hi": if (!value.trim()) error = "Hindi location is required"; break;
      case "googleMap": if (!value.trim()) error = "Google Map URL is required"; break;
      case "availablePlots": if (!value.toString().trim()) error = "Available plots is required"; break;
      case "plotSize_en": if (!value.trim()) error = "English plot size is required"; break;
      case "plotSize_hi": if (!value.trim()) error = "Hindi plot size is required"; break;
      case "plotPrice_en": if (!value.trim()) error = "English plot price is required"; break;
      case "plotPrice_hi": if (!value.trim()) error = "Hindi plot price is required"; break;
      case "roadWidth_en": if (!value.trim()) error = "English road width is required"; break;
      case "roadWidth_hi": if (!value.trim()) error = "Hindi road width is required"; break;
      case "projectVideo": if (!value.trim()) error = "Project video is required"; break;
      default: break;
    }
    return error;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
    setErrors(prev => ({ ...prev, [name]: validateField(name, value) }));
  };

  const handleBlur = (e: React.FocusEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setErrors(prev => ({ ...prev, [name]: validateField(name, value) }));
  };

  const handleNestedChange = (field: 'name' | 'location' | 'plotSize' | 'plotPrice' | 'roadWidth' | 'developmentStatus', lang: 'en' | 'hi', value: string) => {
    const key = `${field}_${lang}`;
    setFormData({
      ...formData,
      [field]: { ...formData[field], [lang]: value }
    });
    setErrors(prev => ({ ...prev, [key]: validateField(key, value) }));
  };

  const handleNestedBlur = (field: 'name' | 'location' | 'plotSize' | 'plotPrice' | 'roadWidth' | 'developmentStatus', lang: 'en' | 'hi', value: string) => {
    const key = `${field}_${lang}`;
    setErrors(prev => ({ ...prev, [key]: validateField(key, value) }));
  };

  const handleRemoveExistingPhoto = (index: number) => {
    const newPhotos = [...formData.projectPhotos];
    newPhotos.splice(index, 1);
    setFormData({ ...formData, projectPhotos: newPhotos });
    if (errors.projectPhotos && newPhotos.length === 0 && photoFiles.length === 0) {
      setErrors({ ...errors, projectPhotos: "At least one project photo is required" });
    } else if (errors.projectPhotos) {
      setErrors({ ...errors, projectPhotos: "" });
    }
  };

  const handleRemoveNewPhoto = (index: number) => {
    const newFiles = [...photoFiles];
    newFiles.splice(index, 1);
    setPhotoFiles(newFiles);
    if (errors.projectPhotos && formData.projectPhotos.length === 0 && newFiles.length === 0) {
      setErrors({ ...errors, projectPhotos: "At least one project photo is required" });
    } else if (errors.projectPhotos) {
      setErrors({ ...errors, projectPhotos: "" });
    }
  };

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    const newErrors: Record<string, string> = {};
    if (!formData.name.en?.trim()) newErrors.name_en = "English project name is required";
    if (!formData.name.hi?.trim()) newErrors.name_hi = "Hindi project name is required";
    if (!formData.location.en?.trim()) newErrors.location_en = "English location is required";
    if (!formData.location.hi?.trim()) newErrors.location_hi = "Hindi location is required";
    if (!formData.googleMap?.trim()) newErrors.googleMap = "Google Map URL is required";
    if (!formData.availablePlots?.toString().trim()) newErrors.availablePlots = "Available plots is required";
    if (!formData.plotSize.en?.trim()) newErrors.plotSize_en = "English plot size is required";
    if (!formData.plotSize.hi?.trim()) newErrors.plotSize_hi = "Hindi plot size is required";
    if (!formData.plotPrice.en?.trim()) newErrors.plotPrice_en = "English plot price is required";
    if (!formData.plotPrice.hi?.trim()) newErrors.plotPrice_hi = "Hindi plot price is required";
    if (!formData.roadWidth.en?.trim()) newErrors.roadWidth_en = "English road width is required";
    if (!formData.roadWidth.hi?.trim()) newErrors.roadWidth_hi = "Hindi road width is required";
    if (!formData.projectVideo?.trim()) newErrors.projectVideo = "Project video is required";
    if (formData.projectPhotos.length === 0 && photoFiles.length === 0) newErrors.projectPhotos = "At least one project photo is required";
    if (!formData.siteLayout && !siteLayoutFile) newErrors.siteLayout = "Site layout is required";

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error("Please fix the validation errors in the form.");
      return;
    }
    setErrors({});

    setLoading(true);

    try {
      let finalPhotos = [...formData.projectPhotos];
      let finalSiteLayoutUrl = formData.siteLayout;

      // Upload Site Layout
      if (siteLayoutFile) {
        const optimizedFile = await resizeImage(siteLayoutFile);
        const fileExt = optimizedFile.name.split('.').pop() || 'jpg';
        const fileName = `sitelayout_${Date.now()}.${fileExt}`;
        const storageRef = ref(storage, `projects/${fileName}`);
        const snapshot = await uploadBytes(storageRef, optimizedFile);
        finalSiteLayoutUrl = await getDownloadURL(snapshot.ref);
      }

      // Upload Project Photos
      if (photoFiles.length > 0) {
        const uploadPromises = photoFiles.map(async (file, index) => {
          const optimizedFile = await resizeImage(file);
          const fileExt = optimizedFile.name.split('.').pop() || 'jpg';
          const fileName = `photo_${Date.now()}_${index}.${fileExt}`;
          const storageRef = ref(storage, `projects/${fileName}`);
          const snapshot = await uploadBytes(storageRef, optimizedFile);
          return await getDownloadURL(snapshot.ref);
        });

        const uploadedUrls = await Promise.all(uploadPromises);
        finalPhotos = [...finalPhotos, ...uploadedUrls];
      }

      const payload = {
        name: formData.name,
        projectVideo: formData.projectVideo,
        location: formData.location,
        googleMap: formData.googleMap,
        availablePlots: formData.availablePlots,
        plotSize: formData.plotSize,
        plotPrice: formData.plotPrice,
        roadWidth: formData.roadWidth,
        developmentStatus: formData.developmentStatus,
        isActive: formData.isActive,
        isFeatured: formData.isFeatured,
        projectPhotos: finalPhotos,
        siteLayout: finalSiteLayoutUrl,
        facilities: formData.facilities,
      };

      if (isEdit) {
        await api.put(`/projects/${initialData.id}`, payload);
        toast.success("Project updated successfully!");
      } else {
        await api.post("/projects", payload);
        toast.success("Project created successfully!");
      }

      router.push("/projects");
      router.refresh();
    } catch (err: any) {
      console.error("Save project error:", err);
      const errorMessage = err?.response?.data?.message || err?.message || "Failed to save project. Check console for details.";
      toast.error(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} noValidate className="space-y-6 pb-12">
      <Card>
        <CardHeader>
          <CardTitle>Core Details</CardTitle>
          <CardDescription>Basic information about the project and location.</CardDescription>
        </CardHeader>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* ENGLISH SECTION */}
          <div className="md:col-span-2 space-y-4">
            <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('english')}</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Input label="Project Name " name="name_en" required value={formData.name.en} onChange={(e) => handleNestedChange('name', 'en', e.target.value)} onBlur={(e) => handleNestedBlur('name', 'en', e.target.value)} error={errors.name_en} placeholder="e.g. Sunrise Valley" />
              <Input label="Location " name="location_en" required value={formData.location.en} onChange={(e) => handleNestedChange('location', 'en', e.target.value)} onBlur={(e) => handleNestedBlur('location', 'en', e.target.value)} error={errors.location_en} placeholder="e.g. Sector 128, Noida" />
              <div className="md:col-span-2">
                <Select
                  label="Development Status "
                  name="devStatus_en"
                  required
                  value={formData.developmentStatus.en}
                  onChange={(e) => handleNestedChange('developmentStatus', 'en', e.target.value)}
                  options={[
                    { value: 'Upcoming', label: 'Upcoming' },
                    { value: 'Ongoing', label: 'Ongoing' },
                    { value: 'Completed', label: 'Completed' },
                  ]}
                />
              </div>
            </div>
          </div>

          {/* HINDI SECTION */}
          <div className="md:col-span-2 space-y-4 pt-4 border-t border-slate-100">
            <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('hindi')}</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Input label="प्रोजेक्ट का नाम " name="name_hi" required value={formData.name.hi} onChange={(e) => handleNestedChange('name', 'hi', e.target.value)} onBlur={(e) => handleNestedBlur('name', 'hi', e.target.value)} error={errors.name_hi} placeholder="e.g. सनराइज वैली" />
              <Input label="स्थान " name="location_hi" required value={formData.location.hi} onChange={(e) => handleNestedChange('location', 'hi', e.target.value)} onBlur={(e) => handleNestedBlur('location', 'hi', e.target.value)} error={errors.location_hi} placeholder="e.g. सेक्टर 128, नोएडा" />
              <div className="md:col-span-2">
                <Select
                  label="विकास की स्थिति "
                  name="devStatus_hi"
                  required
                  value={formData.developmentStatus.hi}
                  onChange={(e) => handleNestedChange('developmentStatus', 'hi', e.target.value)}
                  options={[
                    { value: 'आगामी', label: 'आगामी' },
                    { value: 'जारी है', label: 'जारी है' },
                    { value: 'पूर्ण', label: 'पूर्ण' },
                  ]}
                />
              </div>
            </div>
          </div>
          <div className="md:col-span-2 space-y-3 pt-4 border-t border-slate-100">
            <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">Map Configuration</h4>
            <div className="relative border-l-4 border-blue-500 pl-4 py-2 bg-slate-50 rounded-r-lg">
              <Input label="Google Map (Embed or Share URL)" name="googleMap" required value={formData.googleMap} onChange={handleChange} onBlur={handleBlur} error={errors.googleMap} placeholder="e.g. https://www.google.com/maps/embed?..." />
              <p className="text-[10px] text-slate-500 mt-1 italic">Note: Use the Google Maps "Embed Map" URL for best results.</p>
            </div>
          </div>
          <div className="md:col-span-2 grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="flex items-center justify-between p-4 bg-slate-50 border border-slate-200 rounded-xl">
              <div>
                <h3 className="text-sm font-semibold text-slate-800">Project Visibility</h3>
                <p className="text-xs text-slate-500 mt-0.5">Enable or disable this project on the public app</p>
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

            <div className="flex items-center justify-between p-4 bg-slate-50 border border-slate-200 rounded-xl">
              <div>
                <h3 className="text-sm font-semibold text-slate-800">Featured Project</h3>
                <p className="text-xs text-slate-500 mt-0.5">Show this project on the home screen</p>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  name="isFeatured"
                  checked={formData.isFeatured}
                  onChange={(e) => setFormData({ ...formData, isFeatured: e.target.checked })}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-slate-300 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-500"></div>
                <span className="ml-3 text-sm font-medium text-slate-700">{formData.isFeatured ? 'Featured' : 'Standard'}</span>
              </label>
            </div>
          </div>
        </div>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Plot Specifications</CardTitle>
          <CardDescription>Details about the available plots within this project.</CardDescription>
        </CardHeader>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Input label="Available Plots" name="availablePlots" type="number" required value={formData.availablePlots} onChange={handleChange} onBlur={handleBlur} error={errors.availablePlots} placeholder="e.g. 25" />

          {/* ENGLISH SECTION */}
          <div className="md:col-span-2 space-y-4">
            <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('english')}</h4>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <Input label="Plot Size " name="plotSize_en" required value={formData.plotSize.en} onChange={(e) => handleNestedChange('plotSize', 'en', e.target.value)} onBlur={(e) => handleNestedBlur('plotSize', 'en', e.target.value)} error={errors.plotSize_en} placeholder="e.g. 100-200 sq.yd" />
              <Input label="Plot Price " name="plotPrice_en" required value={formData.plotPrice.en} onChange={(e) => handleNestedChange('plotPrice', 'en', e.target.value)} onBlur={(e) => handleNestedBlur('plotPrice', 'en', e.target.value)} error={errors.plotPrice_en} placeholder="e.g. ₹50L onwards" />
              <Input label="Road Width " name="roadWidth_en" required value={formData.roadWidth.en} onChange={(e) => handleNestedChange('roadWidth', 'en', e.target.value)} onBlur={(e) => handleNestedBlur('roadWidth', 'en', e.target.value)} error={errors.roadWidth_en} placeholder="e.g. 40 ft" />
            </div>
          </div>

          {/* HINDI SECTION */}
          <div className="md:col-span-2 space-y-4 pt-4 border-t border-slate-100">
            <h4 className="font-bold text-slate-900 bg-slate-50 px-3 py-1.5 rounded-lg inline-block text-xs uppercase tracking-wider">{t('hindi')}</h4>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <Input label="प्लॉट का आकार " name="plotSize_hi" required value={formData.plotSize.hi} onChange={(e) => handleNestedChange('plotSize', 'hi', e.target.value)} onBlur={(e) => handleNestedBlur('plotSize', 'hi', e.target.value)} error={errors.plotSize_hi} placeholder="e.g. 100-200 वर्ग गज" />
              <Input label="प्लॉट की कीमत " name="plotPrice_hi" required value={formData.plotPrice.hi} onChange={(e) => handleNestedChange('plotPrice', 'hi', e.target.value)} onBlur={(e) => handleNestedBlur('plotPrice', 'hi', e.target.value)} error={errors.plotPrice_hi} placeholder="e.g. ₹50 लाख से शुरू" />
              <Input label="सड़क की चौड़ाई " name="roadWidth_hi" required value={formData.roadWidth.hi} onChange={(e) => handleNestedChange('roadWidth', 'hi', e.target.value)} onBlur={(e) => handleNestedBlur('roadWidth', 'hi', e.target.value)} error={errors.roadWidth_hi} placeholder="e.g. 40 फीट" />
            </div>
          </div>
        </div>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Facilities / Amenities</CardTitle>
          <CardDescription>Select the amenities available in this project.</CardDescription>
        </CardHeader>
        <div className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
            {predefinedFacilities.map((fac, idx) => {
              const isSelected = formData.facilities.some((f: any) => f.en === fac.en);
              return (
                <label key={idx} className={`flex items-start p-3 border rounded-xl cursor-pointer transition-colors ${isSelected ? 'bg-blue-50 border-blue-200' : 'bg-white border-slate-200 hover:bg-slate-50'}`}>
                  <div className="flex items-center h-5">
                    <input
                      type="checkbox"
                      checked={isSelected}
                      onChange={() => toggleFacility(fac)}
                      className="w-4 h-4 text-blue-600 bg-slate-100 border-slate-300 rounded focus:ring-blue-500"
                    />
                  </div>
                  <div className="ml-3 text-sm">
                    <span className="font-medium text-slate-900 block">{fac.en}</span>
                    <span className="text-slate-500 block text-xs mt-0.5">{fac.hi}</span>
                  </div>
                </label>
              );
            })}
          </div>

          <div className="bg-slate-50 p-4 rounded-xl border border-slate-200 space-y-4">
            <h4 className="text-sm font-semibold text-slate-800">Add Custom Amenity (अन्य)</h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Amenity</label>
                <input
                  type="text"
                  value={customFacility.en}
                  onChange={(e) => setCustomFacility({ ...customFacility, en: e.target.value })}
                  placeholder="e.g. Club House"
                  className="w-full px-3 py-2 bg-white border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">सुविधा </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={customFacility.hi}
                    onChange={(e) => setCustomFacility({ ...customFacility, hi: e.target.value })}
                    placeholder="e.g. क्लब हाउस"
                    className="flex-1 px-3 py-2 bg-white border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <button
                    type="button"
                    onClick={addCustomFacility}
                    disabled={!customFacility.en.trim() || !customFacility.hi.trim()}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-semibold hover:bg-blue-700 disabled:opacity-50"
                  >
                    Add
                  </button>
                </div>
              </div>
            </div>

            {formData.facilities.filter((f: any) => !predefinedFacilities.some(pf => pf.en === f.en)).length > 0 && (
              <div className="mt-4 pt-4 border-t border-slate-200">
                <h5 className="text-xs font-semibold text-slate-500 mb-2 uppercase tracking-wider">Custom Amenities</h5>
                <div className="flex flex-wrap gap-2">
                  {formData.facilities.map((fac: any, idx: number) => {
                    const isPredefined = predefinedFacilities.some(pf => pf.en === fac.en);
                    if (isPredefined) return null;
                    return (
                      <span key={idx} className="inline-flex items-center px-3 py-1.5 rounded-lg text-xs font-medium bg-indigo-50 text-indigo-700 border border-indigo-100">
                        {fac.en} / {fac.hi}
                        <button type="button" onClick={() => removeFacility(idx)} className="ml-2 text-indigo-400 hover:text-indigo-600">
                          <X className="w-3 h-3" />
                        </button>
                      </span>
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        </div>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Media & Layout</CardTitle>
          <CardDescription>Upload photos, site layout, and video walkthrough.</CardDescription>
        </CardHeader>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="md:col-span-2">
            <Input label="High-Quality Video / 360° View (URL)" name="projectVideo" required value={formData.projectVideo} onChange={handleChange} onBlur={handleBlur} error={errors.projectVideo} placeholder="e.g. YouTube or Matterport link" />
          </div>

          <div className="md:col-span-2 space-y-3">
            <label className="block text-sm font-semibold text-slate-700">Project Photos <span className="text-red-500">*</span></label>
            <div className="flex flex-wrap gap-4 mb-4">
              {formData.projectPhotos.map((url: string, index: number) => (
                <div key={`existing-${index}`} className="relative w-24 h-24 rounded-lg overflow-hidden border border-slate-200">
                  <img src={url} alt="Project" className="w-full h-full object-cover" />
                  <button type="button" onClick={() => handleRemoveExistingPhoto(index)} className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 hover:bg-red-600">
                    <X className="w-3 h-3" />
                  </button>
                </div>
              ))}
              {photoFiles.map((file, index) => (
                <div key={`new-${index}`} className="relative w-24 h-24 rounded-lg overflow-hidden border border-slate-200 bg-slate-50 flex flex-col items-center justify-center">
                  <span className="text-[10px] text-center px-1 truncate w-full text-slate-600 font-medium">New</span>
                  <span className="text-xs text-center px-1 truncate w-full text-slate-400">{file.name}</span>
                  <button type="button" onClick={() => handleRemoveNewPhoto(index)} className="absolute top-1 right-1 bg-red-500 text-white rounded-full p-1 hover:bg-red-600">
                    <X className="w-3 h-3" />
                  </button>
                </div>
              ))}
            </div>

            <input
              type="file"
              accept="image/*"
              multiple
              required={formData.projectPhotos.length === 0 && photoFiles.length === 0}
              onChange={(e) => {
                if (e.target.files) {
                  const filesArray = Array.from(e.target.files);
                  const validFiles = filesArray.filter(file => {
                    if (file.size > 5 * 1024 * 1024) {
                      toast.error(`Image ${file.name} is larger than 5MB`);
                      return false;
                    }
                    return true;
                  });
                  setPhotoFiles(prev => [...prev, ...validFiles]);
                  if (errors.projectPhotos) setErrors({ ...errors, projectPhotos: "" });
                }
                e.target.value = '';
              }}
              className="block w-full text-sm text-slate-500
                file:mr-4 file:py-2 file:px-4
                file:rounded-xl file:border-0
                file:text-sm file:font-semibold
                file:bg-blue-50 file:text-blue-700
                hover:file:bg-blue-100 transition-colors cursor-pointer"
            />
            <p className="mt-1.5 text-xs text-slate-500 font-medium">Max file size: 5MB per image. Select multiple images to create a gallery.</p>
            {errors.projectPhotos && (
              <p className="mt-1.5 text-sm text-red-600 font-medium animate-in fade-in slide-in-from-top-1">
                {errors.projectPhotos}
              </p>
            )}
          </div>

          <div className="md:col-span-2 space-y-2 mt-4 pt-4 border-t border-slate-100">
            <label className="block text-sm font-semibold text-slate-700 mb-3">Site Layout (Map/Plan) <span className="text-red-500">*</span></label>

            {formData.siteLayout && !siteLayoutFile && (
              <div className="mb-4">
                <p className="text-xs font-medium text-slate-500 mb-2">Current Layout:</p>
                <div className="relative w-48 h-32 rounded-lg overflow-hidden border border-slate-200 shadow-sm">
                  <img src={formData.siteLayout} alt="Site Layout" className="w-full h-full object-cover" />
                </div>
              </div>
            )}

            <input
              type="file"
              accept="image/*"
              required={!formData.siteLayout}
              onChange={(e) => {
                if (e.target.files && e.target.files.length > 0) {
                  const file = e.target.files[0];
                  if (file.size > 5 * 1024 * 1024) {
                    toast.error("Site layout image must be less than 5MB");
                    e.target.value = "";
                    setSiteLayoutFile(null);
                    return;
                  }
                  setSiteLayoutFile(file);
                  if (errors.siteLayout) setErrors({ ...errors, siteLayout: "" });
                }
              }}
              className="block w-full text-sm text-slate-500
                file:mr-4 file:py-2 file:px-4
                file:rounded-xl file:border-0
                file:text-sm file:font-semibold
                file:bg-indigo-50 file:text-indigo-700
                hover:file:bg-indigo-100 transition-colors cursor-pointer"
            />
            <p className="mt-1.5 text-xs text-slate-500 font-medium">Max file size: 5MB. Recommended resolution: 1920x1080px.</p>
            {errors.siteLayout && (
              <p className="mt-1.5 text-sm text-red-600 font-medium animate-in fade-in slide-in-from-top-1">
                {errors.siteLayout}
              </p>
            )}
            {siteLayoutFile && (
              <p className="mt-2 text-sm text-indigo-600">New layout selected: {siteLayoutFile.name}</p>
            )}
          </div>
        </div>
      </Card>

      <div className="flex items-center justify-end space-x-4 pt-4">
        <Button type="button" variant="secondary" onClick={() => router.push("/projects")}>Cancel</Button>
        <Button type="submit" isLoading={loading}>Save Project</Button>
      </div>
    </form>
  );
}
