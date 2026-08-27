"use client";

import { useState, useEffect, useRef } from "react";
import { updateDoc, collection, setDoc, doc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import api from "@/lib/api";
import { PageHeader } from "@/components/ui/PageHeader";
import {
  Bookmark,
  User,
  CreditCard,
  Download,
  Loader2,
  FileDown,
  Pencil,
} from "lucide-react";
import { toast } from "react-hot-toast";
import { formatCurrency, formatDateTime } from "@/lib/formatters";
import { getSetting } from "@/lib/cmsService";
import { Modal } from "@/components/ui/Modal";
import { Button } from "@/components/ui/Button";
import { useParams } from "next/navigation";
import { GState, jsPDF } from "jspdf";
import html2canvas from "html2canvas";
import {
  BookingApplicationForm,
  BookingApplicationFormData,
  BookingApplicationFormErrors,
  emptyBookingApplicationForm,
  validateBookingApplicationForm,
} from "@/components/BookingApplicationForm";

function amountInWords(amount: number) {
  const ones = [
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
  ];
  const tens = [
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety",
  ];
  const underThousand = (value: number): string => {
    if (value < 20) return ones[value];
    if (value < 100)
      return `${tens[Math.floor(value / 10)]}${value % 10 ? ` ${ones[value % 10]}` : ""}`;
    return `${ones[Math.floor(value / 100)]} Hundred${value % 100 ? ` ${underThousand(value % 100)}` : ""}`;
  };
  const rounded = Math.round(amount);
  if (!rounded) return "INR Zero Only";
  const parts: string[] = [];
  const crore = Math.floor(rounded / 10000000);
  const lakh = Math.floor((rounded % 10000000) / 100000);
  const thousand = Math.floor((rounded % 100000) / 1000);
  const remainder = rounded % 1000;
  if (crore) parts.push(`${underThousand(crore)} Crore`);
  if (lakh) parts.push(`${underThousand(lakh)} Lakh`);
  if (thousand) parts.push(`${underThousand(thousand)} Thousand`);
  if (remainder) parts.push(underThousand(remainder));
  return `INR ${parts.join(" ")} Only`;
}

export default function BookingDetailsPage() {
  const params = useParams();
  const [booking, setBooking] = useState<any>(null);
  const [payments, setPayments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isPaymentModalOpen, setIsPaymentModalOpen] = useState(false);
  const [paymentAmount, setPaymentAmount] = useState("");
  const [paymentMode, setPaymentMode] = useState("CASH");
  const [transactionId, setTransactionId] = useState("");
  const [paymentNotes, setPaymentNotes] = useState("");
  const [loggingPayment, setLoggingPayment] = useState(false);
  const [downloadingPaymentId, setDownloadingPaymentId] = useState<
    string | null
  >(null);
  const [isApplicationFormOpen, setIsApplicationFormOpen] = useState(false);
  const [applicationForm, setApplicationForm] =
    useState<BookingApplicationFormData>(emptyBookingApplicationForm);
  const [applicationFormErrors, setApplicationFormErrors] =
    useState<BookingApplicationFormErrors>({});
  const [updatingApplicationForm, setUpdatingApplicationForm] = useState(false);
  const [uploadingApplicantPhoto, setUploadingApplicantPhoto] = useState(false);
  const [downloadingApplicationForm, setDownloadingApplicationForm] = useState(false);
  const downloadingApplicationFormRef = useRef(false);

  useEffect(() => {
    if (params?.id) loadBooking();
  }, [params?.id]);

  async function loadBooking() {
    try {
      const [res, paymentsRes] = await Promise.all([
        api.get(`/bookings/${params.id}`),
        api.get(`/payments`, {
          filters: [{ field: "bookingId", operator: "==", value: params.id }],
        }),
      ]);
      if (res.data.success) {
        const bookingData = res.data.data;
        const [projectResult, plotResult] = await Promise.allSettled([
          bookingData.projectId
            ? api.get(`/projects/${bookingData.projectId}`)
            : Promise.resolve(null),
          bookingData.plotId ? api.get(`/plots/${bookingData.plotId}`) : Promise.resolve(null),
        ]);
        const project = projectResult.status === "fulfilled"
          ? projectResult.value?.data?.data || null
          : null;
        const plot = plotResult.status === "fulfilled"
          ? plotResult.value?.data?.data || null
          : null;
        if (projectResult.status === "rejected") {
          console.warn("Unable to load booking project details", projectResult.reason);
        }
        if (plotResult.status === "rejected") {
          console.warn("Unable to load booking plot details", plotResult.reason);
        }
        setBooking({
          ...bookingData,
          project,
          plot,
          projectName: project?.name?.en || project?.name || bookingData.projectName,
          siteLayout: project?.siteLayout || bookingData.siteLayout || "",
          plotNumber: plot?.plotNumber || bookingData.plotNumber,
        });
      }
      else toast.error("Booking not found");
      if (paymentsRes.data.success) setPayments(paymentsRes.data.data);
    } catch (error) {
      console.error(error);
      toast.error("Failed to load booking details");
    } finally {
      setLoading(false);
    }
  }

  const handleLogPayment = async () => {
    const amount = parseFloat(paymentAmount);
    if (isNaN(amount) || amount <= 0) {
      toast.error("Please enter a valid amount");
      return;
    }
    if (paymentMode !== "CASH" && !transactionId.trim()) {
      toast.error("Please enter the transaction ID");
      return;
    }
    setLoggingPayment(true);
    try {
      const paymentRef = doc(collection(db, "payments"));
      await setDoc(paymentRef, {
        id: paymentRef.id,
        bookingId: booking.id,
        customerId: booking.customerId,
        amount,
        mode: paymentMode,
        transactionId: paymentMode !== "CASH" ? transactionId.trim() : null,
        notes: paymentNotes,
        status: "COMPLETED",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      });
      const newPaidAmount = (booking.paidAmount || 0) + amount;
      await updateDoc(doc(db, "assignPlots", booking.id), {
        paidAmount: newPaidAmount,
        updatedAt: new Date().toISOString(),
      });
      setBooking({ ...booking, paidAmount: newPaidAmount });
      toast.success("Payment logged successfully");
      setIsPaymentModalOpen(false);
      setPaymentAmount("");
      setTransactionId("");
      setPaymentNotes("");
      loadBooking();
    } catch (error) {
      console.error(error);
      toast.error("Failed to log payment");
    } finally {
      setLoggingPayment(false);
    }
  };

  const handleDownloadReceipt = async (payment: any) => {
    setDownloadingPaymentId(payment.id);
    try {
      const receiptSettings = await getSetting("receiptSettings");
      if (!receiptSettings) {
        throw new Error(
          "Receipt settings are not configured in Admin Settings",
        );
      }
      const receipt = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: "a4",
      });
      const margin = 14;
      const pageWidth = receipt.internal.pageSize.getWidth();
      const amount = Number(payment.amount || 0);
      // jsPDF's built-in Helvetica font does not contain the INR glyph.
      const amountText = `Rs. ${amount.toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
      const voucherNumber = payment.voucherNumber || payment.id || "N/A";
      const date = payment.receiptDate || formatDateTime(payment.createdAt);
      const account = `${booking.projectName || "Plot Booking"}${booking.plotNumber ? ` - Plot ${booking.plotNumber}` : ""}`;
      const through =
        payment.bankName ||
        payment.through ||
        payment.transactionId ||
        payment.mode ||
        "N/A";
      const wrap = (text: string, x: number, y: number, width: number) =>
        receipt.text(receipt.splitTextToSize(text, width), x, y, {
          lineHeightFactor: 1.35,
        });

      receipt.setTextColor(0, 0, 0);
      receipt.setFontSize(16);
      receipt.setFont("helvetica", "bold");
      receipt.text(receiptSettings.companyName, pageWidth / 2, 28, {
        align: "center",
      });

      receipt.setFontSize(11);
      receipt.setFont("helvetica", "normal");
      receipt.text(receiptSettings.address, pageWidth / 2, 35, {
        align: "center",
      });
      receipt.text(
        `State Name : ${receiptSettings.stateName}, Code : ${receiptSettings.stateCode}`,
        pageWidth / 2,
        41,
        { align: "center" },
      );
      receipt.text(`CIN: ${receiptSettings.cin}`, pageWidth / 2, 47, {
        align: "center",
      });
      receipt.text(`E-Mail : ${receiptSettings.email}`, pageWidth / 2, 53, {
        align: "center",
      });

      receipt.setFontSize(15);
      receipt.setFont("helvetica", "bold");
      receipt.text("Receipt Voucher", pageWidth / 2, 66, { align: "center" });

      receipt.setFontSize(12);
      receipt.text(`No. : ${voucherNumber}`, margin, 79);
      receipt.text(`Dated : ${date}`, pageWidth - margin, 79, {
        align: "right",
      });

      const tableTop = 87;
      const particularsWidth = 127;
      const amountWidth = pageWidth - margin * 2 - particularsWidth;
      const rowHeights = [25, 25, 34];
      receipt.setLineWidth(0.3);
      receipt.rect(margin, tableTop, particularsWidth, 10);
      receipt.rect(margin + particularsWidth, tableTop, amountWidth, 10);
      receipt.setFont("helvetica", "bold");
      receipt.text("Particulars", margin + 7, tableTop + 7);
      receipt.text("Amount", pageWidth - margin - 6, tableTop + 7, {
        align: "right",
      });

      let rowTop = tableTop + 10;
      const row = (
        height: number,
        label: string,
        value: string,
        rowAmount = "",
      ) => {
        receipt.rect(margin, rowTop, particularsWidth, height);
        receipt.rect(margin + particularsWidth, rowTop, amountWidth, height);
        receipt.setFont("helvetica", "bold");
        receipt.text(label, margin + 7, rowTop + 8);
        receipt.setFont("helvetica", "normal");
        wrap(value, margin + 7, rowTop + 18, particularsWidth - 14);
        if (rowAmount)
          receipt.text(rowAmount, pageWidth - margin - 6, rowTop + 8, {
            align: "right",
          });
        rowTop += height;
      };
      row(rowHeights[0], "Account :", account, amountText);
      row(rowHeights[1], "Through :", through);
      row(
        rowHeights[2],
        "Amount (in words) :",
        amountInWords(amount),
        amountText,
      );

      receipt.setFontSize(13);
      receipt.setFont("helvetica", "bold");
      receipt.text(
        "Total",
        pageWidth - margin - amountWidth - 18,
        rowTop + 10,
        { align: "right" },
      );
      receipt.text(amountText, pageWidth - margin - 6, rowTop + 10, {
        align: "right",
      });
      receipt.setFontSize(11);
      receipt.text(
        receiptSettings.authorisedSignatory,
        pageWidth - margin,
        250,
        { align: "right" },
      );

      const safeReceiptId = String(payment.id || "payment").replace(
        /[^a-z0-9_-]/gi,
        "-",
      );
      receipt.save(`payment-receipt.pdf`);
      toast.success("Receipt downloaded");
    } catch (error) {
      console.error(error);
      toast.error("Failed to download receipt");
    } finally {
      setDownloadingPaymentId(null);
    }
  };

  const getApplicationForm = (): BookingApplicationFormData => ({
    ...emptyBookingApplicationForm,
    ...(booking.applicationForm || {}),
    firstApplicantMobile:
      booking.applicationForm?.firstApplicantMobile ||
      booking.mobileNumber ||
      "",
    firstApplicantName:
      booking.applicationForm?.firstApplicantName || booking.customerName || "",
  });

  const handleOpenApplicationForm = () => {
    const currentForm = getApplicationForm();
    setApplicationForm(currentForm);
    setApplicationFormErrors(validateBookingApplicationForm(currentForm));
    setIsApplicationFormOpen(true);
  };

  const handleUpdateApplicationForm = async (
    event: React.FormEvent<HTMLFormElement>,
  ) => {
    event.preventDefault();
    const validationErrors = validateBookingApplicationForm(applicationForm);
    setApplicationFormErrors(validationErrors);
    if (Object.keys(validationErrors).length > 0) {
      toast.error("Please fix the validation errors in the form");
      return;
    }

    setUpdatingApplicationForm(true);
    try {
      await api.put(`/bookings/${booking.id}`, {
        applicationForm,
        mobileNumber: applicationForm.firstApplicantMobile.trim(),
      });
      const initialPaymentAmount = Number(applicationForm.initialPayment) || 0;
      const initialPaymentRecord = payments.find(
        (payment) =>
          payment.id === booking.initialPaymentId ||
          payment.paymentType === "BOOKING_INITIAL" ||
          payment.notes === "Initial payment from booking application",
      );
      if (initialPaymentRecord) {
        await updateDoc(doc(db, "payments", initialPaymentRecord.id), {
          amount: initialPaymentAmount,
          mode: applicationForm.paymentMode,
          transactionId:
            applicationForm.paymentMode === "CASH"
              ? null
              : applicationForm.paymentReference.trim(),
          bankName: applicationForm.bankName.trim(),
          updatedAt: new Date().toISOString(),
        });
      } else if (initialPaymentAmount > 0) {
        const paymentRef = doc(collection(db, "payments"));
        await setDoc(paymentRef, {
          id: paymentRef.id,
          bookingId: booking.id,
          customerId: booking.customerId,
          amount: initialPaymentAmount,
          mode: applicationForm.paymentMode,
          transactionId:
            applicationForm.paymentMode === "CASH"
              ? null
              : applicationForm.paymentReference.trim(),
          bankName: applicationForm.bankName.trim(),
          paymentType: "BOOKING_INITIAL",
          notes: "Initial payment from booking application",
          status: "COMPLETED",
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        });
        await api.put(`/bookings/${booking.id}`, { initialPaymentId: paymentRef.id });
      }
      const otherPaymentsTotal = payments
        .filter((payment) => payment.id !== initialPaymentRecord?.id)
        .reduce((total, payment) => total + Number(payment.amount || 0), 0);
      await updateDoc(doc(db, "assignPlots", booking.id), {
        paidAmount: otherPaymentsTotal + initialPaymentAmount,
        updatedAt: new Date().toISOString(),
      });
      setBooking({
        ...booking,
        applicationForm,
        mobileNumber: applicationForm.firstApplicantMobile.trim(),
        paidAmount: otherPaymentsTotal + initialPaymentAmount,
      });
      await loadBooking();
      setIsApplicationFormOpen(false);
      toast.success("Application form updated");
    } catch (error: any) {
      console.error(error);
      toast.error(
        error.response?.data?.message || "Failed to update application form",
      );
    } finally {
      setUpdatingApplicationForm(false);
    }
  };

  const handleDownloadTextApplicationForm = async () => {
    if (downloadingApplicationFormRef.current) return;
    downloadingApplicationFormRef.current = true;
    setDownloadingApplicationForm(true);
    try {
      const form = getApplicationForm();
      const applicationSettings = await getSetting("receiptSettings");
      if (!applicationSettings) {
        throw new Error("Company details are not configured in Admin Settings");
      }
      const pdf = new jsPDF({ unit: "mm", format: "a4" });
      const addPdfFooter = () => {
        pdf.setFillColor(174, 174, 174);
        pdf.rect(0, 283, 210, 14, "F");
        pdf.setTextColor(255, 255, 255);
        pdf.setFont("helvetica", "bold");
        pdf.setFontSize(11);
        pdf.text(applicationSettings.contactPhone || "", 48, 292, {
          align: "center",
        });
        pdf.setFillColor(255, 247, 240);
        pdf.roundedRect(78, 286, 54, 9, 2, 2, "F");
        pdf.setTextColor(255, 123, 61);
        pdf.text("CONTACT US", 105, 292, { align: "center" });
        pdf.setTextColor(255, 255, 255);
        pdf.text(applicationSettings.website || "", 162, 292, {
          align: "center",
        });
      };
      const loadImage = async (path: string) => {
        const response = await fetch(path);
        if (!response.ok) throw new Error(`Unable to load ${path}`);
        const blob = await response.blob();
        return new Promise<string>((resolve, reject) => {
          const reader = new FileReader();
          reader.onloadend = () => resolve(String(reader.result));
          reader.onerror = () => reject(new Error(`Unable to read ${path}`));
          reader.readAsDataURL(blob);
        });
      };
      const applicantPhotos = await Promise.all(
        [form.firstApplicantPhoto, form.secondApplicantPhoto].map(async (photoUrl) => {
          if (!photoUrl) return "";
          try {
            return await loadImage(
              `/api/site-layout?url=${encodeURIComponent(photoUrl)}`,
            );
          } catch (error) {
            console.warn("Unable to load applicant photo", error);
            return "";
          }
        }),
      );
      const getPhotoFormat = (dataUrl: string) =>
        dataUrl.startsWith("data:image/png") ? "PNG" : "JPEG";
      const registrationDetails = [
        `GST REGISTRATION NUMBER - ${applicationSettings.gstNumber || ""}`,
        `CIN NUMBER - ${applicationSettings.cin || ""}`,
        `PAN NUMBER - ${applicationSettings.panNumber || ""}`,
        `TAN NUMBER - ${applicationSettings.tanNumber || ""}`,
      ];
      const addBrandHeader = async () => {
        pdf.addImage(companyLogo, "PNG", 0, 7, 200, 100);
        pdf.setTextColor("#431821");
        pdf.setFont("times", "bold");
        pdf.setFontSize(16);
        pdf.text(applicationSettings.taglineEnglish || "", 105, 115, {
          align: "center",
          maxWidth: 170,
        });
        if (!applicationSettings.taglineHindi) return;

        const hindiTagline = window.document.createElement("div");
        hindiTagline.textContent = applicationSettings.taglineHindi;
        hindiTagline.style.cssText =
          "position:fixed;left:-10000px;top:0;width:680px;min-height:150px;padding:8px 10px 18px;box-sizing:border-box;color:#431821;font:500 44px Arial,sans-serif;text-align:center;line-height:1.35;white-space:normal;";
        window.document.body.appendChild(hindiTagline);
        await new Promise<void>((resolve) =>
          requestAnimationFrame(() => resolve()),
        );
        const hindiCanvas = await html2canvas(hindiTagline, {
          scale: 2,
          backgroundColor: null,
        });
        pdf.addImage(
          hindiCanvas.toDataURL("image/png"),
          "PNG",
          25,
          118,
          170,
          30,
        );
        hindiTagline.remove();
      };
      const addRegistrationDetails = () => {
        pdf.setTextColor("#431821");
        pdf.setFont("times", "normal");
        pdf.setFontSize(5.5);
        registrationDetails.forEach((detail, index) => {
          const lines = pdf.splitTextToSize(detail, 72);
          pdf.text(lines, 8, 8 + index * 4, { lineHeightFactor: 1 });
        });
      };
      const [companyLogo, transparentLogo, handsImage] = await Promise.all([
        loadImage("/logo_with_text.png"),
        loadImage("/transparent_logo.png"),
        loadImage("/hands.jpg"),
      ]);

      // Page 1
      await addBrandHeader();
      pdf.setTextColor(181, 43, 32);
      pdf.setFontSize(11);
      pdf.setTextColor(91, 48, 41);
      pdf.setFont("times", "bold");
      pdf.setFontSize(11);
      pdf.addImage(handsImage, "JPEG", 0, 100, 210, 180);
      pdf.text(
        "THE APPLICATION FORM IS ON THE NEXT PAGE.\nPLEASE OPEN AND FILL IT OUT.",
        105,
        250,
        { align: "center", maxWidth: 120 },
      );
      addRegistrationDetails();
      addPdfFooter();
      pdf.setTextColor(0, 0, 0);
      pdf.addPage();
      // Page 2
      await addBrandHeader();
      pdf.setTextColor(181, 43, 32);
      pdf.setFontSize(11);
      pdf.setTextColor("#431821");
      pdf.setTextColor(91, 48, 41);
      pdf.setFont("times", "bold");
      pdf.setFontSize(11);
      pdf.setTextColor("#431821");
      pdf.text(`NAME MR./MRS./: ${form.firstApplicantName.trim()}`, 105, 160, {
        align: "center",
        maxWidth: 180,
      });
      pdf.setTextColor("#431821");
      pdf.text(
        `PLOT NUMBER: ${String(booking.plotNumber || "").trim()}`,
        105,
        170,
        { align: "center", maxWidth: 180 },
      );
      pdf.addImage(handsImage, "JPEG", 0, 120, 210, 180);
      addRegistrationDetails();
      addPdfFooter();
      pdf.setTextColor(0, 0, 0);
      pdf.addPage();
      // Page 3: render the brochure layout in the browser so Hindi and map details match the design.
      const mission =
        "IS TO PROVIDE AFFORDABLE, LEGALLY SECURE, AND HIGH-QUALITY PLOTS WHILE MAINTAINING TRANSPARENCY, INTEGRITY, AND TRUST IN THE REAL ESTATE SECTOR. WE AIM TO DEVELOP WELL-PLANNED RESIDENTIAL PROJECTS WITH MODERN AMENITIES, SETTING NEW STANDARDS IN PROPERTY DEVELOPMENT. CUSTOMER SATISFACTION IS OUR TOP PRIORITY, ENSURING THEIR INVESTMENTS ARE SECURE AND PROFITABLE.";
      const vision =
        "TO REDEFINE REAL ESTATE BY DEVELOPING WELL-PLANNED, AFFORDABLE, AND LEGALLY SECURE PROPERTIES THAT CREATE LONG-TERM VALUE FOR OUR CUSTOMERS AND CONTRIBUTE TO SUSTAINABLE URBAN GROWTH.";
      const officeLocation =
        `${applicationSettings.address ?? ""}, ${applicationSettings.stateName ?? ""}, ${applicationSettings.stateCode ?? ""}` ||
        "BYPASS ROAD SIPHAI, TOLA, PURNEA, 854301";
      const projectId = booking.projectId || booking.project?.id || booking.plot?.projectId;
      let siteLayout = "";
      if (projectId) {
        try {
          const projectResponse = await api.get(`/projects/${projectId}`);
          siteLayout = projectResponse.data?.data?.siteLayout || "";
        } catch (error) {
          console.warn("Unable to fetch project site layout", error);
        }
      }
      siteLayout ||= booking.siteLayout || "";
      let siteLayoutDataUrl = "";
      if (siteLayout) {
        try {
          siteLayoutDataUrl = await loadImage(
            `/api/site-layout?url=${encodeURIComponent(siteLayout)}`,
          );
        } catch (error) {
          console.warn("Unable to load project site layout image", error);
        }
      }
      const plotRows = [
        ["30", "29", "28", "27", "26", "25", "23", "24"],
        ["31", "32", "33", "34", "35", "22", "21", "20"],
        ["39", "38", "37", "36", "14", "15", "16", "17"],
        ["40", "41", "42", "43", "13", "12", "11", "10"],
        ["47", "46", "45", "44", "6", "7", "8", "9"],
        ["48", "49", "50", "51", "5", "4", "3", "2"],
        ["55", "54", "53", "52", "1", "", "", ""],
        ["56", "57", "58", "", "", "", "", ""],
      ];
      const brochure = document.createElement("div");
      brochure.style.cssText =
        "position:fixed;left:-10000px;top:0;width:744px;height:1052px;background:#fff;color:#431821;font-family:Georgia,'Times New Roman',serif;overflow:hidden;";
      const plotCells = plotRows
        .flatMap((row) =>
          row.map((plotNumber) =>
            plotNumber
              ? `<div style=\"height:72px;border:1px solid #6c8790;background:#fbfdfb;text-align:center;padding-top:9px;box-sizing:border-box;color:#536fae;font:bold 24px Georgia;\">${plotNumber}<small style=\"display:block;color:#4c9c63;font:12px Georgia;margin-top:6px;\">3484</small></div>`
              : `<div></div>`,
          ),
        )
        .join("");
      const mapMarkup = siteLayoutDataUrl
        ? `<img src="${siteLayoutDataUrl}" alt="Site layout" style="width:100%;height:100%;object-fit:contain;display:block;" />`
        : `<div style="width:100%;height:100%;border:3px solid #637a8d;display:grid;grid-template-columns:repeat(8,1fr);">${plotCells}</div>`;
      const brochureHeader = `
        <div style="width:100%;text-align:center;color:#d29a00;font-size:125px;line-height:.9;font-weight:bold;white-space:nowrap;transform:scaleX(1.28);text-shadow:3px 0 #ff00d9,-3px 0 #00dce8;">
          शुभायतनम्
        </div>`;
      const brochureProfile = `
       <div style="position:absolute;left:28px;top:208px;width:228px;text-align:center;">
       <h2 style="color:#ff3030;font-size:24px;font-weight:700;margin:0 0 8px;">OUR MISSION</h2>
       <div style="font-size:12px;font-weight:400;">${mission}</div>
       <h2 style="color:#ff3030;font-size:24px;font-weight:700;margin:20px 0 8px;">OUR VISION</h2>
       <div style="color:#431821;font-size:12px;font-weight:400;">${vision}</div></div>`;
      const brochureMap = `
        <div style="position:absolute;left:282px;top:205px;width:428px;height:576px;">
          ${mapMarkup}
        </div>`;
      const brochureOffice = `
        <div style="position:absolute;left:0;right:0;top:900px;text-align:center;color:#ff3030;font-size:25px;font-weight:bold;">
          OFFICE LOCATION
          <div style="font-size:21px;margin-top:8px;white-space:nowrap;">${officeLocation.toUpperCase()}</div>
        </div>`;
      const brochureFooter = `
        <div style="position:absolute;bottom:0;left:0;right:0;height:50px;background:#aeaeae;color:#fff;font:bold 18px Arial;display:flex;align-items:center;justify-content:space-around;">
          <span>${applicationSettings.contactPhone || ""}</span>
          <b style="background:#fff7f0;color:#ff7b3d;padding:10px 22px;border-radius:10px;">CONTACT US</b>
          <span>${applicationSettings.website || ""}</span>
        </div>`;
      brochure.innerHTML = `
        <div style="height:100%;width:100%;position:relative;box-sizing:border-box;padding:8px 28px 0;">
          ${brochureHeader}
          ${brochureProfile}
          ${brochureMap}
          ${brochureOffice}
          ${brochureFooter}
        </div>`;
      document.body.appendChild(brochure);
      await new Promise<void>((resolve) =>
        requestAnimationFrame(() => resolve()),
      );
      const brochureCanvas = await html2canvas(brochure, {
        scale: 2,
        backgroundColor: "#ffffff",
        useCORS: true,
      });
      brochure.remove();
      pdf.addImage(
        brochureCanvas.toDataURL("image/png"),
        "PNG",
        0,
        0,
        210,
        297,
      );
      pdf.setTextColor(0, 0, 0);
      addPdfFooter();
      pdf.setTextColor(0, 0, 0);
      pdf.addPage();
      // Page 4: application form
      const margin = 16;
      const width = 210 - margin * 2;
      let y = 18;
      const value = (text: string) =>
        text.trim() ||
        ".....................................";
      const addPhotoBoxes = () => {
        const boxWidth = 25;
        const boxHeight = 32;
        const boxGap = 6;
        const startX = 210 - margin - boxWidth * 2 - boxGap;
        const boxY = 16;

        pdf.setDrawColor(67, 24, 33);
        pdf.setLineWidth(0.4);
        [0, 1].forEach((index) => {
          const boxX = startX + index * (boxWidth + boxGap);
          pdf.rect(boxX, boxY, boxWidth, boxHeight);
          if (applicantPhotos[index]) {
            pdf.addImage(
              applicantPhotos[index],
              getPhotoFormat(applicantPhotos[index]),
              boxX + 1,
              boxY + 1,
              boxWidth - 2,
              boxHeight - 2,
            );
          }
          pdf.setFont("times", "normal");
          pdf.setFontSize(7);
          if (!applicantPhotos[index]) {
            pdf.text(
              index === 0 ? "First Applicant" : "Second Applicant",
              boxX + boxWidth / 2,
              boxY + boxHeight / 2,
              { align: "center", maxWidth: boxWidth - 4 },
            );
          }
        });
      };
      const addPageIfNeeded = (height = 8) => {
        if (y + height > 280) {
          pdf.addPage();
          y = 18;
        }
      };

      const text = (
        content: string,
        size = 9,
        bold = false,
        x = margin,
        align: "left" | "center" | "right" = "left",
        underline = false,
        color = "#431821",
      ) => {
        addPageIfNeeded();

        pdf.setTextColor(color);
        pdf.setFont("times", bold ? "bold" : "normal");
        pdf.setFontSize(size);

        const lines = pdf.splitTextToSize(content, width);

        lines.forEach((line: string) => {
          let textX = x;

          if (align === "center") {
            textX = pdf.internal.pageSize.getWidth() / 2;
          } else if (align === "right") {
            textX = pdf.internal.pageSize.getWidth() - margin;
          }

          pdf.text(line, textX, y, {
            align,
          });

          if (underline) {
            const textWidth = pdf.getTextWidth(line);

            let lineX = textX;

            if (align === "center") {
              lineX = textX - textWidth / 2;
            } else if (align === "right") {
              lineX = textX - textWidth;
            }

            pdf.setDrawColor(color);
            pdf.setLineWidth(0.3);

            pdf.line(lineX, y + 1, lineX + textWidth, y + 1);
          }

          y += size * 0.35 + 0.5;
        });
      };
      const textMore = (
        content: string,
        size = 9,
        bold = false,
        x = margin,
      ) => {
        addPageIfNeeded();

        pdf.setFont("times", bold ? "bold" : "normal");
        pdf.setFontSize(size);

        const lines = pdf.splitTextToSize(content, width);

        pdf.text(lines, x, y);

        y += lines.length * (size * 0.4 + 2);
      };

      const fieldRow = (
        leftLabel: string,
        leftValue: string,
        rightLabel: string,
        rightValue: string,
      ) => {
        addPageIfNeeded();

        const gap = 18;
        const columnWidth = (width - gap) / 2;

        pdf.setFont("times", "normal");
        pdf.setFontSize(9);

        // Left
        pdf.text(`${leftLabel} ${value(leftValue)}`, margin, y, {
          maxWidth: columnWidth,
          align: "left",
        });

        // Right
        pdf.text(
          `${rightLabel} ${value(rightValue)}`,
          margin + columnWidth + gap,
          y,
          {
            maxWidth: columnWidth,
            align: "left",
          },
        );

        y += 7;
      };
      const field = (label: string, fieldValue: string) =>
        textMore(`${label} ${value(fieldValue)}`, 9);
      const formatPdfDate = (date: string) => {
        const match = date.trim().match(/^(\d{4})-(\d{2})-(\d{2})$/);
        return match ? `${match[3]}-${match[2]}-${match[1]}` : date;
      };
      const plotAreaBlock = () => {
        addPageIfNeeded();
        pdf.setFont("times", "normal");
        pdf.setFontSize(9);
        pdf.text("16. PLOT AREA (SQ. FT.)", margin, y);
        const rightColumnX = margin + 65;
        const areaColumnWidth = 60;
        pdf.text(`1. SQ.FT. ${value(form.plotArea1)}`, rightColumnX, y, {
          maxWidth: areaColumnWidth,
        });
        pdf.text(
          `2. SQ.FT. ${value(form.plotArea2)}`,
          rightColumnX + areaColumnWidth + 8,
          y,
          { maxWidth: areaColumnWidth },
        );
        y += 7;
        pdf.text(`3. SQ.FT. ${value(form.plotArea3)}`, rightColumnX, y, {
          maxWidth: areaColumnWidth,
        });
        pdf.text(
          `4. SQ.FT. ${value(form.plotArea4)}`,
          rightColumnX + areaColumnWidth + 8,
          y,
          { maxWidth: areaColumnWidth },
        );
        y += 7;
      };
      const checkboxRow = () => {
        addPageIfNeeded(18);
        pdf.setFont("times", "normal");
        pdf.setFontSize(9);
        pdf.text("15. PAYMENT PLAN OPTION:", margin, y);
        pdf.text("(PLEASE TICK)", margin + 10, y + 7);
        const options = [
          ["OWN PAYMENT PLAN", "OWN_PAYMENT_PLAN", margin + 52, y + 5],
          ["MANUAL PLAN", "MANUAL_PLAN", margin + 137, y + 5],
          ["FLEXI PAYMENT PLAN", "FLEXI_PAYMENT_PLAN", margin + 52, y + 12],
        ] as const;
        options.forEach(([label, plan, x, optionY]) => {
          pdf.text(label, x, optionY);
          const boxX =
            x +
            (plan === "MANUAL_PLAN"
              ? 32
              : plan === "FLEXI_PAYMENT_PLAN"
                ? 41
                : 43);
          pdf.rect(boxX, optionY - 4, 5, 5);
          const selected = form.paymentPlan === plan;
          if (selected) {
            pdf.setLineWidth(0.6);
            pdf.line(boxX + 1, optionY - 2, boxX + 2.3, optionY - 0.7);
            pdf.line(boxX + 2.3, optionY - 0.7, boxX + 4.3, optionY - 3.2);
            pdf.setLineWidth(0.2);
          }
        });
        y += 21;
      };
      const section = (title: string) => {
        addPageIfNeeded(12);
        y += 3;
        text(title, 11, true);
        y += 2;
      };
      addPhotoBoxes();
      text("To,", 13, false);
      y += 1;
      text("The Managing Director", 13, false);
      y += 1;
      text(applicationSettings.companyName || "", 13, false);
      y += 1;
      text(
        `${applicationSettings.address || ""} ${applicationSettings.stateName || ""}\n${applicationSettings.stateCode || ""}`,
        13,
        false,
      );
      y += 6;
      text("Dear Sir,", 13, false);
      text(
        `I/We request you that my/our application may be accepted for booking of residential plot in our project ${value(booking.projectName || "")} which plot no. is ${value(booking.plotNumber || "")}. I/We agree to sign and execute, as and when required by the company, the allotment letter/builder buyer understanding/development and maintenance agreement on the company's standard format. Contents have been read and understood by me/us. I/We agree to abide by the terms and conditions laid down in this application form.`,
        13,
      );
      y += 4;
      text(
        `I/We remit herewith a sum of Rs. ${value(form.initialPayment)} in words ${value(form.initialPaymentInWords)} by Cheque No./NEFT/RTGS ${value(form.paymentReference)} dated ${value(formatPdfDate(form.paymentDate))} towards the Booking Money or Part Payment for the said Plot.  (Cheque to be drawn in favour of "Shubhaytanam Buildtech Pvt Ltd. " Only)`,
        13,
      );
      y += 8;
      text(
        "I/We agree to pay the further installments of the plot cost and allied charges stipulated/demanded by the company.",
        13,
      );
      y += 6;
      text("My/Our particulars as mentioned below:", 13, false);
      section("A. FIRST APPLICANT");
      field(
        "1. Mr./Mrs./Ms.(To be filled in caps):",
        form.firstApplicantName.toUpperCase(),
      );
      field(
        "2. Son/Wife/Daughter of Mr./Mrs.(To be filled in caps):",
        form.firstApplicantFatherName.toUpperCase(),
      );
      field(
        "3. Date of Birth/Date of Incorporation:",
        formatPdfDate(form.firstApplicantDateOfBirth),
      );
      field(
        "4. Date of Marriage Anniversary:",
        formatPdfDate(form.firstApplicantMarriageDate),
      );
      fieldRow(
        "5. Occupation:",
        form.firstApplicantOccupation,
        "6. Nationality:",
        form.firstApplicantNationality,
      );
      field("7. Present Address (Residence):", form.firstApplicantAddress);
      field(
        "8. Permanent Address(Residence):",
        form.firstApplicantPermanentAddress || form.permanentAddress,
      );
      field("9. Office Address:", form.firstApplicantOfficeAddress);
      fieldRow(
        "10. Telephone (O):",
        form.firstApplicantTelephoneOffice,
        "Telephone (R):",
        form.firstApplicantTelephoneResidence,
      );
      field("11. Mobile:", form.firstApplicantMobile);
      field("12. E-mail:", form.firstApplicantEmail);
      field(
        "13. Income Tax Permanent Account (PAN) No:",
        form.firstApplicantPan,
      );
      field(
        "14. Passport No./Voter Card No./Dri. Lic. No./Aadhar No.:",
        form.firstApplicantPassportOrId || form.firstApplicantAadhaar,
      );
      fieldRow(
        "15. Nominee Name:",
        form.firstNomineeName.toUpperCase(),
        "Relationship:",
        form.firstNomineeRelationship.toUpperCase(),
      );
      y = 18;
      pdf.addPage();
      section("B. SECOND APPLICANT");
      field(
        "1. Mr./Mrs./Ms.(To be filled in caps):",
        form.secondApplicantName.toUpperCase(),
      );
      field(
        "2. Son/Wife/Daughter of Mr./Mrs.(To be filled in caps):",
        form.secondApplicantFatherName.toUpperCase(),
      );
      field(
        "3. Date of Birth/Date of Incorporation:",
        formatPdfDate(form.secondApplicantDateOfBirth),
      );
      field(
        "4. Date of Marriage Anniversary:",
        formatPdfDate(form.secondApplicantMarriageDate),
      );
      fieldRow(
        "5. Occupation:",
        form.secondApplicantOccupation,
        "6. Nationality:",
        form.secondApplicantNationality,
      );
      field("7. Present Address(Residence):", form.secondApplicantAddress);
      field(
        "8. Permanent Address(Residence):",
        form.secondApplicantPermanentAddress || form.permanentAddress,
      );
      field("9. Office Address:", form.secondApplicantOfficeAddress);
      fieldRow(
        "10. Telephone (O):",
        form.secondApplicantTelephoneOffice,
        "Telephone (R):",
        form.secondApplicantTelephoneResidence,
      );
      field("11. Mobile:", form.secondApplicantMobile);
      field("12. E-mail:", form.secondApplicantEmail);
      field(
        "13. Income Tax Permanent Account (PAN) No:",
        form.secondApplicantPan,
      );
      field(
        "13. Passport No./Voter Card No./Dri. Lic. No./Aadhar No.:",
        form.secondApplicantPassportOrId || form.secondApplicantAadhaar,
      );
      fieldRow(
        "14. Nominee Name:",
        form.secondNomineeName.toUpperCase(),
        "Relationship:",
        form.secondNomineeRelationship.toUpperCase(),
      );
      checkboxRow();
      text(
        "THE PAYMENT PLAN IS ANNEXED HERE WITH AND MENTION AS ANNEXURE-1",
        9,
        false,
      );
      plotAreaBlock();
      field(
        "17. Plot sale price Rs. per Sq. Ft.:",
        form.salePricePerSqFt,
      );
      field(
        "18. Additional/Development Charge per Sq. Ft.:",
        form.developmentChargePerSqFt,
      );
      field("19. Any other remarks:", form.remarks);
      text(
        "I/We the above applicant(s) do hereby declare that the above particulars given by me/us are true and correct to the best of my/our knowledge. I/We agree that any allotment based on this application shall be subject to fulfillment of the basic terms and conditions of the company. I/We shall abide by the terms and conditions and terms of payment plans attached to this application.",
        9,
      );
      y += 8;
      field("Date:", formatPdfDate(form.applicationDate));
      field("Place:", form.applicationPlace);
      y += 8;
      text("Name of Applicant(s).", 10, false);
      y += 6;
      fieldRow(
        "1. First Applicant:",
        `${form.firstApplicantName.toUpperCase()}`,
        "Signature:",
        ``,
      );
      fieldRow(
        "1. Second Applicant:",
        `${form.secondApplicantName.toUpperCase()}`,
        "Signature:",
        ``,
      );
      y += 4;
      text("FOR SUBHAYTANAM BUILDTECH PVT. LTD.", 10, false, 120);
      y += 8;
      text("AUTHORISED SIGNATORY", 10, false, 120);

      pdf.addPage();
      y = 16;
      text(
        "TERMS AND CONDITIONS OF BOOKING / ALLOTMENT OF",
        11,
        true,
        0,
        "center",
        true,
        "#b52b20",
      );

      text("PLOT IN OUR PROJECT", 11, true, 0, "center", true, "#b52b20");
      pdf.setTextColor("#431821");
      y += 2;
      const terms = [
        "1. Allotment of plots will be made only on the condition that the applicant has the knowledge of the project and subject to all statutory rules and notification applicable to this area.",
        "2. The Applicant(s) has fully satisfied him/her self about the interest and title of the company in the said land and understands the same.",
        "3. The Applicant(s) accepts that timely payment of Installments is the essence of the terms of booking/Allotment. In case of delay in payments, an interest shall be levied at the rate of 2% Per month for the first month of delay and the same shall be 2.5% per month for second month. In case three installments are unpaid, the booking/Allotment of plot shall stand cancelled.",
        "4. That 25% of the agreed sale value shall represent the earnest money. In the event of surrender/cancellation of allotment, the earnest money shall be forfeited and the company shall be entitled to refund of the balance amount without any interest after the said plot is allotted/sold to any other persons.",
        "5. The Applicant(s) understand and agree to the following additional charges applicable to said plot:- \n(a) 20/16 Feet Road or Corner Plot @ 15% of Basic Sale Price, if applicable, at the time of Sale deed registry the Plot. \n(b) Development charged 2/- per sq.ft. yearly (ie. Internal Road, Drainage System, Electrification, Township Boundary wall). \n(c) Additional costs charged for Community Hall facility and Park (If applicable, after the completion of project).",
        "6. The Applicant(s) accepts that the Company have the first lien and charge on the said plot for all dues and other sums Payable by the applicant(s) to the Company.",
        "7. The Applicant(s) accepts that the Application/Allotment of Plot is entirely at the discretion of the company and the company reserves the right to allot or reject any application without assigning any reasons there of.",
        "8. The Company shall have the right to effect suitable/necessary alteration in the lay-out plan as and when needed. The resultant charges if any, shall also be obtained as per the original sale rate.",
        "9. The sale deed shall be executed and registered in favour of Applicant(s) name after receiving the full sale value of the plot. The applicant(s) shall be liable to Pay Statutory charges and other statutory levies, rates, taxes, services taxes etc.",
        "10. The sale deed shall be executed and registered in favour of Applicant(s) name only.",
        "11. ANNEXTURE-1: Payment Plan \n(A) Down Payment Plan - Under the plan, the customer needs to make an upfront payment of 95% of the sale value. The sale deed of plot will be registered within a month from the date of booking. \n(B) Flexi Payment Plan - \n(i) At the time of booking - 25% \n(ii) Instalment ............................ \n(C) Manual Plan - \n(1) At the time of booking - 25% \n(i) Instalment -",
        "12. Transfer of ownership of an allotted plot in the event of sale or otherwise, it can be affected only after obtaining a No Objection Certificate from the Company.",
        "13. Since it is a Large Project, the development will be completed in phases. All major Common facilities will be completed only after completion of all the Phases.",
        "14. All dispute shall be subject to the jurisdiction of Purnia court only.",
      ];
      pdf.setFont("times", "normal");
      pdf.setFontSize(7.2);
      terms.forEach((term) => {
        const lines = pdf.splitTextToSize(term, width);
        pdf.text(lines, margin, y, { lineHeightFactor: 1.12 });
        y += lines.length * 3.3 + 2;
      });
      pdf.setFontSize(8);
      const declaration = pdf.splitTextToSize(
        "I/We have fully read and understood the terms and conditions, documents referred to therein and agree to accept them and undertake to abide by the same.",
        width,
      );
      pdf.text(declaration, margin, y, { lineHeightFactor: 1.15 });

      const pageCount = pdf.getNumberOfPages();
      for (let pageNumber = 1; pageNumber <= pageCount; pageNumber += 1) {
        pdf.setPage(pageNumber);
        if (pageNumber > 3) {
          pdf.setGState(new GState({ opacity: 0.12 }));
          pdf.addImage(transparentLogo, "PNG", 140, 175, 70, 122);
          pdf.setGState(new GState({ opacity: 1 }));
          pdf.addImage(companyLogo, "PNG", margin, 273, 20, 10);
        }
        if (pageNumber > 3 && pageNumber < pageCount) {
          pdf.setFont("times", "bold");
          pdf.setFontSize(10);
          pdf.text("To be continued", 105, 290, { align: "center" });
        }
      }

      pdf.save("booking-application-form.pdf");

      toast.success("Application form downloaded");
    } catch (error) {
      console.error(error);
      toast.error(
        error instanceof Error
          ? `Failed to download application form: ${error.message}`
          : "Failed to download application form",
      );
    } finally {
      downloadingApplicationFormRef.current = false;
      setDownloadingApplicationForm(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!booking) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl font-semibold text-slate-800">
          Booking not found
        </h2>
      </div>
    );
  }

  const balance = (booking.totalAmount || 0) - (booking.paidAmount || 0);

  return (
    <div className="space-y-6 pb-8">
      <PageHeader
        title="Booking Details"
        breadcrumbs={[
          { label: "Dashboard", href: "/dashboard" },
          { label: "Bookings", href: "/bookings" },
          { label: `Plot ${booking.plotNumber || "N/A"}` },
        ]}
      />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Summary Card */}
        <div className="col-span-1 md:col-span-3 bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="h-16 w-16 bg-blue-100 text-blue-600 rounded-2xl flex items-center justify-center">
              <Bookmark className="h-8 w-8" />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-slate-900">
                {booking.projectName}
              </h2>
              <p className="text-slate-500 font-medium">
                Plot {booking.plotNumber}
              </p>
            </div>
          </div>
          <div
            className={`px-4 py-2 rounded-full text-sm font-bold ${booking.status === "SOLD"
              ? "bg-green-100 text-green-700"
              : "bg-blue-100 text-blue-700"
              }`}
          >
            {booking.status}
          </div>
        </div>

        {/* Customer Info */}
        <div className="col-span-1 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
          <div className="mb-4 flex items-center justify-between border-b border-slate-100 pb-2">
            <h3 className="text-lg font-semibold text-slate-900 flex items-center gap-2">
              <User className="h-5 w-5 text-slate-400" />
              Customer Details
            </h3>
            <button
              type="button"
              onClick={handleOpenApplicationForm}
              title="Update application form"
              aria-label="Update application form"
              className="rounded-lg p-2 text-slate-400 transition-colors hover:bg-blue-50 hover:text-blue-600"
            >
              <Pencil className="h-4 w-4" />
            </button>
          </div>
          <div className="space-y-4">
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">
                Name
              </p>
              <p className="text-base font-bold text-slate-900 mt-1">
                {booking.customerName || "N/A"}
              </p>
            </div>
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">
                Mobile Number
              </p>
              <p className="text-base font-bold text-slate-900 mt-1">
                {booking.mobileNumber || "N/A"}
              </p>
            </div>
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">
                Booking Date
              </p>
              <p className="text-sm font-bold text-slate-900 mt-1">
                {booking.createdAt ? formatDateTime(booking.createdAt) : "N/A"}
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={handleDownloadTextApplicationForm}
            disabled={downloadingApplicationForm}
            className="mt-5 inline-flex w-full items-center justify-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-sm font-semibold text-slate-700 transition-colors hover:border-blue-300 hover:bg-blue-50 hover:text-blue-700 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {downloadingApplicationForm ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <FileDown className="h-4 w-4" />
            )}
            {downloadingApplicationForm
              ? "Generating Booking Form..."
              : "Download Booking Form"}
          </button>
        </div>

        {/* Financial Info & EMI Tracking */}
        <div className="col-span-1 md:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
          <div className="flex items-center justify-between mb-4 border-b border-slate-100 pb-2">
            <h3 className="text-lg font-semibold text-slate-900 flex items-center gap-2">
              <CreditCard className="h-5 w-5 text-slate-400" />
              Payment & EMI Tracking
            </h3>
            <button
              onClick={() => setIsPaymentModalOpen(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm font-semibold hover:bg-blue-700 transition-colors"
            >
              Log Payment
            </button>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
            <div className="p-4 bg-slate-50 rounded-xl border border-slate-100">
              <p className="text-xs font-semibold text-slate-500 uppercase">
                Total Amount
              </p>
              <p className="text-xl font-bold text-slate-900 mt-1">
                {formatCurrency(booking.totalAmount || 0)}
              </p>
            </div>
            <div className="p-4 bg-green-50 rounded-xl border border-green-100">
              <p className="text-xs font-semibold text-green-600 uppercase">
                Paid Amount
              </p>
              <p className="text-xl font-bold text-green-700 mt-1">
                {formatCurrency(booking.paidAmount || 0)}
              </p>
            </div>
            <div
              className={`p-4 rounded-xl border ${balance > 0 ? "bg-red-50 border-red-100" : "bg-slate-50 border-slate-100"}`}
            >
              <p
                className={`text-xs font-semibold uppercase ${balance > 0 ? "text-red-600" : "text-slate-500"}`}
              >
                Pending Balance
              </p>
              <p
                className={`text-xl font-bold mt-1 ${balance > 0 ? "text-red-700" : "text-slate-900"}`}
              >
                {formatCurrency(balance)}
              </p>
            </div>
          </div>

          <h4 className="text-sm font-semibold text-slate-900 mb-3">
            Recent Payments (Ledger)
          </h4>
          {payments.length === 0 ? (
            <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 text-center text-sm text-slate-500">
              No payments logged yet.
            </div>
          ) : (
            <div className="space-y-3">
              {payments
                .sort(
                  (a, b) =>
                    new Date(b.createdAt).getTime() -
                    new Date(a.createdAt).getTime(),
                )
                .map((payment) => (
                  <div
                    key={payment.id}
                    className="flex justify-between items-center gap-3 p-3 rounded-lg border border-slate-100 bg-white"
                  >
                    <div>
                      <p className="font-semibold text-sm text-slate-900">
                        {formatCurrency(payment.amount)}
                      </p>
                      <p className="text-xs text-slate-500 mt-0.5">
                        {payment.mode}
                        {payment.transactionId &&
                          ` (Txn: ${payment.transactionId})`}
                        {payment.notes && ` - ${payment.notes}`}
                      </p>
                    </div>
                    <div className="flex items-center gap-3">
                      <div className="text-right">
                        <p className="text-xs font-medium text-slate-900">
                          {formatDateTime(payment.createdAt)}
                        </p>
                        <span className="text-[10px] font-bold text-green-700 bg-green-100 px-2 py-0.5 rounded-full mt-1 inline-block">
                          COMPLETED
                        </span>
                      </div>
                      <button
                        type="button"
                        onClick={() => handleDownloadReceipt(payment)}
                        disabled={downloadingPaymentId === payment.id}
                        aria-label={`Download receipt for ${formatCurrency(payment.amount)}`}
                        title="Download receipt"
                        className="inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-slate-200 text-slate-600 transition-colors hover:border-blue-300 hover:bg-blue-50 hover:text-blue-600 disabled:cursor-not-allowed disabled:opacity-60"
                      >
                        {downloadingPaymentId === payment.id ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <Download className="h-4 w-4" />
                        )}
                      </button>
                    </div>
                  </div>
                ))}
            </div>
          )}
        </div>
      </div>

      {/* Log Payment Modal */}
      <Modal
        isOpen={isPaymentModalOpen}
        onClose={() => setIsPaymentModalOpen(false)}
        title="Log Manual Payment"
        maxWidth="md"
        footer={
          <div className="flex justify-end gap-3 w-full">
            <Button
              variant="secondary"
              onClick={() => setIsPaymentModalOpen(false)}
            >
              Cancel
            </Button>
            <Button onClick={handleLogPayment} isLoading={loggingPayment}>
              Save Payment
            </Button>
          </div>
        }
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">
              Amount (₹)
            </label>
            <input
              type="number"
              value={paymentAmount}
              onChange={(e) => setPaymentAmount(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="e.g. 50000"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">
              Payment Mode
            </label>
            <select
              value={paymentMode}
              onChange={(e) => setPaymentMode(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="CASH">Cash</option>
              <option value="UPI">UPI</option>
              <option value="BANK_TRANSFER">Bank Transfer / NEFT</option>
              <option value="CHEQUE">Cheque</option>
              <option value="LOAN">Bank Loan</option>
            </select>
          </div>
          {paymentMode !== "CASH" && (
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Transaction ID / UTR
              </label>
              <input
                type="text"
                value={transactionId}
                onChange={(e) => setTransactionId(e.target.value)}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="e.g. UTR123456789"
              />
            </div>
          )}
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">
              Notes
            </label>
            <textarea
              value={paymentNotes}
              onChange={(e) => setPaymentNotes(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Cheque number, UTR, etc."
              rows={3}
            />
          </div>
        </div>
      </Modal>

      <Modal
        isOpen={isApplicationFormOpen}
        onClose={() => setIsApplicationFormOpen(false)}
        title="Update Plot Booking Application"
        fullScreen
        footer={
          <div className="flex w-full justify-end gap-3">
            <Button
              variant="secondary"
              type="button"
              onClick={() => setIsApplicationFormOpen(false)}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              form="application-form"
              disabled={updatingApplicationForm || uploadingApplicantPhoto || Object.keys(applicationFormErrors).length > 0}
              isLoading={updatingApplicationForm || uploadingApplicantPhoto}
            >
              Update Form
            </Button>
          </div>
        }
      >
        <form id="application-form" onSubmit={handleUpdateApplicationForm}>
          <BookingApplicationForm
            value={applicationForm}
            bookingId={booking.id}
            onPhotoUploadStateChange={setUploadingApplicantPhoto}
            onChange={(nextValue) => {
              setApplicationForm(nextValue);
              setApplicationFormErrors(validateBookingApplicationForm(nextValue));
            }}
            errors={applicationFormErrors}
            disabled={updatingApplicationForm || uploadingApplicantPhoto}
          />
        </form>
      </Modal>
    </div>
  );
}
