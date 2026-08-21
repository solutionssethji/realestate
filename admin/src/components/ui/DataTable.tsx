import React, { useState } from "react";
import { Loader2, ChevronLeft, ChevronRight } from "lucide-react";
import { motion } from "framer-motion";

interface DataTableProps {
  columns: { header: string; key: string; render?: (item: any) => React.ReactNode }[];
  data: any[];
  isLoading?: boolean;
  emptyState?: React.ReactNode;
  itemsPerPage?: number;
  // New props for Server-Side Pagination
  isServerSide?: boolean;
  onNextPage?: () => void;
  onPrevPage?: () => void;
  hasNextPage?: boolean;
  hasPrevPage?: boolean;
}

export const DataTable = ({
  columns,
  data,
  isLoading,
  emptyState,
  itemsPerPage = 10,
  isServerSide = false,
  onNextPage,
  onPrevPage,
  hasNextPage = false,
  hasPrevPage = false
}: DataTableProps) => {
  const [clientPage, setClientPage] = useState(1);

  if (isLoading) {
    return (
      <div className="w-full h-64 flex items-center justify-center bg-white rounded-2xl border border-slate-100 shadow-sm">
        <Loader2 className="h-8 w-8 text-blue-500 animate-spin" />
      </div>
    );
  }

  if (!data || data.length === 0) {
    return (
      <div className="w-full bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        {emptyState || (
          <div className="p-8 text-center text-slate-500">
            No records found.
          </div>
        )}
      </div>
    );
  }

  let paginatedData = data;
  let showPagination = false;

  if (isServerSide) {
    showPagination = hasNextPage || hasPrevPage;
  } else {
    const totalPages = Math.ceil(data.length / itemsPerPage);
    const currentPage = Math.min(clientPage, Math.max(1, totalPages));
    const startIndex = (currentPage - 1) * itemsPerPage;
    paginatedData = data.slice(startIndex, startIndex + itemsPerPage);
    showPagination = totalPages > 1;
  }

  return (
    <div className="w-full bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden flex flex-col">
      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm text-slate-600">
          <thead className="text-xs text-slate-500 uppercase bg-slate-50/80 border-b border-slate-100">
            <tr>
              {columns.map((col, idx) => (
                <th key={idx} scope="col" className="px-6 py-4 font-semibold tracking-wider">
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <motion.tbody
            className="divide-y divide-slate-100"
            initial="hidden"
            animate="visible"
            variants={{
              visible: {
                transition: {
                  staggerChildren: 0.05
                }
              }
            }}
          >
            {paginatedData.map((item, rowIndex) => (
              <motion.tr
                key={item.id || rowIndex}
                className="hover:bg-slate-50/80 transition-colors duration-150"
                variants={{
                  hidden: { opacity: 0, y: 10 },
                  visible: { opacity: 1, y: 0 }
                }}
              >
                {columns.map((col, colIndex) => (
                  <td key={colIndex} className="px-6 py-4 whitespace-nowrap">
                    {col.render ? col.render(item) : item[col.key]}
                  </td>
                ))}
              </motion.tr>
            ))}
          </motion.tbody>
        </table>
      </div>

      {showPagination && (
        <div className="flex items-center justify-between px-6 py-4 border-t border-slate-100 bg-slate-50/50">
          <div className="text-sm text-slate-500">
            {isServerSide ? (
              <span>Showing results for current page</span>
            ) : (
              <span>
                Showing <span className="font-medium text-slate-900">{((clientPage - 1) * itemsPerPage) + 1}</span> to <span className="font-medium text-slate-900">{Math.min(clientPage * itemsPerPage, data.length)}</span> of <span className="font-medium text-slate-900">{data.length}</span> results
              </span>
            )}
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => {
                if (isServerSide && onPrevPage) {
                  onPrevPage();
                } else {
                  setClientPage(p => Math.max(1, p - 1));
                }
              }}
              disabled={isServerSide ? !hasPrevPage : clientPage === 1}
              className="p-2 rounded-lg border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronLeft className="h-4 w-4" />
            </button>

            {!isServerSide && (
              <div className="text-sm font-medium text-slate-700 px-2">
                Page {clientPage} of {Math.ceil(data.length / itemsPerPage)}
              </div>
            )}

            <button
              onClick={() => {
                if (isServerSide && onNextPage) {
                  onNextPage();
                } else {
                  setClientPage(p => Math.min(Math.ceil(data.length / itemsPerPage), p + 1));
                }
              }}
              disabled={isServerSide ? !hasNextPage : clientPage === Math.ceil(data.length / itemsPerPage)}
              className="p-2 rounded-lg border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
