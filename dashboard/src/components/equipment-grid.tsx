import { Clock3, MapPin, MapPinOff } from "lucide-react";

import type { Equipment } from "@/lib/types";

interface EquipmentGridProps {
  equipment: Equipment[];
}

const cardTones = [
  "bg-[#e9f4f2]",
  "bg-[#eef3f8]",
  "bg-[#f4f1eb]",
  "bg-[#f1f3ee]",
];

function relativeTime(timestamp: string) {
  const elapsedSeconds = Math.max(
    0,
    Math.floor((Date.now() - new Date(timestamp).getTime()) / 1_000),
  );
  const formatter = new Intl.RelativeTimeFormat("en", { numeric: "auto" });
  if (elapsedSeconds < 60) return formatter.format(-elapsedSeconds, "second");
  const minutes = Math.floor(elapsedSeconds / 60);
  if (minutes < 60) return formatter.format(-minutes, "minute");
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return formatter.format(-hours, "hour");
  return formatter.format(-Math.floor(hours / 24), "day");
}

export function EquipmentGrid({ equipment }: EquipmentGridProps) {
  if (equipment.length === 0) {
    return (
      <div className="flex min-h-80 flex-col items-center justify-center rounded-[2rem] bg-[#f3f5f4] px-6 text-center">
        <span className="rounded-full bg-white p-4 text-slate-500 shadow-sm">
          <MapPinOff aria-hidden="true" size={25} />
        </span>
        <p className="mt-5 text-lg font-medium text-slate-900">No equipment yet</p>
        <p className="mt-1 max-w-sm text-sm text-slate-500">
          Registered equipment will appear here with its latest ward.
        </p>
      </div>
    );
  }

  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      {equipment.map((item, index) => (
        <article
          key={item.id}
          className={`${cardTones[index % cardTones.length]} group flex min-h-64 flex-col justify-between rounded-[2rem] p-6 transition duration-200 hover:-translate-y-0.5 hover:shadow-[0_16px_36px_rgba(30,41,59,0.08)] sm:p-7`}
        >
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-xs font-medium uppercase tracking-[0.12em] text-slate-500">
                Current location
              </p>
              <h2 className="mt-3 text-2xl font-medium leading-tight tracking-[-0.025em] text-slate-950">
                {item.name}
              </h2>
            </div>
            <span className="grid size-11 shrink-0 place-items-center rounded-full bg-white/80 text-teal-700 shadow-sm">
              <MapPin aria-hidden="true" size={20} />
            </span>
          </div>

          <div>
            <p className="text-3xl font-medium tracking-[-0.035em] text-slate-950">
              {item.currentWardName ?? "Unknown ward"}
            </p>
            <p className="mt-3 flex items-center gap-2 text-sm text-slate-600">
              <Clock3 aria-hidden="true" size={15} />
              Last seen {relativeTime(item.updatedAt)}
            </p>
          </div>
        </article>
      ))}
    </div>
  );
}
