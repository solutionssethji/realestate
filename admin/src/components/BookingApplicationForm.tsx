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
    applicationDate: string;
    applicationPlace: string;
    remarks: string;
    notes: string;
}

export const emptyBookingApplicationForm: BookingApplicationFormData = {
    firstApplicantName: "", secondApplicantName: "", firstApplicantFatherName: "", secondApplicantFatherName: "",
    firstApplicantDateOfBirth: "", secondApplicantDateOfBirth: "", firstApplicantMarriageDate: "", secondApplicantMarriageDate: "",
    firstApplicantOccupation: "", secondApplicantOccupation: "", firstApplicantNationality: "", secondApplicantNationality: "",
    firstApplicantAddress: "", secondApplicantAddress: "", firstApplicantPermanentAddress: "", secondApplicantPermanentAddress: "", permanentAddress: "", firstApplicantOfficeAddress: "", secondApplicantOfficeAddress: "",
    firstApplicantTelephoneOffice: "", secondApplicantTelephoneOffice: "", firstApplicantTelephoneResidence: "", secondApplicantTelephoneResidence: "",
    firstApplicantMobile: "", secondApplicantMobile: "", firstApplicantEmail: "", secondApplicantEmail: "", firstApplicantPan: "", secondApplicantPan: "", firstApplicantAadhaar: "", secondApplicantAadhaar: "", firstApplicantPassportOrId: "", secondApplicantPassportOrId: "",
    firstNomineeName: "", firstNomineeRelationship: "", secondNomineeName: "", secondNomineeRelationship: "", paymentPlan: "", paymentMode: "CASH", initialPayment: "", initialPaymentInWords: "", paymentReference: "", paymentDate: "", bankName: "",
    plotArea1: "", plotArea2: "", plotArea3: "", plotArea4: "", salePricePerSqFt: "", developmentChargePerSqFt: "", applicationDate: "", applicationPlace: "", remarks: "", notes: "",
};

export type BookingApplicationFormErrors = Partial<Record<keyof BookingApplicationFormData, string>>;

