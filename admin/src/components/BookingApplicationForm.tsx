import React, { useState } from "react";
import Cropper from "react-easy-crop";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { storage } from "@/lib/firebase";
import { Modal } from "@/components/ui/Modal";
import { numberToWords } from "@/lib/formatters";

interface CropArea {
    width: number;
    height: number;
    x: number;
    y: number;
}

export interface BookingApplicationFormData {
    firstApplicantName: string;
    secondApplicantName: string;
    firstApplicantFatherName: string;
    secondApplicantFatherName: string;
    firstApplicantDateOfBirth: string;
    secondApplicantDateOfBirth: string;
    firstApplicantMarriageDate: string;
    secondApplicantMarriageDate: string;
    firstApplicantOccupation: string;
    secondApplicantOccupation: string;
    firstApplicantNationality: string;
    secondApplicantNationality: string;
    firstApplicantAddress: string;
    secondApplicantAddress: string;
    firstApplicantPermanentAddress: string;
    secondApplicantPermanentAddress: string;
    permanentAddress: string;
    firstApplicantOfficeAddress: string;
    secondApplicantOfficeAddress: string;
    firstApplicantTelephoneOffice: string;
    secondApplicantTelephoneOffice: string;
    firstApplicantTelephoneResidence: string;
    secondApplicantTelephoneResidence: string;
    firstApplicantMobile: string;
    secondApplicantMobile: string;
    firstApplicantEmail: string;
    secondApplicantEmail: string;
    firstApplicantPan: string;
    secondApplicantPan: string;
    firstApplicantAadhaar: string;
    secondApplicantAadhaar: string;
    firstApplicantPassportOrId: string;
    secondApplicantPassportOrId: string;
    firstNomineeName: string;
    firstNomineeRelationship: string;
    secondNomineeName: string;
    secondNomineeRelationship: string;
    paymentPlan: string;
    paymentMode: string;
    initialPayment: string;
    initialPaymentInWords: string;
    paymentReference: string;
    paymentDate: string;
    bankName: string;
    plotArea1: string;
    plotArea2: string;
    plotArea3: string;
    plotArea4: string;
    salePricePerSqFt: string;
    developmentChargePerSqFt: string;
    totalAmount: string;
    applicationDate: string;
    applicationPlace: string;
    remarks: string;
    notes: string;
    firstApplicantPhoto: string;
    secondApplicantPhoto: string;
}

export const emptyBookingApplicationForm: BookingApplicationFormData = {
    firstApplicantName: "", secondApplicantName: "", firstApplicantFatherName: "", secondApplicantFatherName: "",
    firstApplicantDateOfBirth: "", secondApplicantDateOfBirth: "", firstApplicantMarriageDate: "", secondApplicantMarriageDate: "",
    firstApplicantOccupation: "", secondApplicantOccupation: "", firstApplicantNationality: "", secondApplicantNationality: "",
    firstApplicantAddress: "", secondApplicantAddress: "", firstApplicantPermanentAddress: "", secondApplicantPermanentAddress: "", permanentAddress: "", firstApplicantOfficeAddress: "", secondApplicantOfficeAddress: "",
    firstApplicantTelephoneOffice: "", secondApplicantTelephoneOffice: "", firstApplicantTelephoneResidence: "", secondApplicantTelephoneResidence: "",
    firstApplicantMobile: "", secondApplicantMobile: "", firstApplicantEmail: "", secondApplicantEmail: "", firstApplicantPan: "", secondApplicantPan: "", firstApplicantAadhaar: "", secondApplicantAadhaar: "", firstApplicantPassportOrId: "", secondApplicantPassportOrId: "",
    firstNomineeName: "", firstNomineeRelationship: "", secondNomineeName: "", secondNomineeRelationship: "", paymentPlan: "", paymentMode: "CASH", initialPayment: "", initialPaymentInWords: "", paymentReference: "", paymentDate: "", bankName: "",
    plotArea1: "", plotArea2: "", plotArea3: "", plotArea4: "", salePricePerSqFt: "", developmentChargePerSqFt: "", totalAmount: "", applicationDate: "", applicationPlace: "", remarks: "", notes: "", firstApplicantPhoto: "", secondApplicantPhoto: "",
};

