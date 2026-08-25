import { useState, useEffect } from "react";
import api from "@/lib/api";
import { Modal } from "@/components/ui/Modal";
import { Search, Loader2 } from "lucide-react";
import { toast } from "react-hot-toast";

interface AssignPlotDialogProps {
  isOpen: boolean;
  onClose: () => void;
  plot: any;
  onAssigned: (plotId: string, assignedUserId: string) => void;
}

export function AssignPlotDialog({ isOpen, onClose, plot, onAssigned }: AssignPlotDialogProps) {
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [assigning, setAssigning] = useState(false);

  useEffect(() => {
    if (isOpen) {
      fetchUsers();
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

  const handleAssign = async (user: any) => {
    setAssigning(true);
    try {
      // Create a booking record
      const bookingData = {
        customerId: user.id || "",
        mobileNumber: user.mobileNumber || "",
        projectId: plot.projectId || "",
        plotId: plot.id || "",
        totalAmount: 0,
        paidAmount: 0,
      };

      await api.post("/bookings", bookingData);

      // Update plot status
      await api.put(`/plots/${plot.id}`, {
        status: "BOOKED_SOLD",
        assignedUserId: user.id
      });

      toast.success(`Plot assigned to ${user.fullName}`);
      onAssigned(plot.id, user.id);
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
      title={`Assign Plot ${plot?.plotNumber} to User`}
      maxWidth="md"
    >
      <div className="flex flex-col h-[500px]">
        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
          <input
            type="text"
            placeholder="Search by name or mobile..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div className="flex-1 overflow-y-auto pr-2 space-y-2">
          {loading ? (
            <div className="flex items-center justify-center h-full">
              <Loader2 className="h-6 w-6 animate-spin text-blue-500" />
            </div>
          ) : filteredUsers.length === 0 ? (
            <div className="flex items-center justify-center h-full text-sm text-slate-500">
              No users found.
            </div>
          ) : (
            filteredUsers.map((user) => (
              <div
                key={user.id}
                className="flex items-center justify-between p-3 border border-slate-100 rounded-lg hover:border-blue-200 hover:bg-blue-50 transition-colors"
              >
                <div>
                  <p className="font-semibold text-sm text-slate-800">{user.fullName || 'Unknown'}</p>
                  <p className="text-xs text-slate-500">{user.mobileNumber || user.email}</p>
                </div>
                <button
                  disabled={assigning}
                  onClick={() => handleAssign(user)}
                  className="px-3 py-1.5 text-xs font-semibold text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                >
                  Assign
                </button>
              </div>
            ))
          )}
        </div>
      </div>
    </Modal>
  );
}
