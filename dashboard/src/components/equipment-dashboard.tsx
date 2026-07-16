"use client";

import { useState } from "react";
import { Activity, CircleAlert, LogOut, QrCode, RefreshCw } from "lucide-react";

import { EquipmentGrid } from "@/components/equipment-grid";
import { QrLabelSheet } from "@/components/qr-label-sheet";
import { useEquipment } from "@/hooks/use-equipment";

interface EquipmentDashboardProps {
  userEmail: string;
  onSignOut: () => Promise<void>;
}

export function EquipmentDashboard({
  userEmail,
  onSignOut,
}: EquipmentDashboardProps) {
  const [showQrLabels, setShowQrLabels] = useState(false);
  const {
    configured,
    equipment,
    isLoading,
    isRefreshing,
    lastRefreshedAt,
    error,
    refresh,
  } = useEquipment();

  return (
    <div className="min-h-screen bg-white">
      <header className="sticky top-0 z-20 border-b border-slate-200/70 bg-white/90 backdrop-blur-xl">
        <div className="mx-auto flex h-18 max-w-[1440px] items-center justify-between px-5 sm:px-8 lg:px-12">
          <div className="flex items-center gap-3">
            <span className="grid size-9 place-items-center rounded-full bg-teal-700 text-white">
              <Activity aria-hidden="true" size={19} />
            </span>
            <p className="text-lg font-medium tracking-[-0.02em] text-slate-950">QuickTrack</p>
          </div>
          <div className="flex items-center gap-3">
            <p className="hidden text-sm text-slate-600 sm:block">{userEmail}</p>
            <button
              type="button"
              onClick={() => void onSignOut()}
              aria-label="Sign out"
              className="grid size-10 place-items-center rounded-full text-slate-600 transition hover:bg-slate-100 hover:text-slate-950"
            >
              <LogOut aria-hidden="true" size={16} />
            </button>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-[1440px] px-5 pb-16 pt-8 sm:px-8 sm:pt-12 lg:px-12 lg:pb-24">
        <section className="grid overflow-hidden rounded-[2rem] bg-[#e5f3f1] lg:grid-cols-[1.5fr_0.7fr]">
          <div className="flex min-h-80 flex-col justify-between p-7 sm:p-10 lg:min-h-[410px] lg:p-14">
            <div>
              <p className="text-sm font-medium text-teal-800">Hospital equipment tracking</p>
              <h1 className="mt-5 max-w-3xl text-4xl font-medium leading-[1.03] tracking-[-0.045em] text-slate-950 sm:text-5xl lg:text-6xl">
                Know where every device is.
              </h1>
              <p className="mt-5 max-w-xl text-base leading-7 text-slate-600 sm:text-lg">
                A clear, live view of each device and its last-known clinical ward.
              </p>
            </div>
            <button
              type="button"
              onClick={() => void refresh()}
              disabled={!configured || isLoading || isRefreshing}
              aria-live="polite"
              className="mt-8 inline-flex w-fit items-center gap-2 rounded-full bg-slate-950 px-5 py-3 text-sm font-medium text-white transition hover:bg-teal-800 disabled:cursor-not-allowed disabled:opacity-50"
            >
              <RefreshCw
                aria-hidden="true"
                size={16}
                className={isLoading || isRefreshing ? "animate-spin" : ""}
              />
              {isRefreshing ? "Refreshing…" : "Refresh locations"}
            </button>
          </div>
          <div className="flex min-h-52 flex-col justify-between bg-teal-800 p-7 text-white sm:p-10 lg:min-h-[410px] lg:p-12">
            <p className="text-sm text-teal-100">Registered equipment</p>
            <div>
              <p className="text-7xl font-medium tracking-[-0.06em] sm:text-8xl">
                {String(equipment.length).padStart(2, "0")}
              </p>
              <p className="mt-3 max-w-xs text-sm leading-6 text-teal-100">
                Devices currently visible across your hospital wards.
              </p>
            </div>
          </div>
        </section>

        {error && (
          <div role="alert" className="mt-6 flex items-start gap-3 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-900">
            <CircleAlert aria-hidden="true" className="mt-0.5 shrink-0" size={18} />
            <p>Supabase could not be reached: {error}</p>
          </div>
        )}

        <section aria-label="Equipment locations" className="mt-12 sm:mt-16">
          <div className="mb-6 flex items-end justify-between gap-4">
            <div>
              <p className="text-sm font-medium text-teal-800">Live locations</p>
              <h2 className="mt-1 text-3xl font-medium tracking-[-0.035em] text-slate-950">
                Equipment at a glance
              </h2>
            </div>
            <div className="flex items-center gap-4">
              <div className="hidden text-right text-sm text-slate-500 sm:block">
                <p>{equipment.length} devices</p>
                {lastRefreshedAt && (
                  <p className="mt-1 text-xs text-teal-700" aria-live="polite">
                    Updated at {lastRefreshedAt.toLocaleTimeString([], {
                      hour: "2-digit",
                      minute: "2-digit",
                      second: "2-digit",
                    })}
                  </p>
                )}
              </div>
              <button
                type="button"
                onClick={() => setShowQrLabels(true)}
                disabled={isLoading || equipment.length === 0}
                className="inline-flex items-center gap-2 rounded-full border border-slate-300 bg-white px-4 py-2.5 text-sm font-medium text-slate-800 transition hover:border-teal-700 hover:text-teal-800 disabled:cursor-not-allowed disabled:opacity-40"
              >
                <QrCode aria-hidden="true" size={17} />
                Print QR labels
              </button>
            </div>
          </div>
          {isLoading ? (
            <div className="grid min-h-80 place-items-center rounded-[2rem] bg-slate-50 text-sm text-slate-500">
              <RefreshCw aria-hidden="true" className="mb-3 animate-spin text-teal-600" />
              Loading equipment locations…
            </div>
          ) : (
            <EquipmentGrid equipment={equipment} />
          )}
        </section>
      </main>
      {showQrLabels && (
        <QrLabelSheet
          equipment={equipment}
          onClose={() => setShowQrLabels(false)}
        />
      )}
    </div>
  );
}
