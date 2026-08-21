/* eslint-disable react-hooks/immutability */
"use client";

import { useAuth } from "@/context/AuthContext";
import {
  LayoutDashboard, Building2, Map, Tag, PhoneIncoming, CalendarCheck,
  CreditCard, Users, Settings, LogOut, Menu, X, FileText, HelpCircle
} from "lucide-react";
import Link from "next/link";
import { useRouter, usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";

const navItems = [
  { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { name: "Projects", href: "/projects", icon: Building2 },
  { name: "Plots", href: "/plots", icon: Map },
  { name: "Offers", href: "/offers", icon: Tag },
  { name: "Enquiries", href: "/enquiries", icon: PhoneIncoming },
  { name: "Site Visits", href: "/site-visits", icon: CalendarCheck },
  { name: "Transactions", href: "/transactions", icon: CreditCard },

  { name: "FAQs", href: "/faq", icon: HelpCircle },
  { name: "Settings", href: "/settings", icon: Settings },
];

import NotificationBell from "@/components/NotificationBell";
import { useLanguage } from '@/context/LanguageContext';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { t } = useLanguage();
  const { user, logout, isAuthenticated, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.push("/login");
    }
  }, [isAuthenticated, loading, router]);

  if (loading || !isAuthenticated) {
    return null; // Wait for auth check before rendering anything
  }

  return (
    <div className="h-screen overflow-hidden bg-[#F8FAFC] flex">
      {/* Mobile Sidebar Overlay */}
      {isSidebarOpen && (
        <div
          className="fixed inset-0 z-40 bg-gray-900/60 backdrop-blur-sm lg:hidden transition-opacity"
          onClick={() => setIsSidebarOpen(false)}
        />
      )}

      {/* Premium Dark Sidebar */}
      <aside className={`
        fixed inset-y-0 left-0 z-50 w-72 bg-slate-900 border-r border-slate-800 transform transition-all duration-300 ease-in-out lg:translate-x-0 lg:static lg:flex-shrink-0 shadow-2xl
        ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
        <div className="h-20 flex items-center justify-center px-6 border-b border-white/5 bg-slate-900/50 backdrop-blur-xl">
          <img src="/logo_with_text.png" alt="SHUBHAYTANAM CONNECT" className="max-h-12 w-auto object-contain" />
        </div>

        <nav className="p-4 space-y-1.5 h-[calc(100vh-5rem)] overflow-y-auto scrollbar-hide">
          <div className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-4 mt-2 px-3">
            Overview
          </div>
          {navItems.map((item) => {
            const isActive = pathname.startsWith(item.href);
            const Icon = item.icon;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`
                  flex items-center px-4 py-3 text-sm font-medium rounded-xl group transition-all duration-200
                  ${isActive
                    ? 'bg-blue-600/10 text-blue-400 shadow-[inset_2px_0_0_0_#3b82f6]'
                    : 'text-slate-400 hover:bg-slate-800/50 hover:text-slate-200'}
                `}
                onClick={() => setIsSidebarOpen(false)}
              >
                <Icon className={`mr-3 h-5 w-5 flex-shrink-0 transition-colors duration-200 ${isActive ? 'text-blue-400' : 'text-slate-500 group-hover:text-slate-300'}`} />
                {item.name}
              </Link>
            );
          })}
        </nav>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden bg-slate-50">
        {/* Glassmorphism Header */}
        <header className="h-20 sticky top-0 z-30 bg-white/70 backdrop-blur-xl border-b border-slate-200/50 flex items-center justify-between px-4 sm:px-6 lg:px-8 shadow-sm">
          <button
            onClick={() => setIsSidebarOpen(true)}
            className="lg:hidden p-2 rounded-lg text-slate-500 hover:text-slate-700 hover:bg-slate-100 transition-colors"
          >
            <Menu className="h-6 w-6" />
          </button>

          <div className="flex-1" />

          <div className="flex items-center space-x-6">
            <NotificationBell />
            <div className="h-8 w-px bg-slate-200"></div>
            <div className="flex items-center gap-4 cursor-pointer hover:opacity-80 transition-opacity">
              <div className="hidden sm:flex flex-col items-end">
                <span className="text-sm font-semibold text-slate-900">{user?.name || 'Admin'}</span>
                <span className="text-xs font-medium text-slate-500">{user?.role || 'Administrator'}</span>
              </div>
              <div className="h-10 w-10 rounded-full bg-gradient-to-br from-blue-100 to-indigo-100 border border-blue-200 flex items-center justify-center text-blue-700 font-bold shadow-sm">
                {user?.name?.charAt(0) || 'A'}
              </div>
            </div>
            <button
              onClick={logout}
              className="p-2.5 text-slate-400 hover:text-red-500 rounded-full hover:bg-red-50 transition-all duration-200"
              title="Logout"
            >
              <LogOut className="h-5 w-5" />
            </button>
          </div>
        </header>

        {/* Main Body */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-5 relative">
          <AnimatePresence mode="wait">
            <motion.div
              key={pathname}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.3 }}
              className="h-full"
            >
              {children}
            </motion.div>
          </AnimatePresence>
        </main>
      </div>
    </div>
  );
}
