"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { collection, doc, setDoc } from "firebase/firestore";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { db, storage, createAuthUser } from "@/lib/firebase";
import getCroppedImg from "@/lib/cropImage";
import Cropper from "react-easy-crop";
import { Modal } from "@/components/ui/Modal";
import { PageHeader } from "@/components/ui/PageHeader";
import { User, Mail, Phone, Briefcase, FileText, Building, CheckCircle, Eye, EyeOff } from "lucide-react";
import { toast } from "react-hot-toast";
import { validateStrongPassword } from "@/lib/validators";

export default function AddAgentPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [profileImage, setProfileImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [imageToCrop, setImageToCrop] = useState<string | null>(null);
  const [isCropModalOpen, setIsCropModalOpen] = useState(false);
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<any>(null);
  
  const [showPassword, setShowPassword] = useState(false);

  const [formData, setFormData] = useState({
    fullName: "",
    email: "",
    password: "", // Initial password for the agent
    mobileNumber: "",
    whatsappNumber: "",
    firmName: "",
    panNumber: "",
    aadharNumber: "",
    bankAccountNumber: "",
    ifscCode: "",
    bankName: ""
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  const validateField = (name: string, value: string) => {
    let error = "";
    switch (name) {
      case "email":
        const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
        if (!value) error = "Email is required";
        else if (!emailRegex.test(value)) error = "Enter a valid email address";
        break;
      case "password":
        if (!value) error = "Password is required";
        else {
          const strengthError = validateStrongPassword(value);
          if (strengthError) error = strengthError;
        }
        break;
      case "mobileNumber":
      case "whatsappNumber":
        const phoneRegex = /^[0-9]{10}$/;
        if (!value) error = "Number is required";
        else if (!phoneRegex.test(value)) error = "Enter a valid 10-digit number";
        break;
      case "panNumber":
        const panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/;
        if (!value) error = "PAN is required";
        else if (!panRegex.test(value.toUpperCase())) error = "Enter a valid PAN (e.g. ABCDE1234F)";
        break;
      case "aadharNumber":
        const aadharRegex = /^\d{12}$/;
        if (!value) error = "Aadhar is required";
        else if (!aadharRegex.test(value.replace(/\s/g, ''))) error = "Enter a valid 12-digit Aadhar";
        break;
      case "ifscCode":
        const ifscRegex = /^[A-Z]{4}0[A-Z0-9]{6}$/;
        if (!value) error = "IFSC is required";
        else if (!ifscRegex.test(value.toUpperCase())) error = "Enter a valid IFSC code";
        break;
      case "bankAccountNumber":
        const accRegex = /^\d{9,18}$/;
        if (!value) error = "Account Number is required";
        else if (!accRegex.test(value)) error = "Enter a valid bank account number";
        break;
      case "bankName":
      case "fullName":
        if (!value.trim()) error = "This field is required";
        break;
      default:
        break;
    }
    return error;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    let formattedValue = value;
    
    if (name === "panNumber" || name === "ifscCode") {
      formattedValue = value.toUpperCase();
    }
    
    // Allow numbers only for specific fields
    if (
      name === "mobileNumber" ||
      name === "whatsappNumber" ||
      name === "aadharNumber" ||
      name === "bankAccountNumber"
    ) {
      formattedValue = value.replace(/\D/g, "");
    }
    
    setFormData({ ...formData, [name]: formattedValue });
    
    const error = validateField(name, formattedValue);
    setErrors(prev => ({ ...prev, [name]: error }));
  };

  const handleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    const error = validateField(name, value);
    setErrors(prev => ({ ...prev, [name]: error }));
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setImageToCrop(URL.createObjectURL(file));
      setIsCropModalOpen(true);
      e.target.value = "";
    }
  };

  const onCropComplete = (croppedArea: any, croppedAreaPixels: any) => {
    setCroppedAreaPixels(croppedAreaPixels);
  };

  const handleCropConfirm = async () => {
    if (imageToCrop && croppedAreaPixels) {
      try {
        const croppedFile = await getCroppedImg(imageToCrop, croppedAreaPixels, 0);
        if (croppedFile) {
          setProfileImage(croppedFile);
          setImagePreview(URL.createObjectURL(croppedFile));
        }
      } catch (e) {
        console.error(e);
      }
    }
    setIsCropModalOpen(false);
  };

  const handleRemoveImage = () => {
    setProfileImage(null);
    setImagePreview(null);
    setImageToCrop(null);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const newErrors: Record<string, string> = {};
    Object.keys(formData).forEach((key) => {
      const error = validateField(key, formData[key as keyof typeof formData]);
      if (error) newErrors[key] = error;
    });

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      toast.error("Please fix the validation errors in the form.");
      return;
    }

    setLoading(true);

    try {
      const authUid = await createAuthUser(formData.email, formData.password);

      const newAgentRef = doc(collection(db, "agents"), authUid);
      let photoURL = "";

      if (profileImage) {
        const storageRef = ref(storage, `agents/${newAgentRef.id}/profile.jpg`);
        await uploadBytes(storageRef, profileImage);
        photoURL = await getDownloadURL(storageRef);
      }

      const { password, ...agentDataToSave } = formData;

      await setDoc(newAgentRef, {
        ...agentDataToSave,
        id: newAgentRef.id,
        photoURL,
        status: "ACTIVE",
        role: "AGENT",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });

      toast.success("Agent registered successfully! Please inform the agent to verify their email before logging in.", { duration: 6000 });
      router.push("/agents");
    } catch (error: any) {
      console.error(error);
      toast.error(error.message || "Failed to add agent.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6 pb-12">
      <PageHeader
        title="Add New Agent"
        breadcrumbs={[
          { label: "Dashboard", href: "/dashboard" },
          { label: "Agents", href: "/agents" },
          { label: "Add Agent" }
        ]}
      />

      <form onSubmit={handleSubmit} className="space-y-8">

        {/* Basic Info */}
        <div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
          <h2 className="text-lg font-bold text-slate-900 mb-6 flex items-center gap-2">
            <User className="h-5 w-5 text-blue-600" />
            Basic Information
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="md:col-span-2 mb-4">
              <label className="block text-sm font-semibold text-slate-700 mb-2">Profile Picture (Optional)</label>
              <div className="flex items-center gap-4">
                <div className="h-20 w-20 rounded-full border-2 border-dashed border-slate-300 flex items-center justify-center bg-slate-50 overflow-hidden">
                  {imagePreview ? (
                    <img src={imagePreview} alt="Preview" className="h-full w-full object-cover" />
                  ) : (
                    <User className="h-8 w-8 text-slate-400" />
                  )}
                </div>
                <div className="flex flex-col">
                  <div className="flex items-center space-x-4">
                    <input type="file" accept="image/*" onChange={handleImageChange} className="block w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" />
                    {imagePreview && (
                      <button type="button" onClick={handleRemoveImage} className="px-3 py-1 text-sm text-red-600 bg-red-50 hover:bg-red-100 rounded-full font-medium transition-colors">
                        Remove
                      </button>
                    )}
                  </div>
                  <p className="mt-1 text-xs text-slate-500">JPG, PNG or GIF (Max 5MB)</p>
                </div>
              </div>
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Full Name *</label>
              <input type="text" name="fullName" required value={formData.fullName} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.fullName ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all`} />
              {errors.fullName && <p className="text-red-500 text-xs mt-1">{errors.fullName}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Firm Name (Optional)</label>
              <input type="text" name="firmName" value={formData.firmName} onChange={handleChange} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Email Address *</label>
              <input type="email" name="email" required value={formData.email} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.email ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all`} />
              {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Initial Password *</label>
              <div className="relative">
                <input type={showPassword ? "text" : "password"} name="password" required value={formData.password} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.password ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all pr-12`} />
                <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 transition-colors">
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
              {errors.password && <p className="text-red-500 text-xs mt-1">{errors.password}</p>}
              {!errors.password && (
                <div className="mt-2 bg-blue-50/50 p-3 rounded-lg border border-blue-100">
                  <p className="text-xs text-blue-800 font-medium mb-1">Password Requirements:</p>
                  <ul className="text-xs text-blue-600/80 list-disc list-inside space-y-0.5">
                    <li>At least 8 characters</li>
                    <li>1 uppercase & 1 lowercase letter</li>
                    <li>1 number & 1 special character</li>
                  </ul>
                </div>
              )}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Mobile Number *</label>
              <input type="tel" name="mobileNumber" required value={formData.mobileNumber} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.mobileNumber ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all`} />
              {errors.mobileNumber && <p className="text-red-500 text-xs mt-1">{errors.mobileNumber}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">WhatsApp Number *</label>
              <input type="tel" name="whatsappNumber" required value={formData.whatsappNumber} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.whatsappNumber ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all`} />
              {errors.whatsappNumber && <p className="text-red-500 text-xs mt-1">{errors.whatsappNumber}</p>}
            </div>
          </div>
        </div>

        {/* KYC Info */}
        <div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
          <h2 className="text-lg font-bold text-slate-900 mb-6 flex items-center gap-2">
            <FileText className="h-5 w-5 text-blue-600" />
            KYC Documents
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">PAN Card Number *</label>
              <input type="text" name="panNumber" required value={formData.panNumber} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.panNumber ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all uppercase`} placeholder="ABCDE1234F" />
              {errors.panNumber && <p className="text-red-500 text-xs mt-1">{errors.panNumber}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Aadhar Number *</label>
              <input type="text" name="aadharNumber" required value={formData.aadharNumber} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.aadharNumber ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all`} placeholder="1234 5678 9012" />
              {errors.aadharNumber && <p className="text-red-500 text-xs mt-1">{errors.aadharNumber}</p>}
            </div>
          </div>
        </div>

        {/* Bank Details */}
        <div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
          <h2 className="text-lg font-bold text-slate-900 mb-6 flex items-center gap-2">
            <Building className="h-5 w-5 text-blue-600" />
            Bank Details (For Commission Payouts)
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Bank Name *</label>
              <input type="text" name="bankName" required value={formData.bankName} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.bankName ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all`} />
              {errors.bankName && <p className="text-red-500 text-xs mt-1">{errors.bankName}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">Account Number *</label>
              <input type="text" name="bankAccountNumber" required value={formData.bankAccountNumber} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.bankAccountNumber ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all`} />
              {errors.bankAccountNumber && <p className="text-red-500 text-xs mt-1">{errors.bankAccountNumber}</p>}
            </div>
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">IFSC Code *</label>
              <input type="text" name="ifscCode" required value={formData.ifscCode} onChange={handleChange} onBlur={handleBlur} className={`w-full px-4 py-2.5 bg-slate-50 border ${errors.ifscCode ? 'border-red-500' : 'border-slate-200'} rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white transition-all uppercase`} />
              {errors.ifscCode && <p className="text-red-500 text-xs mt-1">{errors.ifscCode}</p>}
            </div>
          </div>
        </div>

        <div className="flex items-center justify-end gap-4 pt-4">
          <button type="button" onClick={() => router.back()} className="px-6 py-3 text-slate-600 font-semibold hover:bg-slate-100 rounded-xl transition-colors">
            Cancel
          </button>
          <button type="submit" disabled={loading} className="inline-flex items-center px-8 py-3 bg-blue-600 text-white font-semibold rounded-xl hover:bg-blue-700 transition-colors shadow-sm shadow-blue-200 disabled:opacity-70 disabled:cursor-not-allowed">
            {loading ? (
              <>
                <div className="h-5 w-5 mr-2 animate-spin rounded-full border-b-2 border-white"></div>
                Saving...
              </>
            ) : (
              <>
                <CheckCircle className="h-5 w-5 mr-2" />
                Add Agent
              </>
            )}
          </button>
        </div>
      </form>

      <Modal
        isOpen={isCropModalOpen}
        onClose={() => setIsCropModalOpen(false)}
        title="Crop Profile Image"
        maxWidth="lg"
        footer={
          <>
            <button
              onClick={() => setIsCropModalOpen(false)}
              className="px-4 py-2 text-slate-600 hover:bg-slate-200 rounded-lg transition-colors font-medium"
            >
              Cancel
            </button>
            <button
              onClick={handleCropConfirm}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
            >
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
