import React from "react";

export const ShimmerBlock = ({ className = "" }: { className?: string }) => (
  <div className={`animate-pulse bg-slate-200 rounded-lg ${className}`}></div>
);

export const ShimmerCard = () => (
  <div className="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm w-full">
    <ShimmerBlock className="h-6 w-1/3 mb-6" />
    <ShimmerBlock className="h-4 w-full mb-3" />
    <ShimmerBlock className="h-4 w-2/3 mb-3" />
    <ShimmerBlock className="h-4 w-5/6 mb-6" />
    <div className="flex justify-end">
      <ShimmerBlock className="h-10 w-24 rounded-xl" />
    </div>
  </div>
);

export const ShimmerTable = ({ rows = 5 }: { rows?: number }) => (
  <div className="w-full bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
    <div className="bg-slate-50 border-b border-slate-100 px-6 py-4 flex space-x-4">
      <ShimmerBlock className="h-4 w-1/4" />
      <ShimmerBlock className="h-4 w-1/4" />
      <ShimmerBlock className="h-4 w-1/4" />
      <ShimmerBlock className="h-4 w-1/4" />
    </div>
    <div className="divide-y divide-slate-100">
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="px-6 py-5 flex space-x-4">
          <ShimmerBlock className="h-4 w-1/4" />
          <ShimmerBlock className="h-4 w-1/4" />
          <ShimmerBlock className="h-4 w-1/4" />
          <ShimmerBlock className="h-4 w-1/4" />
        </div>
      ))}
    </div>
  </div>
);
