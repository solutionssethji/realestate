/* eslint-disable react-hooks/immutability */
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client";

import { useState, useEffect } from "react";
import api from "@/lib/api";
import {
  Building2, Map, PhoneIncoming, CalendarCheck, Loader2, ArrowRight
} from "lucide-react";
import Link from "next/link";
import { useLanguage } from '@/context/LanguageContext';
import { useAuth } from "@/context/AuthContext";
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts';
import { toast } from 'react-hot-toast';

interface DashboardStats {
  totalProjects: number;
  totalPlots: number;
  availablePlots: number;
  holdPlots: number;
  bookedPlots: number;
  totalEnquiries: number;
  totalSiteVisits: number;
}

const COLORS = ['#10B981', '#F59E0B', '#EF4444']; // Emerald, Amber, Red

export default function DashboardPage() {
  const { t } = useLanguage();
  const { user } = useAuth();
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    async function fetchDashboardData() {
      try {
        setLoading(true);
        const [projectsRes, plotsRes, enquiriesRes, visitsRes] = await Promise.all([
          api.get("/projects"),
          api.get("/plots"),
          api.get("/enquiries"),
          api.get("/site-visits")
        ]);

        const plots = plotsRes.data.data;

        setStats({
          totalProjects: projectsRes.data.data.length,
          totalPlots: plots.length,
          availablePlots: plots.filter((p: any) => p.status === 'AVAILABLE').length,
          holdPlots: plots.filter((p: any) => p.status === 'HOLD').length,
          bookedPlots: plots.filter((p: any) => p.status === 'BOOKED_SOLD').length,
          totalEnquiries: enquiriesRes.data.data.length,
          totalSiteVisits: visitsRes.data.data.length
        });
      } catch (err) {
        console.error("Dashboard fetch error:", err);
        toast.error(t('dashboard_fetch_error'));
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-[calc(100vh-10rem)]">
        <Loader2 className="h-10 w-10 animate-spin text-blue-600" />
      </div>
    );
  }
  const chartData = [
    { name: t('available'), value: stats?.availablePlots || 0 },
    { name: t('on_hold'), value: stats?.holdPlots || 0 },
    { name: t('booked_sold_status'), value: stats?.bookedPlots || 0 },
  ];

  return (
    <div className="space-y-8 pb-8">
      {/* Welcome Banner */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-blue-600 to-indigo-700 p-8 sm:p-10 shadow-xl shadow-blue-900/10">
        <div className="absolute top-0 right-0 -mt-10 -mr-10 opacity-20">
          <Building2 className="h-64 w-64 text-white transform rotate-12" />
        </div>
        <div className="relative z-10">
          <h1 className="text-3xl font-extrabold text-white tracking-tight">
            {t('welcome_back_user', { name: user?.name || t('administrator') })}
          </h1>
          <p className="mt-1.5 text-slate-50 max-w-2xl text-sm leading-relaxed">
            {t('dashboard_subtitle')}
          </p>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-4">
        {/* Project Card */}
        <div className="group bg-white rounded-2xl p-6 shadow-sm border border-slate-100 hover:shadow-xl hover:shadow-blue-500/10 hover:-translate-y-1 transition-all duration-300">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">{t('total_projects')}</p>
              <p className="mt-2 text-3xl font-bold text-slate-900">{stats?.totalProjects}</p>
            </div>
            <div className="p-3 bg-blue-50 rounded-xl group-hover:bg-blue-600 transition-colors duration-300">
              <Building2 className="h-7 w-7 text-blue-600 group-hover:text-white transition-colors duration-300" />
            </div>
          </div>
          <div className="mt-6">
            <Link href="/projects" className="text-sm font-medium text-blue-600 hover:text-blue-700 flex items-center group-hover:translate-x-1 transition-transform">
              {t('view_all_projects')} <ArrowRight className="ml-1.5 h-4 w-4" />
            </Link>
          </div>
        </div>

        {/* Plot Card */}
        <div className="group bg-white rounded-2xl p-6 shadow-sm border border-slate-100 hover:shadow-xl hover:shadow-indigo-500/10 hover:-translate-y-1 transition-all duration-300">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">{t('total_plots')}</p>
              <p className="mt-2 text-3xl font-bold text-slate-900">{stats?.totalPlots}</p>
            </div>
            <div className="p-3 bg-indigo-50 rounded-xl group-hover:bg-indigo-600 transition-colors duration-300">
              <Map className="h-7 w-7 text-indigo-600 group-hover:text-white transition-colors duration-300" />
            </div>
          </div>
          <div className="mt-6">
            <Link href="/plots" className="text-sm font-medium text-indigo-600 hover:text-indigo-700 flex items-center group-hover:translate-x-1 transition-transform">
              {t('manage_inventory')} <ArrowRight className="ml-1.5 h-4 w-4" />
            </Link>
          </div>
        </div>

        {/* Enquiries Card */}
        <div className="group bg-white rounded-2xl p-6 shadow-sm border border-slate-100 hover:shadow-xl hover:shadow-emerald-500/10 hover:-translate-y-1 transition-all duration-300">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">{t('total_enquiries')}</p>
              <p className="mt-2 text-3xl font-bold text-slate-900">{stats?.totalEnquiries}</p>
            </div>
            <div className="p-3 bg-emerald-50 rounded-xl group-hover:bg-emerald-600 transition-colors duration-300">
              <PhoneIncoming className="h-7 w-7 text-emerald-600 group-hover:text-white transition-colors duration-300" />
            </div>
          </div>
          <div className="mt-6">
            <Link href="/enquiries" className="text-sm font-medium text-emerald-600 hover:text-emerald-700 flex items-center group-hover:translate-x-1 transition-transform">
              {t('view_all_enquiries')} <ArrowRight className="ml-1.5 h-4 w-4" />
            </Link>
          </div>
        </div>

        {/* Site Visits Card */}
        <div className="group bg-white rounded-2xl p-6 shadow-sm border border-slate-100 hover:shadow-xl hover:shadow-purple-500/10 hover:-translate-y-1 transition-all duration-300">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-slate-500">{t('site_visits')}</p>
              <p className="mt-2 text-3xl font-bold text-slate-900">{stats?.totalSiteVisits}</p>
            </div>
            <div className="p-3 bg-purple-50 rounded-xl group-hover:bg-purple-600 transition-colors duration-300">
              <CalendarCheck className="h-7 w-7 text-purple-600 group-hover:text-white transition-colors duration-300" />
            </div>
          </div>
          <div className="mt-6">
            <Link href="/site-visits" className="text-sm font-medium text-purple-600 hover:text-purple-700 flex items-center group-hover:translate-x-1 transition-transform">
              {t('check_schedule')} <ArrowRight className="ml-1.5 h-4 w-4" />
            </Link>
          </div>
        </div>
      </div>

      {/* Charts and Details Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-8">
        {/* Plot Distribution Chart */}
        <div className="col-span-1 bg-white rounded-2xl shadow-sm border border-slate-100 p-6">
          <h2 className="text-lg font-bold text-slate-900 mb-6">{t('plot_status_distribution')}</h2>
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={chartData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {chartData.map((_, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                />
                <Legend verticalAlign="bottom" height={36} iconType="circle" />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Status Quick Stats */}
        <div className="col-span-1 lg:col-span-2 grid grid-cols-1 sm:grid-cols-3 gap-6">
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col justify-center relative overflow-hidden">
            <div className="absolute -right-4 -bottom-4 h-24 w-24 bg-emerald-50 rounded-full blur-2xl"></div>
            <dt className="text-sm font-medium text-slate-500 uppercase tracking-wider relative z-10">{t('available')}</dt>
            <dd className="mt-2 text-4xl font-extrabold text-slate-900 relative z-10">{stats?.availablePlots}</dd>
            <div className="mt-4 h-1 w-full bg-slate-100 rounded-full overflow-hidden">
              <div className="h-full bg-emerald-500 w-full"></div>
            </div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col justify-center relative overflow-hidden">
            <div className="absolute -right-4 -bottom-4 h-24 w-24 bg-amber-50 rounded-full blur-2xl"></div>
            <dt className="text-sm font-medium text-slate-500 uppercase tracking-wider relative z-10">{t('on_hold')}</dt>
            <dd className="mt-2 text-4xl font-extrabold text-slate-900 relative z-10">{stats?.holdPlots}</dd>
            <div className="mt-4 h-1 w-full bg-slate-100 rounded-full overflow-hidden">
              <div className="h-full bg-amber-500 w-full"></div>
            </div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100 flex flex-col justify-center relative overflow-hidden">
            <div className="absolute -right-4 -bottom-4 h-24 w-24 bg-red-50 rounded-full blur-2xl"></div>
            <dt className="text-sm font-medium text-slate-500 uppercase tracking-wider relative z-10">{t('booked_sold_status')}</dt>
            <dd className="mt-2 text-4xl font-extrabold text-slate-900 relative z-10">{stats?.bookedPlots}</dd>
            <div className="mt-4 h-1 w-full bg-slate-100 rounded-full overflow-hidden">
              <div className="h-full bg-red-500 w-full"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
