"use client";

import { Printer, X } from "lucide-react";
import { QRCodeSVG } from "qrcode.react";

import type { Equipment } from "@/lib/types";

interface QrLabelSheetProps {
  equipment: Equipment[];
  onClose: () => void;
}

export function QrLabelSheet({ equipment, onClose }: QrLabelSheetProps) {
  return (
    <div
      className="qr-label-overlay fixed inset-0 z-50 overflow-y-auto bg-slate-950/45 p-3 backdrop-blur-sm sm:p-6"
      role="dialog"
      aria-modal="true"
      aria-labelledby="qr-label-title"
    >
      <div className="mx-auto max-w-5xl overflow-hidden rounded-[2rem] bg-white shadow-2xl">
        <header className="qr-label-controls sticky top-0 z-10 flex items-center justify-between gap-4 border-b border-slate-200 bg-white/95 px-5 py-4 backdrop-blur sm:px-7">
          <div>
            <h2 id="qr-label-title" className="text-xl font-medium text-slate-950">
              Equipment QR labels
            </h2>
            <p className="mt-1 text-sm text-slate-500">
              {equipment.length} printable {equipment.length === 1 ? "label" : "labels"}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => window.print()}
              disabled={equipment.length === 0}
              className="inline-flex items-center gap-2 rounded-full bg-slate-950 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-teal-800 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <Printer aria-hidden="true" size={16} />
              Print labels
            </button>
            <button
              type="button"
              onClick={onClose}
              aria-label="Close QR label preview"
              className="grid size-10 place-items-center rounded-full text-slate-600 transition hover:bg-slate-100 hover:text-slate-950"
            >
              <X aria-hidden="true" size={20} />
            </button>
          </div>
        </header>

        <div id="qr-label-sheet" className="grid gap-4 bg-slate-100 p-5 sm:grid-cols-2 sm:p-8">
          {equipment.map((item) => (
            <article
              key={item.id}
              className="qr-equipment-label flex min-h-64 items-center gap-6 rounded-2xl border border-slate-300 bg-white p-6"
            >
              <QRCodeSVG
                value={item.assetNumber}
                size={144}
                level="H"
                marginSize={2}
                title={`${item.name}: ${item.assetNumber}`}
                className="size-36 shrink-0"
              />
              <div className="min-w-0">
                <p className="text-xs font-semibold uppercase tracking-[0.15em] text-teal-700">
                  QuickTrack
                </p>
                <h3 className="mt-3 text-xl font-semibold leading-tight text-slate-950">
                  {item.name}
                </h3>
                <p className="mt-4 break-all font-mono text-sm font-semibold text-slate-700">
                  {item.assetNumber}
                </p>
                <p className="mt-3 text-xs leading-5 text-slate-500">
                  Scan before moving this equipment.
                </p>
              </div>
            </article>
          ))}
        </div>
      </div>
    </div>
  );
}
