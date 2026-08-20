import React from "react";
import { Loader2 } from "lucide-react";

export const StatusBadge = ({ status, className = "" }: { status: string; className?: string }) => {
  const normalized = status.toUpperCase().trim();

  let colorClass = "bg-slate-100 text-slate-700 border-slate-200"; // Default

  // Status Colors
  if (['ACTIVE', 'AVAILABLE', 'SUCCESS', 'COMPLETED', 'RESOLVED', 'CLOSED', 'CONFIRMED'].includes(normalized)) {
    colorClass = "bg-emerald-50 text-emerald-700 border-emerald-200";
  } else if (['PENDING', 'HOLD', 'IN_PROGRESS', 'DRAFT', 'FOLLOW_UP', 'ONGOING', 'CONTACTED'].includes(normalized)) {
    colorClass = "bg-amber-50 text-amber-700 border-amber-200";
  } else if (['INACTIVE', 'BOOKED', 'SOLD', 'BOOKED_SOLD', 'CANCELLED', 'FAILED', 'REJECTED'].includes(normalized)) {
    colorClass = "bg-red-50 text-red-700 border-red-200";
  } else if (['NEW', 'UPCOMING', 'UNREAD'].includes(normalized)) {
    colorClass = "bg-blue-50 text-blue-700 border-blue-200";
  }

  return (
    <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold border ${colorClass} ${className}`}>
      {status.replace(/_/g, ' ')}
    </span>
  );
};
