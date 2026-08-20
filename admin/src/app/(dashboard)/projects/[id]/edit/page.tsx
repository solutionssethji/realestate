/* eslint-disable react-hooks/immutability */
"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import api from "@/lib/api";
import ProjectForm from "@/components/ProjectForm";
import { Loader2 } from "lucide-react";
import toast from "react-hot-toast";

export default function EditProjectPage() {
  const params = useParams();
  const [project, setProject] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  /* eslint-disable react-hooks/set-state-in-effect */
  useEffect(() => {
    async function fetchProject() {
      try {
        const res = await api.get(`/projects/${params.id}`);
        setProject(res.data.data);
      } catch (err) {
        toast.error("Failed to load project details.");
        setError("Failed to load project details.");
      } finally {
        setLoading(false);
      }
    };
    if (params.id) {
      fetchProject();
    }
  }, [params.id]);

  if (loading) return <div className="flex justify-center p-12"><Loader2 className="animate-spin text-blue-600 h-8 w-8" /></div>;
  if (error) return <div className="p-12 text-center text-red-600">{error}</div>;

  return (
    <div className="py-6 sm:px-6 lg:px-8 bg-white shadow sm:rounded-lg">
      <ProjectForm initialData={project} isEdit={true} />
    </div>
  );
}
