import { useState, useEffect, useMemo, useCallback } from 'react';
import api from '@/lib/api';
import toast from 'react-hot-toast';

interface UseClientPaginationOptions {
  endpoint: string;
  itemsPerPage?: number;
  filters?: any[];
  searchFields?: string[];
  searchQuery?: string;
  defaultSortField?: string;
  defaultSortOrder?: 'asc' | 'desc';
}

export function useClientPagination<T = any>({
  endpoint,
  itemsPerPage = 10,
  filters = [],
  searchFields = ['name.en'],
  searchQuery = '',
  defaultSortField = 'createdAt',
  defaultSortOrder = 'desc'
}: UseClientPaginationOptions) {
  const [allData, setAllData] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentPageIndex, setCurrentPageIndex] = useState(0);
  const [refetchTrigger, setRefetchTrigger] = useState(0);

  // Debounce search
  const [debouncedSearch, setDebouncedSearch] = useState(searchQuery);
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedSearch(searchQuery);
      setCurrentPageIndex(0);
    }, 300);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  const fetchAll = useCallback(async () => {
    try {
      setLoading(true);
      const res = await api.get(endpoint, {
        filters,
        sortField: defaultSortField,
        sortOrder: defaultSortOrder
      });
      setAllData(res.data.data || []);
      setCurrentPageIndex(0);
    } catch (error: any) {
      console.error(`Failed to fetch ${endpoint}`, error);
      toast.error(error?.message || `Failed to load data`);
    } finally {
      setLoading(false);
    }
  }, [endpoint, JSON.stringify(filters), defaultSortField, defaultSortOrder, refetchTrigger]);

  useEffect(() => {
    fetchAll();
  }, [fetchAll]);

  const getNestedValue = (obj: any, path: string) => {
    return path.split('.').reduce((acc, part) => acc && acc[part], obj);
  };

  const filteredData = useMemo(() => {
    if (!debouncedSearch) return allData;
    
    const lowerSearch = debouncedSearch.toLowerCase();
    return allData.filter(item => {
      return searchFields.some(field => {
        const val = getNestedValue(item, field);
        if (typeof val === 'string') {
          return val.toLowerCase().includes(lowerSearch);
        }
        return false;
      });
    });
  }, [allData, debouncedSearch, searchFields]);

  const totalPages = Math.ceil(filteredData.length / itemsPerPage);
  const paginatedData = useMemo(() => {
    const startIndex = currentPageIndex * itemsPerPage;
    return filteredData.slice(startIndex, startIndex + itemsPerPage);
  }, [filteredData, currentPageIndex, itemsPerPage]);

  const hasNextPage = currentPageIndex < totalPages - 1;
  const hasPrevPage = currentPageIndex > 0;

  const handleNextPage = () => {
    if (hasNextPage) setCurrentPageIndex(prev => prev + 1);
  };

  const handlePrevPage = () => {
    if (hasPrevPage) setCurrentPageIndex(prev => prev - 1);
  };

  const refreshCurrentPage = () => {
    setRefetchTrigger(prev => prev + 1);
  };

  const updateItem = (id: string, updatedItem: Partial<T>) => {
    setAllData(prev => prev.map((item: any) => item.id === id ? { ...item, ...updatedItem } : item));
  };

  const removeItem = (id: string) => {
    setAllData(prev => prev.filter((item: any) => item.id !== id));
  };

  return {
    data: paginatedData,
    updateItem,
    removeItem,
    loading,
    hasNextPage,
    hasPrevPage,
    handleNextPage,
    handlePrevPage,
    refreshCurrentPage
  };
}