export type BookingApplicationFormErrors = Partial<Record<keyof BookingApplicationFormData, string>>;

export function validateBookingApplicationForm(value: BookingApplicationFormData): BookingApplicationFormErrors {
    const errors: BookingApplicationFormErrors = {};
    const requiredFields: Array<[keyof BookingApplicationFormData, string]> = [
        ["firstApplicantName", "First applicant name is required."],
        ["firstApplicantDateOfBirth", "Date of birth is required."],
        ["firstApplicantOccupation", "Occupation is required."],
        ["firstApplicantNationality", "Nationality is required."],
        ["firstApplicantAddress", "Present address is required."],
        ["firstApplicantMobile", "First applicant mobile number is required."],
        ["firstApplicantEmail", "First applicant email is required."],
        ["paymentPlan", "Payment plan is required."],
        ["initialPayment", "Initial payment is required."],
        ["paymentDate", "Payment date is required."],
        ["plotArea1", "Plot area is required."],
        ["salePricePerSqFt", "Plot sale price is required."],
        ["totalAmount", "Total amount is required."],
        ["applicationDate", "Application date is required."],
        ["applicationPlace", "Application place is required."],
    ];

    requiredFields.forEach(([field, message]) => {
        if (!value[field].trim()) errors[field] = message;
    });

    const mobileFields: Array<keyof BookingApplicationFormData> = ["firstApplicantMobile", "secondApplicantMobile"];
    mobileFields.forEach((field) => {
        const mobile = value[field].trim();
        if (mobile && !/^\+?[0-9\s()-]{10,15}$/.test(mobile)) {
            errors[field] = "Enter a valid mobile number.";
        }
    });

    const emailFields: Array<keyof BookingApplicationFormData> = ["firstApplicantEmail", "secondApplicantEmail"];
    emailFields.forEach((field) => {
        const email = value[field].trim();
        if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            errors[field] = "Enter a valid email address.";
        }
    });

    const panFields: Array<keyof BookingApplicationFormData> = ["firstApplicantPan", "secondApplicantPan"];
    panFields.forEach((field) => {
        const pan = value[field].trim();
        if (pan && !/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(pan.toUpperCase())) {
            errors[field] = "Enter a valid PAN number.";
        }
    });

    const aadhaarFields: Array<keyof BookingApplicationFormData> = ["firstApplicantAadhaar", "secondApplicantAadhaar"];
    aadhaarFields.forEach((field) => {
        const aadhaar = value[field].replace(/\s/g, "");
        if (aadhaar && !/^\d{12}$/.test(aadhaar)) errors[field] = "Enter a valid 12-digit Aadhaar number.";
    });

    const numericFields: Array<keyof BookingApplicationFormData> = [
        "initialPayment", "plotArea1", "plotArea2", "plotArea3", "plotArea4", "salePricePerSqFt", "developmentChargePerSqFt", "totalAmount",
    ];
    numericFields.forEach((field) => {
        const numericValue = value[field].trim();
        if (numericValue && (!Number.isFinite(Number(numericValue)) || Number(numericValue) < 0)) {
            errors[field] = "Enter a valid non-negative amount.";
        }
    });

    const dateFields: Array<keyof BookingApplicationFormData> = [
        "firstApplicantDateOfBirth", "secondApplicantDateOfBirth", "firstApplicantMarriageDate", "secondApplicantMarriageDate", "paymentDate", "applicationDate",
    ];
    dateFields.forEach((field) => {
        const date = value[field].trim();
        if (date && !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
            errors[field] = "Enter a valid date.";
        }
    });

    if (value.paymentMode !== "CASH" && !value.paymentReference.trim()) {
        errors.paymentReference = "Payment reference is required for this payment mode.";
    }

    return errors;
}

