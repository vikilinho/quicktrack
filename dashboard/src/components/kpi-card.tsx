import type { LucideIcon } from "lucide-react";

interface KpiCardProps {
  label: string;
  value: number;
  hint: string;
  icon: LucideIcon;
  tone: "teal" | "blue" | "amber" | "rose";
}

const tones = {
  teal: "bg-teal-50 text-teal-700 ring-teal-100",
  blue: "bg-sky-50 text-sky-700 ring-sky-100",
  amber: "bg-amber-50 text-amber-700 ring-amber-100",
  rose: "bg-rose-50 text-rose-700 ring-rose-100",
} as const;

export function KpiCard({ label, value, hint, icon: Icon, tone }: KpiCardProps) {
  return (
    <article className="rounded-2xl border border-slate-200/80 bg-white p-5 shadow-[0_1px_2px_rgba(15,23,42,0.03)]">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-sm font-medium text-slate-500">{label}</p>
          <p className="mt-2 font-mono text-3xl font-semibold tracking-tight text-slate-900">
            {value.toString().padStart(2, "0")}
          </p>
        </div>
        <span className={`rounded-xl p-2.5 ring-1 ${tones[tone]}`}>
          <Icon aria-hidden="true" size={20} strokeWidth={1.8} />
        </span>
      </div>
      <p className="mt-4 text-xs text-slate-500">{hint}</p>
    </article>
  );
}