export function validateBookingApplicationForm(value: BookingApplicationFormData): BookingApplicationFormErrors {
    const errors: BookingApplicationFormErrors = {};
    const requiredFields: Array<[keyof BookingApplicationFormData, string]> = [
        ["firstApplicantName", "First applicant name is required."],
        ["firstApplicantFatherName", "Father / spouse name is required."],
        ["firstApplicantDateOfBirth", "Date of birth is required."],
        ["firstApplicantOccupation", "Occupation is required."],
        ["firstApplicantNationality", "Nationality is required."],
        ["firstApplicantAddress", "Present address is required."],
        ["firstApplicantMobile", "First applicant mobile number is required."],
        ["firstApplicantEmail", "First applicant email is required."],
        ["paymentPlan", "Payment plan is required."],
        ["initialPayment", "Initial payment is required."],
        ["initialPaymentInWords", "Initial payment in words is required."],
        ["paymentDate", "Payment date is required."],
        ["plotArea1", "Plot area is required."],
        ["salePricePerSqFt", "Plot sale price is required."],
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
        "initialPayment", "plotArea1", "plotArea2", "plotArea3", "plotArea4", "salePricePerSqFt", "developmentChargePerSqFt",
    ];
    numericFields.forEach((field) => {
        const numericValue = value[field].trim();
        if (numericValue && (!Number.isFinite(Number(numericValue)) || Number(numericValue) < 0)) {
            errors[field] = "Enter a valid non-negative amount.";
        }
    });

    const today = new Date().toISOString().slice(0, 10);
    const dateFields: Array<keyof BookingApplicationFormData> = [
        "firstApplicantDateOfBirth", "secondApplicantDateOfBirth", "firstApplicantMarriageDate", "secondApplicantMarriageDate", "paymentDate", "applicationDate",
    ];
    dateFields.forEach((field) => {
        const date = value[field].trim();
        if (date && (!/^\d{4}-\d{2}-\d{2}$/.test(date) || date > today)) {
            errors[field] = "Enter a valid date that is not in the future.";
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
}

export function BookingApplicationForm({ value, onChange, disabled = false, errors = {} }: BookingApplicationFormProps) {
    const updateField = (field: keyof BookingApplicationFormData, fieldValue: string) => onChange({ ...value, [field]: fieldValue });
    const inputClassName = "w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-100";
    const field = (label: string, name: keyof BookingApplicationFormData, type = "text", required = false) => (
        <label className="text-sm font-medium text-slate-700">{label}{required && <span className="text-red-500"> *</span>}
            <input required={required} disabled={disabled} type={type} value={value[name]} onChange={(e) => updateField(name, e.target.value)} className={`${inputClassName} ${errors[name] ? "border-red-500 focus:ring-red-500" : ""}`} aria-invalid={Boolean(errors[name])} aria-describedby={errors[name] ? `${String(name)}-error` : undefined} />
            {errors[name] && <span id={`${String(name)}-error`} className="mt-1 block text-xs font-normal text-red-600">{errors[name]}</span>}
        </label>
    );
    const textarea = (label: string, name: keyof BookingApplicationFormData, wide = false, required = false) => (
        <label className={`text-sm font-medium text-slate-700 ${wide ? "sm:col-span-2" : ""}`}>{label}{required && <span className="text-red-500"> *</span>}
            <textarea required={required} disabled={disabled} value={value[name]} onChange={(e) => updateField(name, e.target.value)} className={`${inputClassName} ${errors[name] ? "border-red-500 focus:ring-red-500" : ""}`} aria-invalid={Boolean(errors[name])} aria-describedby={errors[name] ? `${String(name)}-error` : undefined} rows={2} />
            {errors[name] && <span id={`${String(name)}-error`} className="mt-1 block text-xs font-normal text-red-600">{errors[name]}</span>}
        </label>
    );

    return (
        <div className="space-y-6">
            <section className="border-b border-slate-200 pb-6">
                <h3 className="text-base font-bold text-slate-900">A. First Applicant</h3>
                <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                    {field("1. First Applicant Mr./Mrs./Ms. (in capital letters)", "firstApplicantName", "text", true)}
                    {field("Son / Wife / Daughter of", "firstApplicantFatherName", "text", true)}
                    {field("Date of Birth / Incorporation", "firstApplicantDateOfBirth", "date", true)}
                    {field("Marriage Anniversary", "firstApplicantMarriageDate", "date")}
                    {field("Occupation", "firstApplicantOccupation", "text", true)}
                    {field("Nationality", "firstApplicantNationality", "text", true)}
                    {field("Mobile", "firstApplicantMobile", "tel", true)}
                    {field("E-mail", "firstApplicantEmail", "email", true)}
                    {field("PAN Number", "firstApplicantPan")}
                    {field("Aadhaar Number", "firstApplicantAadhaar")}
                    {field("Passport / Voter ID / Licence / Aadhaar", "firstApplicantPassportOrId")}
                    {field("Office Telephone", "firstApplicantTelephoneOffice", "tel")}
                    {field("Residence Telephone", "firstApplicantTelephoneResidence", "tel")}
                    {textarea("Present Address", "firstApplicantAddress", false, true)}
                    {textarea("Permanent Address", "firstApplicantPermanentAddress")}
                    {textarea("Office Address", "firstApplicantOfficeAddress")}
                    {field("Nominee Name", "firstNomineeName")}
                    {field("Nominee Relationship", "firstNomineeRelationship")}
                </div>
            </section>

            <section className="border-b border-slate-200 pb-6">
                <h3 className="text-base font-bold text-slate-900">B. Second Applicant</h3>
                <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                    {field("Second Applicant (Mr./Mrs./Ms.)", "secondApplicantName")}
                    {field("Son / Wife / Daughter of", "secondApplicantFatherName")}
                    {field("Date of Birth / Incorporation", "secondApplicantDateOfBirth", "date")}
                    {field("Marriage Anniversary", "secondApplicantMarriageDate", "date")}
                    {field("Occupation", "secondApplicantOccupation")}
                    {field("Nationality", "secondApplicantNationality")}
                    {field("Mobile", "secondApplicantMobile", "tel")}
                    {field("E-mail", "secondApplicantEmail", "email")}
                    {field("PAN Number", "secondApplicantPan")}
                    {field("Aadhaar Number", "secondApplicantAadhaar")}
                    {field("Office Telephone", "secondApplicantTelephoneOffice", "tel")}
                    {field("Residence Telephone", "secondApplicantTelephoneResidence", "tel")}
                    {field("Passport / Voter ID / Licence / Aadhaar", "secondApplicantPassportOrId")}
                    {textarea("Present Address", "secondApplicantAddress")}
                    {textarea("Permanent Address", "secondApplicantPermanentAddress")}
                    {textarea("Office Address", "secondApplicantOfficeAddress")}
                    {field("Nominee Name", "secondNomineeName")}
                    {field("Nominee Relationship", "secondNomineeRelationship")}
                </div>
            </section>

            <section>
                <h3 className="text-base font-bold text-slate-900">15-19. Payment Plan, Plot Details & Remarks</h3>
                <div className="mt-3 grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <fieldset className="sm:col-span-2">
                        <legend className="text-sm font-medium text-slate-700">15. Payment Plan Option (please tick)</legend>
                        <div className="mt-2 flex flex-wrap gap-4 rounded-lg border border-slate-300 bg-white px-3 py-3">
                            {[['OWN_PAYMENT_PLAN', 'Own Payment Plan'], ['MANUAL_PLAN', 'Manual Plan'], ['FLEXI_PAYMENT_PLAN', 'Flexi Payment Plan']].map(([plan, label], index) => (
                                <label key={plan} className="flex items-center gap-2 text-sm text-slate-700">
                                    <input type="radio" required={index === 0} disabled={disabled} name="paymentPlan" value={plan} checked={value.paymentPlan === plan || (plan === 'OWN_PAYMENT_PLAN' && value.paymentPlan === 'DOWN_PAYMENT')} onChange={(e) => updateField("paymentPlan", e.target.value)} />
                                    {label}
                                </label>
                            ))}
                        </div>
                    </fieldset>
                    <label className="text-sm font-medium text-slate-700">Payment Mode
                        <select disabled={disabled} value={value.paymentMode} onChange={(e) => updateField("paymentMode", e.target.value)} className={inputClassName}>
                            <option value="CASH">Cash</option><option value="UPI">UPI</option><option value="BANK_TRANSFER">NEFT / RTGS / Bank Transfer</option><option value="CHEQUE">Cheque</option><option value="LOAN">Bank Loan</option>
                        </select>
                    </label>
                    {field("Booking Money / Initial Payment", "initialPayment", "number", true)}
                    {field("Booking Money in Words", "initialPaymentInWords", "text", true)}
                    {field("Cheque / NEFT / RTGS Reference", "paymentReference")}
                    {field("Payment Date", "paymentDate", "date", true)}
                    {field("Bank / Finance Company", "bankName")}
                    {field("16. Plot Area 1 (sq. ft.)", "plotArea1", "number", true)}
                    {field("Plot Area 2 (sq. ft.)", "plotArea2", "number")}
                    {field("Plot Area 3 (sq. ft.)", "plotArea3", "number")}
                    {field("Plot Area 4 (sq. ft.)", "plotArea4", "number")}
                    {field("17. Plot Sale Price (Rs. per sq. ft.)", "salePricePerSqFt", "number", true)}
                    {field("18. Additional / Development Charge (Rs. per sq. ft.)", "developmentChargePerSqFt", "number")}
                    {field("Application Date", "applicationDate", "date", true)}
                    {field("Application Place", "applicationPlace", "text", true)}
                    {textarea("19. Any Other Remarks", "remarks", true)}
                    {textarea("Additional Notes", "notes", true)}
                </div>
            </section>
        </div>
    );
}
