import { useState, useEffect, useCallback } from "react";
import api from "@/lib/api";
import toast from "react-hot-toast";

interface UseServerPaginationOptions {
  endpoint: string;
  itemsPerPage?: number;
  filters?: { field: string; operator: any; value: any }[];
  searchField?: string;
  searchQuery?: string;
  defaultSortField?: string;
  capitalizeSearch?: boolean;
}

export function useServerPagination<T = any>({
  endpoint,
  itemsPerPage = 10,
  filters = [],
  searchField = "name",
  searchQuery = "",
  defaultSortField = "createdAt",
  capitalizeSearch = false,
}: UseServerPaginationOptions) {
  const [data, setData] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);

  // Debounce search
  const [debouncedSearch, setDebouncedSearch] = useState(searchQuery);
  useEffect(() => {
    const handler = setTimeout(() => setDebouncedSearch(searchQuery), 500);
    return () => clearTimeout(handler);
  }, [searchQuery]);

  // Pagination State
  const [pageHistory, setPageHistory] = useState<any[]>([undefined]); // index 0 is undefined
  const [currentPageIndex, setCurrentPageIndex] = useState(0);
  const [hasNextPage, setHasNextPage] = useState(false);

  const fetchData = useCallback(
    async (pageIndex: number, resetHistory = false) => {
      try {
        setLoading(true);

        const currentFilters = [...filters];

        if (debouncedSearch && searchField) {
          let formattedSearch = debouncedSearch;
          if (capitalizeSearch) {
            // Capitalize the first letter of each word
            formattedSearch = debouncedSearch.replace(/\b\w/g, (c) =>
              c.toUpperCase(),
            );
          }

          currentFilters.push({
            field: searchField,
            operator: ">=",
            value: formattedSearch,
          });
          currentFilters.push({
            field: searchField,
            operator: "<=",
            value: formattedSearch + "\uf8ff",
          });
        }

        const res = await api.get(endpoint, {
          limitCount: itemsPerPage,
          startAfterDoc: resetHistory ? undefined : pageHistory[pageIndex],
          filters: currentFilters,
          sortField: debouncedSearch
            ? searchField
            : currentFilters.length === 1 && currentFilters[0].operator === "=="
              ? currentFilters[0].field
              : currentFilters.length > 0
                ? undefined
                : defaultSortField,
          sortOrder: debouncedSearch ? "asc" : "desc",
        });

        setData(res.data.data || []);
        setHasNextPage(res.data.data.length === itemsPerPage);

        if (resetHistory) {
          setPageHistory([undefined, res.data.lastDoc]);
          setCurrentPageIndex(0);
        } else if (res.data.lastDoc) {
          setPageHistory((prev) => {
            const newHistory = [...prev];
            newHistory[pageIndex + 1] = res.data.lastDoc;
            return newHistory;
          });
        }
      } catch (error: any) {
        console.error(`Failed to fetch ${endpoint}`, error);
        toast.error(error?.message || `Failed to load data`, {
          duration: 6000,
        });
      } finally {
        setLoading(false);
      }
      // eslint-disable-next-line react-hooks/exhaustive-deps
    },
    [
      endpoint,
      itemsPerPage,
      searchField,
      debouncedSearch,
      defaultSortField,
      JSON.stringify(filters),
      pageHistory,
    ],
  );

  // Fetch when filters or search change
  useEffect(() => {
    fetchData(0, true);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debouncedSearch, JSON.stringify(filters)]);

  const handleNextPage = () => {
    if (hasNextPage) {
      const nextIndex = currentPageIndex + 1;
      setCurrentPageIndex(nextIndex);
      fetchData(nextIndex, false);
    }
  };

  const handlePrevPage = () => {
    if (currentPageIndex > 0) {
      const prevIndex = currentPageIndex - 1;
      setCurrentPageIndex(prevIndex);
      fetchData(prevIndex, false);
    }
  };

  const refreshCurrentPage = () => {
    fetchData(currentPageIndex, false);
  };

  return {
    data,
    setData,
    loading,
    hasNextPage,
    hasPrevPage: currentPageIndex > 0,
    handleNextPage,
    handlePrevPage,
    refreshCurrentPage,
  };
}
