"use client";

import { useState, useEffect } from "react";
import { updateDoc, collection, setDoc, doc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import api from "@/lib/api";
import { PageHeader } from "@/components/ui/PageHeader";
import { Bookmark, User, CreditCard, DollarSign, Calendar } from "lucide-react";
import { toast } from "react-hot-toast";
import { formatCurrency, formatDateTime } from "@/lib/formatters";
import { Modal } from "@/components/ui/Modal";
import { Button } from "@/components/ui/Button";
import { useParams } from "next/navigation";

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

  useEffect(() => {
    if (params?.id) {
      loadBooking();
    }
  }, [params?.id]);

  async function loadBooking() {
    try {
      const [res, paymentsRes] = await Promise.all([
        api.get(`/bookings/${params.id}`),
        api.get(`/payments`, { filters: [{ field: "bookingId", operator: "==", value: params.id }] })
      ]);

      if (res.data.success) {
        setBooking(res.data.data);
      } else {
        toast.error("Booking not found");
      }

      if (paymentsRes.data.success) {
        setPayments(paymentsRes.data.data);
      }
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
      // 1. Add payment record
      const paymentRef = doc(collection(db, "payments"));
      await setDoc(paymentRef, {
        id: paymentRef.id,
        bookingId: booking.id,
        customerId: booking.customerId,
        amount: amount,
        mode: paymentMode,
        transactionId: paymentMode !== "CASH" ? transactionId.trim() : null,
        notes: paymentNotes,
        status: "COMPLETED",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });

      // 2. Update booking paid amount
      const newPaidAmount = (booking.paidAmount || 0) + amount;
      await updateDoc(doc(db, "assignPlots", booking.id), {
        paidAmount: newPaidAmount,
        updatedAt: new Date().toISOString()
      });

      setBooking({ ...booking, paidAmount: newPaidAmount });
      // 3. Close and reset
      toast.success("Payment logged successfully");
      setIsPaymentModalOpen(false);
      setPaymentAmount("");
      setTransactionId("");
      setPaymentNotes("");
      loadBooking(); // Reload booking and payments
    } catch (error: any) {
      setLoggingPayment(false);
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
        <h2 className="text-xl font-semibold text-slate-800">Booking not found</h2>
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
          { label: `Plot ${booking.plotNumber || 'N/A'}` }
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
              <h2 className="text-2xl font-bold text-slate-900">{booking.projectName}</h2>
              <p className="text-slate-500 font-medium">Plot {booking.plotNumber}</p>
            </div>
          </div>
          <div className={`px-4 py-2 rounded-full text-sm font-bold ${booking.status === 'SOLD' ? 'bg-green-100 text-green-700' : 'bg-blue-100 text-blue-700'
            }`}>
            {booking.status}
          </div>
        </div>

        {/* Customer Info */}
        <div className="col-span-1 bg-white p-6 rounded-2xl shadow-sm border border-slate-100">
          <h3 className="text-lg font-semibold text-slate-900 mb-4 border-b border-slate-100 pb-2 flex items-center gap-2">
            <User className="h-5 w-5 text-slate-400" />
            Customer Details
          </h3>
          <div className="space-y-4">
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Name</p>
              <p className="text-base font-bold text-slate-900 mt-1">{booking.customerName || 'N/A'}</p>
            </div>
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Mobile Number</p>
              <p className="text-base font-bold text-slate-900 mt-1">{booking.mobileNumber || 'N/A'}</p>
            </div>
            <div>
              <p className="text-xs font-semibold text-slate-500 uppercase">Booking Date</p>
              <p className="text-sm font-bold text-slate-900 mt-1">
                {booking.createdAt ? formatDateTime(booking.createdAt) : 'N/A'}
              </p>
            </div>
          </div>
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
              <p className="text-xs font-semibold text-slate-500 uppercase">Total Amount</p>
              <p className="text-xl font-bold text-slate-900 mt-1">{formatCurrency(booking.totalAmount || 0)}</p>
            </div>
            <div className="p-4 bg-green-50 rounded-xl border border-green-100">
              <p className="text-xs font-semibold text-green-600 uppercase">Paid Amount</p>
              <p className="text-xl font-bold text-green-700 mt-1">{formatCurrency(booking.paidAmount || 0)}</p>
            </div>
            <div className={`p-4 rounded-xl border ${balance > 0 ? 'bg-red-50 border-red-100' : 'bg-slate-50 border-slate-100'}`}>
              <p className={`text-xs font-semibold uppercase ${balance > 0 ? 'text-red-600' : 'text-slate-500'}`}>Pending Balance</p>
              <p className={`text-xl font-bold mt-1 ${balance > 0 ? 'text-red-700' : 'text-slate-900'}`}>{formatCurrency(balance)}</p>
            </div>
          </div>

          <h4 className="text-sm font-semibold text-slate-900 mb-3">Recent Payments (Ledger)</h4>
          {payments.length === 0 ? (
            <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 text-center text-sm text-slate-500">
              No payments logged yet.
            </div>
          ) : (
            <div className="space-y-3">
              {payments.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()).map(payment => (
                <div key={payment.id} className="flex justify-between items-center p-3 rounded-lg border border-slate-100 bg-white">
                  <div>
                    <p className="font-semibold text-sm text-slate-900">{formatCurrency(payment.amount)}</p>
                    <p className="text-xs text-slate-500 mt-0.5">
                      {payment.mode}
                      {payment.transactionId && ` (Txn: ${payment.transactionId})`}
                      {payment.notes && ` - ${payment.notes}`}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-xs font-medium text-slate-900">{formatDateTime(payment.createdAt)}</p>
                    <span className="text-[10px] font-bold text-green-700 bg-green-100 px-2 py-0.5 rounded-full mt-1 inline-block">COMPLETED</span>
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
            <Button variant="secondary" onClick={() => setIsPaymentModalOpen(false)}>
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
            <label className="block text-sm font-medium text-slate-700 mb-1">Amount (₹)</label>
            <input
              type="number"
              value={paymentAmount}
              onChange={(e) => setPaymentAmount(e.target.value)}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="e.g. 50000"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Payment Mode</label>
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
              <label className="block text-sm font-medium text-slate-700 mb-1">Transaction ID / UTR</label>
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
            <label className="block text-sm font-medium text-slate-700 mb-1">Notes</label>
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
    </div>
  );
}