interface BookingApplicationFormProps {
    value: BookingApplicationFormData;
    onChange: (value: BookingApplicationFormData) => void;
    disabled?: boolean;
    errors?: BookingApplicationFormErrors;
    bookingId?: string;
    onPhotoUploadStateChange?: (uploading: boolean) => void;
    initialPaymentLocked?: boolean;
}

export function BookingApplicationForm({ value, onChange, disabled = false, errors = {}, bookingId, onPhotoUploadStateChange, initialPaymentLocked = false }: BookingApplicationFormProps) {
    const [cropImage, setCropImage] = useState("");
    const [cropField, setCropField] = useState<"firstApplicantPhoto" | "secondApplicantPhoto" | null>(null);
    const [crop, setCrop] = useState({ x: 0, y: 0 });
    const [zoom, setZoom] = useState(1);
    const [cropAreaPixels, setCropAreaPixels] = useState<CropArea | null>(null);
    const [isCropperOpen, setIsCropperOpen] = useState(false);
    const updateField = (field: keyof BookingApplicationFormData, fieldValue: string) => {
        const newData = { ...value, [field]: fieldValue };
        if (field === "initialPayment") {
            const num = Number(fieldValue);
            if (!isNaN(num) && num > 0) {
                newData.initialPaymentInWords = numberToWords(num) + " Rupees Only";
            } else {
                newData.initialPaymentInWords = "";
            }
        }
        onChange(newData);
    };
    const uploadApplicantPhoto = async (field: "firstApplicantPhoto" | "secondApplicantPhoto", file: File) => {
        if (!bookingId) return;
        onPhotoUploadStateChange?.(true);
        try {
            const photoRef = ref(storage, `bookings/${bookingId}/applicant-photos/${field}.jpg`);
            await uploadBytes(photoRef, file);
            updateField(field, await getDownloadURL(photoRef));
        } catch (error) {
            console.error("Unable to upload applicant photo", error);
        } finally {
            onPhotoUploadStateChange?.(false);
        }
    };
    const handlePhotoSelected = (field: "firstApplicantPhoto" | "secondApplicantPhoto", file: File) => {
        setCropField(field);
        setCropImage(URL.createObjectURL(file));
        setCrop({ x: 0, y: 0 });
        setZoom(1);
        setIsCropperOpen(true);
    };
    const closeCropper = () => {
        if (cropImage) URL.revokeObjectURL(cropImage);
        setCropImage("");
        setCropField(null);
        setCropAreaPixels(null);
        setIsCropperOpen(false);
    };
    const confirmCrop = async () => {
        if (!cropImage || !cropField || !cropAreaPixels) return;
        const image = new Image();
        image.src = cropImage;
        await new Promise<void>((resolve, reject) => {
            image.onload = () => resolve();
            image.onerror = () => reject(new Error("Unable to read selected photo"));
        });
        const canvas = document.createElement("canvas");
        canvas.width = cropAreaPixels.width;
        canvas.height = cropAreaPixels.height;
        const context = canvas.getContext("2d");
        if (!context) return;
        context.drawImage(
            image,
            cropAreaPixels.x,
            cropAreaPixels.y,
            cropAreaPixels.width,
            cropAreaPixels.height,
            0,
            0,
            canvas.width,
            canvas.height,
        );
        const croppedFile = await new Promise<File>((resolve, reject) => {
            canvas.toBlob((blob) => {
                if (blob) resolve(new File([blob], `${cropField}.jpg`, { type: "image/jpeg" }));
                else reject(new Error("Unable to crop selected photo"));
            }, "image/jpeg", 0.9);
        });
        const selectedField = cropField;
        closeCropper();
        await uploadApplicantPhoto(selectedField, croppedFile);
    };
    const inputClassName = "w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-100";
    const localDate = new Date();
    const todayStr = `${localDate.getFullYear()}-${String(localDate.getMonth() + 1).padStart(2, '0')}-${String(localDate.getDate()).padStart(2, '0')}`;
    const extractBadge = (label: string) => {
        const match = label.match(/^\[(.*?)\]\s*(.*)$/);
        return match ? { badge: match[1], cleanLabel: match[2] } : { badge: null, cleanLabel: label };
    };
    const field = (label: string, name: keyof BookingApplicationFormData, type = "text", required = false, fieldDisabled = disabled) => {
        const { badge, cleanLabel } = extractBadge(label);
        return (
            <label className="text-sm font-medium text-slate-700">
                <div className="mb-1 flex items-center gap-2">
                    {badge && <span className="inline-flex items-center justify-center rounded-md bg-blue-50 px-1.5 py-0.5 text-xs font-bold text-blue-700 border border-blue-200">{badge}</span>}
                    <span>{cleanLabel}{required && <span className="text-red-500"> *</span>}</span>
                </div>
                <input required={required} disabled={fieldDisabled} type={type} value={value[name]} onChange={(e) => updateField(name, e.target.value)} className={`${inputClassName} ${errors[name] ? "border-red-500 focus:ring-red-500" : ""}`} aria-invalid={Boolean(errors[name])} aria-describedby={errors[name] ? `${String(name)}-error` : undefined} />
                {errors[name] && <span id={`${String(name)}-error`} className="mt-1 block text-xs font-normal text-red-600">{errors[name]}</span>}
            </label>
        );
    };
    const textarea = (label: string, name: keyof BookingApplicationFormData, wide = false, required = false) => {
        const { badge, cleanLabel } = extractBadge(label);
        return (
            <label className={`text-sm font-medium text-slate-700 ${wide ? "sm:col-span-2" : ""}`}>
                <div className="mb-1 flex items-center gap-2">
                    {badge && <span className="inline-flex items-center justify-center rounded-md bg-blue-50 px-1.5 py-0.5 text-xs font-bold text-blue-700 border border-blue-200">{badge}</span>}
                    <span>{cleanLabel}{required && <span className="text-red-500"> *</span>}</span>
                </div>
                <textarea required={required} disabled={disabled} value={value[name]} onChange={(e) => updateField(name, e.target.value)} className={`${inputClassName} ${errors[name] ? "border-red-500 focus:ring-red-500" : ""}`} aria-invalid={Boolean(errors[name])} aria-describedby={errors[name] ? `${String(name)}-error` : undefined} rows={2} />
                {errors[name] && <span id={`${String(name)}-error`} className="mt-1 block text-xs font-normal text-red-600">{errors[name]}</span>}
            </label>
        );
    };
    const applicantPhoto = (label: string, fieldName: "firstApplicantPhoto" | "secondApplicantPhoto") => {
        const { badge, cleanLabel } = extractBadge(label);
        return (
            <label className="text-sm font-medium text-slate-700">
                <div className="mb-1 flex items-center gap-2">
                    {badge && <span className="inline-flex items-center justify-center rounded-md bg-blue-50 px-1.5 py-0.5 text-xs font-bold text-blue-700 border border-blue-200">{badge}</span>}
                    <span>{cleanLabel}</span>
                </div>
                <input
                    type="file"
                    accept="image/*"
                    disabled={disabled}
                    onChange={(event) => {
                        const file = event.target.files?.[0];
                        if (file) handlePhotoSelected(fieldName, file);
                    }}
                    className="mt-1 block w-full text-sm text-slate-600 file:mr-3 file:rounded-md file:border-0 file:bg-blue-50 file:px-3 file:py-2 file:font-semibold file:text-blue-700"
                />
                {value[fieldName] && <img src={value[fieldName]} alt={label} className="mt-2 h-24 w-20 rounded border border-slate-200 object-cover" />}
            </label>
        );
    };

    return (
        <>
            <div className="space-y-6">
                <p className="text-right text-xs font-medium text-slate-500">
                    <span className="text-base font-bold text-red-500">*</span> Required fields
                </p>
                <section className="border-b border-slate-200 pb-6">
                    <h3 className="text-base font-bold text-slate-900">A. First Applicant</h3>

                    <h4 className="mt-4 border-b pb-1 text-sm font-bold text-slate-800">Personal Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {applicantPhoto("First Applicant Photo", "firstApplicantPhoto")}
                        {field("First Applicant (Mr./Mrs./Ms.)", "firstApplicantName", "text", true)}
                        {field("Son / Wife / Daughter of", "firstApplicantFatherName", "text", false)}
                        {field("Date of Birth / Incorporation", "firstApplicantDateOfBirth", "date", true)}
                        {field("Marriage Anniversary", "firstApplicantMarriageDate", "date")}
                        {field("Occupation", "firstApplicantOccupation", "text", true)}
                        {field("Nationality", "firstApplicantNationality", "text", true)}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Identity Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {field("PAN Number", "firstApplicantPan")}
                        {field("Aadhaar Number", "firstApplicantAadhaar")}
                        {field("Passport / Voter ID / Licence / Aadhaar", "firstApplicantPassportOrId")}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Contact Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {field("Mobile", "firstApplicantMobile", "tel", true)}
                        {field("E-mail", "firstApplicantEmail", "email", true)}
                        {field("Office Telephone", "firstApplicantTelephoneOffice", "tel")}
                        {field("Residence Telephone", "firstApplicantTelephoneResidence", "tel")}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Addresses</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {textarea("Present Address", "firstApplicantAddress", false, true)}
                        {textarea("Permanent Address", "firstApplicantPermanentAddress")}
                        {textarea("Office Address", "firstApplicantOfficeAddress")}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Nominee Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {field("Nominee Name", "firstNomineeName")}
                        {field("Nominee Relationship", "firstNomineeRelationship")}
                    </div>
                </section>

                <section className="border-b border-slate-200 pb-6">
                    <h3 className="text-base font-bold text-slate-900">B. Second Applicant</h3>

                    <h4 className="mt-4 border-b pb-1 text-sm font-bold text-slate-800">Personal Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {applicantPhoto("Second Applicant Photo", "secondApplicantPhoto")}
                        {field("Second Applicant (Mr./Mrs./Ms.)", "secondApplicantName")}
                        {field("Son / Wife / Daughter of", "secondApplicantFatherName")}
                        {field("Date of Birth / Incorporation", "secondApplicantDateOfBirth", "date")}
                        {field("Marriage Anniversary", "secondApplicantMarriageDate", "date")}
                        {field("Occupation", "secondApplicantOccupation")}
                        {field("Nationality", "secondApplicantNationality")}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Identity Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {field("PAN Number", "secondApplicantPan")}
                        {field("Aadhaar Number", "secondApplicantAadhaar")}
                        {field("Passport / Voter ID / Licence / Aadhaar", "secondApplicantPassportOrId")}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Contact Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {field("Mobile", "secondApplicantMobile", "tel")}
                        {field("E-mail", "secondApplicantEmail", "email")}
                        {field("Office Telephone", "secondApplicantTelephoneOffice", "tel")}
                        {field("Residence Telephone", "secondApplicantTelephoneResidence", "tel")}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Addresses</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {textarea("Present Address", "secondApplicantAddress")}
                        {textarea("Permanent Address", "secondApplicantPermanentAddress")}
                        {textarea("Office Address", "secondApplicantOfficeAddress")}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Nominee Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {field("Nominee Name", "secondNomineeName")}
                        {field("Nominee Relationship", "secondNomineeRelationship")}
                    </div>
                </section>

                <section>
                    <h3 className="text-base font-bold text-slate-900">C. Payment Plan, Plot Details & Remarks</h3>

                    <h4 className="mt-4 border-b pb-1 text-sm font-bold text-slate-800">Payment Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        <fieldset className="sm:col-span-2">
                            <legend className="text-sm font-medium text-slate-700">
                                <div className="mb-1 flex items-center gap-2">
                                    <span>Payment Plan Option (please tick) <span className="text-base font-bold text-red-500">*</span></span>
                                </div>
                            </legend>
                            <div className="mt-2 flex flex-wrap gap-4 rounded-lg border border-slate-300 bg-white px-3 py-3">
                                {[['OWN_PAYMENT_PLAN', 'Own Payment Plan'], ['MANUAL_PLAN', 'Manual Plan'], ['FLEXI_PAYMENT_PLAN', 'Flexi Payment Plan']].map(([plan, label], index) => (
                                    <label key={plan} className="flex items-center gap-2 text-sm text-slate-700">
                                        <input type="radio" required={index === 0} disabled={disabled} name="paymentPlan" value={plan} checked={value.paymentPlan === plan || (plan === 'OWN_PAYMENT_PLAN' && value.paymentPlan === 'DOWN_PAYMENT')} onChange={(e) => updateField("paymentPlan", e.target.value)} />
                                        {label}
                                    </label>
                                ))}
                            </div>
                        </fieldset>
                        <label className="text-sm font-medium text-slate-700">
                            <div className="mb-1 flex items-center gap-2">
                                <span>Payment Mode</span>
                            </div>
                            <select disabled={disabled || initialPaymentLocked} value={value.paymentMode} onChange={(e) => updateField("paymentMode", e.target.value)} className={inputClassName}>
                                <option value="CASH">Cash</option><option value="UPI">UPI</option><option value="BANK_TRANSFER">NEFT / RTGS / Bank Transfer</option><option value="CHEQUE">Cheque</option><option value="LOAN">Bank Loan</option>
                            </select>
                        </label>
                        {field("Booking Money / Initial Payment", "initialPayment", "number", true, disabled || initialPaymentLocked)}
                        {field("Cheque / NEFT / RTGS Reference", "paymentReference", "text", false, disabled || initialPaymentLocked)}
                        {field("Payment Date", "paymentDate", "date", true, disabled || initialPaymentLocked)}
                        {field("Bank / Finance Company", "bankName")}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Plot Details</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {field("Plot Area 1 (sq. ft.)", "plotArea1", "number", true)}
                        {field("Plot Area 2 (sq. ft.)", "plotArea2", "number")}
                        {field("Plot Area 3 (sq. ft.)", "plotArea3", "number")}
                        {field("Plot Area 4 (sq. ft.)", "plotArea4", "number")}
                        {field("Plot Sale Price (Rs. per sq. ft.)", "salePricePerSqFt", "number", true)}
                        {field("Additional / Development Charge (Rs. per sq. ft.)", "developmentChargePerSqFt", "number")}
                        {field("Total Amount (Rs.)", "totalAmount", "number", true)}
                    </div>

                    <h4 className="mt-6 border-b pb-1 text-sm font-bold text-slate-800">Application Info & Remarks</h4>
                    <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                        {field("Application Date", "applicationDate", "date", true)}
                        {field("Application Place", "applicationPlace", "text", true)}
                        {textarea("Any Other Remarks", "remarks", true)}
                        {textarea("Additional Notes", "notes", true)}
                    </div>
                </section>
            </div>
            <Modal
                isOpen={isCropperOpen}
                onClose={closeCropper}
                title="Crop Passport Photo"
                maxWidth="md"
                footer={
                    <div className="flex w-full justify-end gap-3">
                        <button type="button" onClick={closeCropper} className="rounded-lg border border-slate-300 px-4 py-2 text-sm font-semibold text-slate-700">Cancel</button>
                        <button type="button" onClick={() => void confirmCrop()} className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-700">Crop & Upload</button>
                    </div>
                }
            >
                <div className="relative h-72 w-full overflow-hidden rounded-lg bg-slate-900">
                    {cropImage && <Cropper image={cropImage} crop={crop} zoom={zoom} aspect={3 / 4} onCropChange={setCrop} onZoomChange={setZoom} onCropComplete={(_, pixels) => setCropAreaPixels(pixels)} />}
                </div>
                <label className="mt-4 block text-sm font-medium text-slate-700">
                    Zoom
                    <input type="range" min={1} max={3} step={0.1} value={zoom} onChange={(event) => setZoom(Number(event.target.value))} className="mt-2 w-full" />
                </label>
            </Modal>
        </>
    );
}
