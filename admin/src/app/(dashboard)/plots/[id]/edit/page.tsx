/* eslint-disable react-hooks/immutability */
/* eslint-disable @typescript-eslint/no-explicit-any */
"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import api from "@/lib/api";
import PlotForm from "@/components/PlotForm";
import { Loader2 } from "lucide-react";
import toast from "react-hot-toast";

export default function EditPlotPage() {
  const params = useParams();
  const [plot, setPlot] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    async function fetchPlot() {
      try {
        const res = await api.get(`/plots`);
        const foundPlot = res.data.data.find((p: any) => p.id === params.id);
        if (foundPlot) setPlot(foundPlot);
        else {
          toast.error("Plot not found.");
          setError("Plot not found.");
        }
      } catch (err) {
        toast.error("Failed to load plot details.");
        setError("Failed to load plot details.");
      } finally {
        setLoading(false);
      }
    };
    if (params.id) {
      fetchPlot();
    }
  }, [params.id]);

  if (loading) return <div className="flex justify-center p-12"><Loader2 className="animate-spin text-blue-600 h-8 w-8" /></div>;
  if (error) return <div className="p-12 text-center text-red-600">{error}</div>;

  return (
    <div className="py-6 sm:px-6 lg:px-8 bg-white shadow sm:rounded-lg">
      <PlotForm initialData={plot} isEdit={true} />
    </div>
  );
}
