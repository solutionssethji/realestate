/* eslint-disable react-hooks/immutability */
"use client";

import { useAuth } from "@/context/AuthContext";
import {
  LayoutDashboard, Building2, Map, Tag, PhoneIncoming, CalendarCheck,
  CreditCard, Users, Settings, LogOut, Menu, X, FileText, HelpCircle, Bookmark, Briefcase, User as UserIcon, Lock, Bell
} from "lucide-react";
import Link from "next/link";
import { useRouter, usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Modal } from "@/components/ui/Modal";

const getNavItems = (role?: string) => {
  if (role === 'AGENT') {
    return [
      { name: "Projects", href: "/projects", icon: Building2 },
      { name: "Plots", href: "/plots", icon: Map },
      { name: "Offers", href: "/offers", icon: Tag },
      { name: "Profile", href: "/profile", icon: UserIcon },
      { name: "Change Password", href: "/change-password", icon: Lock },
    ];
  }

  return [
    { name: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
    { name: "Projects", href: "/projects", icon: Building2 },
    { name: "Plots", href: "/plots", icon: Map },
    { name: "Offers", href: "/offers", icon: Tag },
    { name: "Bookings", href: "/bookings", icon: Bookmark },
    { name: "Agents", href: "/agents", icon: Briefcase },
    { name: "Enquiries", href: "/enquiries", icon: PhoneIncoming },
    { name: "Site Visits", href: "/site-visits", icon: CalendarCheck },
    { name: "Transactions", href: "/transactions", icon: CreditCard },
    { name: "Users", href: "/users", icon: Users },
    { name: "Notifications", href: "/notifications", icon: Bell },
    { name: "FAQs", href: "/faq", icon: HelpCircle },
    { name: "Settings", href: "/settings", icon: Settings },
    { name: "Profile", href: "/profile", icon: UserIcon },
  ];
};

import NotificationBell from "@/components/NotificationBell";
import { useLanguage } from '@/context/LanguageContext';

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { t } = useLanguage();
  const { user, logout, isAuthenticated, loading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [showLogoutModal, setShowLogoutModal] = useState(false);

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

      {/* Premium Light Sidebar */}
      <aside className={`
        fixed inset-y-0 left-0 z-50 w-72 bg-white border-r border-slate-200 transform transition-all duration-300 ease-in-out lg:translate-x-0 lg:static lg:flex-shrink-0 shadow-xl
        ${isSidebarOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
        <div className="h-28 flex items-center justify-center px-2 py-4 border-b border-slate-100 bg-white/80 backdrop-blur-xl">
          <img src="/logo_with_text.png" alt="SHUBHAYTANAM CONNECT" className="max-h-24 w-full object-contain" />
        </div>

        <nav className="p-4 space-y-1.5 h-[calc(100vh-7rem)] overflow-y-auto scrollbar-hide">
          <div className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-4 mt-2 px-3">
            Overview
          </div>
          {getNavItems(user?.role).map((item) => {
            const isActive = pathname.startsWith(item.href);
            const Icon = item.icon;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`
                  flex items-center px-4 py-3 text-sm font-medium rounded-xl group transition-all duration-200
                  ${isActive
                    ? 'bg-blue-50 text-blue-700 shadow-[inset_3px_0_0_0_#3b82f6]'
                    : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}
                `}
                onClick={() => setIsSidebarOpen(false)}
              >
                <Icon className={`mr-3 h-5 w-5 flex-shrink-0 transition-colors duration-200 ${isActive ? 'text-blue-700' : 'text-slate-400 group-hover:text-slate-600'}`} />
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
            {user?.role === "ADMIN" && <NotificationBell />}
            <div className="h-8 w-px bg-slate-200"></div>
            <div className="flex items-center gap-4 cursor-pointer hover:opacity-80 transition-opacity">
              <div className="hidden sm:flex flex-col items-end">
                <span className="text-sm font-semibold text-slate-900">{user?.name || 'Admin'}</span>
                <span className="text-xs font-medium text-slate-500">{user?.role || 'Administrator'}</span>
              </div>
              <div className="h-10 w-10 rounded-full overflow-hidden bg-gradient-to-br from-blue-100 to-indigo-100 border border-blue-200 flex items-center justify-center text-blue-700 font-bold shadow-sm">
                {user?.photoURL ? (
                  <img src={user.photoURL} alt={user.name} className="h-full w-full object-cover" />
                ) : (
                  user?.name?.charAt(0) || 'A'
                )}
              </div>
            </div>
            <button
              onClick={() => setShowLogoutModal(true)}
              className="p-2.5 text-slate-400 hover:text-red-500 rounded-full hover:bg-red-50 transition-all duration-200"
              title="Logout"
            >
              <LogOut className="h-5 w-5" />
            </button>
          </div>
        </header>

        <main className="flex-1 overflow-y-auto p-4 sm:p-5 relative">
          {children}
        </main>
      </div>

      <Modal
        isOpen={showLogoutModal}
        onClose={() => setShowLogoutModal(false)}
        title="Confirm Logout"
        maxWidth="sm"
        footer={
          <div className="flex justify-end gap-3 w-full">
            <button
              onClick={() => setShowLogoutModal(false)}
              className="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded-lg transition-colors font-medium"
            >
              No, Cancel
            </button>
            <button
              onClick={() => {
                setShowLogoutModal(false);
                logout();
              }}
              className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-medium"
            >
              Yes, Logout
            </button>
          </div>
        }
      >
        <div className="py-4 text-slate-600">
          Are you sure you want to log out of your account?
        </div>
      </Modal>
    </div>
  );
}
