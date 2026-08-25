"use client";

import { useAuth } from "@/context/AuthContext";
import {
  LayoutDashboard, User, LogOut, Menu, X
} from "lucide-react";
import Link from "next/link";
import { useRouter, usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";

const navItems = [
  { name: "Dashboard", href: "/agent-dashboard", icon: LayoutDashboard },
  { name: "Profile", href: "/agent-dashboard/profile", icon: User },
];

export default function AgentDashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, logout } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
    // Real auth logic should ensure the user has the 'AGENT' role here.
    if (!user) {
      router.push("/login");
    }
  }, [user, router]);

  if (!isClient || !user) return null;

  return (
    <div className="min-h-screen bg-slate-50 flex">
      {/* Sidebar */}
      <aside className="hidden lg:flex flex-col w-72 bg-white border-r border-slate-200 fixed h-full z-20">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
              Agent Portal
            </h1>
            <p className="text-xs text-slate-500 font-medium mt-1 uppercase tracking-wider">
              Sales Partner
            </p>
          </div>
        </div>
        
        <nav className="flex-1 p-4 space-y-1.5 overflow-y-auto custom-scrollbar">
          {navItems.map((item) => {
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.name}
                href={item.href}
                className={`flex items-center px-4 py-3 rounded-xl transition-all duration-200 group relative overflow-hidden ${
                  isActive
                    ? "bg-blue-50 text-blue-700 font-semibold"
                    : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
                }`}
              >
                {isActive && (
                  <motion.div
                    layoutId="activeTab"
                    className="absolute left-0 top-0 bottom-0 w-1 bg-blue-600 rounded-r-full"
                    initial={false}
                    transition={{ type: "spring", stiffness: 300, damping: 30 }}
                  />
                )}
                <item.icon className={`w-5 h-5 mr-3 transition-colors ${
                  isActive ? "text-blue-600" : "text-slate-400 group-hover:text-slate-600"
                }`} />
                {item.name}
              </Link>
            );
          })}
        </nav>

        <div className="p-4 border-t border-slate-100">
          <div className="bg-slate-50 rounded-xl p-4 mb-4 border border-slate-100 flex items-center gap-3">
            <div className="h-10 w-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold text-lg">
              {user.email?.charAt(0).toUpperCase() || 'A'}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-bold text-slate-900 truncate">Agent User</p>
              <p className="text-xs text-slate-500 truncate">{user.email}</p>
            </div>
          </div>
          <button
            onClick={() => logout()}
            className="flex items-center w-full px-4 py-3 text-red-600 hover:bg-red-50 rounded-xl transition-colors font-medium group"
          >
            <LogOut className="w-5 h-5 mr-3 text-red-400 group-hover:text-red-600 transition-colors" />
            Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 lg:ml-72 flex flex-col min-h-screen">
        {/* Mobile Header */}
        <header className="lg:hidden bg-white border-b border-slate-200 sticky top-0 z-30 flex items-center justify-between p-4 shadow-sm">
          <h1 className="text-xl font-bold text-slate-900">Agent Portal</h1>
          <button
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            className="p-2 text-slate-600 hover:bg-slate-100 rounded-lg transition-colors"
          >
            {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </header>

        {/* Mobile Menu Overlay */}
        <AnimatePresence>
          {isMobileMenuOpen && (
            <>
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setIsMobileMenuOpen(false)}
                className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-40 lg:hidden"
              />
              <motion.div
                initial={{ x: "-100%" }}
                animate={{ x: 0 }}
                exit={{ x: "-100%" }}
                transition={{ type: "spring", bounce: 0, duration: 0.4 }}
                className="fixed inset-y-0 left-0 w-72 bg-white z-50 flex flex-col shadow-2xl lg:hidden"
              >
                <div className="p-6 border-b border-slate-100 flex items-center justify-between">
                  <h2 className="text-2xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
                    Agent Portal
                  </h2>
                  <button onClick={() => setIsMobileMenuOpen(false)} className="p-2 text-slate-400 hover:text-slate-600 bg-slate-50 hover:bg-slate-100 rounded-full transition-colors">
                    <X className="w-5 h-5" />
                  </button>
                </div>
                <nav className="flex-1 p-4 space-y-2 overflow-y-auto">
                  {navItems.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                      <Link
                        key={item.name}
                        href={item.href}
                        onClick={() => setIsMobileMenuOpen(false)}
                        className={`flex items-center px-4 py-3 rounded-xl transition-all duration-200 ${
                          isActive
                            ? "bg-blue-50 text-blue-700 font-semibold shadow-sm shadow-blue-100"
                            : "text-slate-600 hover:bg-slate-50 hover:text-slate-900"
                        }`}
                      >
                        <item.icon className={`w-5 h-5 mr-3 ${isActive ? "text-blue-600" : "text-slate-400"}`} />
                        {item.name}
                      </Link>
                    );
                  })}
                </nav>
              </motion.div>
            </>
          )}
        </AnimatePresence>

        <main className="flex-1 p-4 lg:p-8">
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
