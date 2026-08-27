import { useState, useEffect, type FormEvent } from "react";
import api, { createBookingIfPlotAvailable } from "@/lib/api";
import { Modal } from "@/components/ui/Modal";
import { Search, Loader2 } from "lucide-react";
import { toast } from "react-hot-toast";
import { Button } from "@/components/ui/Button";
import {
  BookingApplicationForm,
  BookingApplicationFormData,
  emptyBookingApplicationForm,
  validateBookingApplicationForm,
  BookingApplicationFormErrors,
} from "@/components/BookingApplicationForm";

interface AssignPlotDialogProps {
  isOpen: boolean;
  onClose: () => void;
  plot: any;
  onAssigned: (
    plotId: string,
    assignedUserId: string,
    assignedUserName?: string,
  ) => void;
}

export function AssignPlotDialog({ isOpen, onClose, plot, onAssigned }: AssignPlotDialogProps) {
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [assigning, setAssigning] = useState(false);
  const [selectedUser, setSelectedUser] = useState<any>(null);
  const [applicationForm, setApplicationForm] = useState<BookingApplicationFormData>(emptyBookingApplicationForm);
  const [formErrors, setFormErrors] = useState<BookingApplicationFormErrors>({});

  useEffect(() => {
    if (isOpen) {
      fetchUsers();
      setSelectedUser(null);
      setApplicationForm(emptyBookingApplicationForm);
      setFormErrors({});
    }
  }, [isOpen]);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      // In a real app we might paginate or search via server, but since this is an MVP we can fetch a chunk
      const res = await api.get("/users", { limitCount: 100 });
      if (res.data.success) {
        setUsers(res.data.data);
      }
    } catch (e) {
      console.error(e);
      toast.error("Failed to load users");
    } finally {
      setLoading(false);
    }
  };

  const handleSelectUser = (user: any) => {
    setSelectedUser(user);
    setFormErrors({});
    setApplicationForm({
      ...emptyBookingApplicationForm,
      firstApplicantName: user.fullName || "",
      firstApplicantMobile: user.mobileNumber || "",
      firstApplicantEmail: user.email || "",
    });
  };

  const handleAssign = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!selectedUser) {
      toast.error("Please select a customer first");
      return;
    }
    const errors = validateBookingApplicationForm(applicationForm);
    setFormErrors(errors);
    if (Object.keys(errors).length > 0) {
      toast.error("Please fix the validation errors in the form");
      return;
    }

    setAssigning(true);
    try {
      const bookingData = {
        customerId: selectedUser.id || "",
        mobileNumber: applicationForm.firstApplicantMobile.trim(),
        projectId: plot.projectId || "",
        plotId: plot.id || "",
        totalAmount: Number(applicationForm.totalAmount) || 0,
        paidAmount: Number(applicationForm.initialPayment) || 0,
        applicationForm,
      };

      const initialPayment = Number(applicationForm.initialPayment) || 0;
      await createBookingIfPlotAvailable(
        plot.id,
        bookingData,
        initialPayment > 0
          ? {
            customerId: selectedUser.id || "",
            amount: initialPayment,
            mode: applicationForm.paymentMode,
            transactionId: applicationForm.paymentMode === "CASH" ? null : applicationForm.paymentReference.trim(),
            bankName: applicationForm.bankName.trim(),
            paymentType: "BOOKING_INITIAL",
            notes:
              applicationForm.notes.trim() ||
              "Initial payment from booking application",
            status: "COMPLETED",
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
          }
          : undefined,
      );

      toast.success(`Plot assigned to ${applicationForm.firstApplicantName}`);
      onAssigned(plot.id, selectedUser.id, selectedUser.fullName || selectedUser.name);
      onClose();
    } catch (e: any) {
      console.error(e);
      toast.error(e.response?.data?.message || "Failed to assign plot");
    } finally {
      setAssigning(false);
    }
  };

  const filteredUsers = users.filter((u) => {
    const s = searchQuery.toLowerCase();
    return (
      (u.fullName || "").toLowerCase().includes(s) ||
      (u.mobileNumber || "").toLowerCase().includes(s)
    );
  });

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={`Plot ${plot?.plotNumber} Booking Application`}
      fullScreen
    >
      <form onSubmit={handleAssign} className="flex min-h-0 flex-1 flex-col bg-slate-50">
        <div className="border-b border-slate-200 bg-white px-6 py-4 sm:px-10">
          <div className="mx-auto flex max-w-6xl flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
            <div>
              <p className="text-xs font-semibold uppercase tracking-wide text-slate-500">Assign Customer</p>
              <p className="text-sm text-slate-600">Choose a customer, complete the application, then assign the plot.</p>
            </div>
            <div className="relative w-full lg:max-w-sm">
              <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
              <input
                type="text"
                placeholder="Search by name or mobile..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full rounded-lg border border-slate-200 bg-slate-50 py-2 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          <div className="mx-auto mt-3 flex max-w-6xl gap-2 overflow-x-auto pb-1">
            {loading ? (
              <div className="flex items-center justify-center py-3">
                <Loader2 className="h-6 w-6 animate-spin text-blue-500" />
              </div>
            ) : filteredUsers.length === 0 ? (
              <div className="py-3 text-sm text-slate-500">
                No users found.
              </div>
            ) : (
              filteredUsers.map((user) => (
                <div
                  key={user.id}
                  className={`flex min-w-[220px] items-center justify-between rounded-lg border p-3 transition-colors ${selectedUser?.id === user.id ? "border-blue-400 bg-blue-50" : "border-slate-100 bg-white hover:border-blue-200 hover:bg-blue-50"}`}
                >
                  <div>
                    <p className="font-semibold text-sm text-slate-800">{user.fullName || 'Unknown'}</p>
                    <p className="text-xs text-slate-500">{user.mobileNumber || user.email}</p>
                  </div>
                  <button
                    disabled={assigning}
                    type="button"
                    onClick={() => handleSelectUser(user)}
                    className="rounded-lg bg-blue-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-blue-700 disabled:opacity-50"
                  >
                    Select
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
        <div className="min-h-0 flex-1 overflow-y-auto px-6 py-6 sm:px-10">
          <div className="mx-auto max-w-6xl">
            <div className="mb-5 flex items-center justify-between rounded-lg border border-blue-100 bg-blue-50 px-4 py-3">
              <div>
                <p className="text-xs font-semibold uppercase text-blue-600">Selected Customer</p>
                <p className="font-semibold text-slate-900">{selectedUser?.fullName || "Select a customer above"}</p>
              </div>
              {selectedUser && <button type="button" onClick={() => setSelectedUser(null)} className="text-sm font-semibold text-blue-700 hover:text-blue-900">Change</button>}
            </div>
            <BookingApplicationForm value={applicationForm} onChange={(nextValue) => { setApplicationForm(nextValue); setFormErrors(validateBookingApplicationForm(nextValue)); }} errors={formErrors} disabled={assigning || !selectedUser} />
          </div>
        </div>
        <div className="border-t border-slate-200 bg-white px-6 py-4 sm:px-10">
          <div className="mx-auto flex max-w-6xl justify-end gap-3">
            <Button type="button" variant="secondary" onClick={onClose}>Cancel</Button>
            <Button
              type="submit"
              isLoading={assigning}
              disabled={!selectedUser || Object.keys(formErrors).length > 0}
            >
              Assign Plot & Create Booking
            </Button>
          </div>
        </div>
      </form>
    </Modal>
  );
}
