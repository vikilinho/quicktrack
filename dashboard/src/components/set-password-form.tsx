"use client";

import { useState, type FormEvent } from "react";
import { KeyRound } from "lucide-react";

import { getSupabaseBrowserClient } from "@/lib/supabase";

interface SetPasswordFormProps {
  onComplete: () => void;
}

export function SetPasswordForm({ onComplete }: SetPasswordFormProps) {
  const [password, setPassword] = useState("");
  const [confirmation, setConfirmation] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (password.length < 10) {
      setError("Use at least 10 characters for your password.");
      return;
    }
    if (password !== confirmation) {
      setError("The passwords do not match.");
      return;
    }

    const client = getSupabaseBrowserClient();
    if (!client) return;
    setIsSubmitting(true);
    setError(null);
    const result = await client.auth.updateUser({
      password,
      data: { quicktrack_password_set: true },
    });
    if (result.error) {
      setError(result.error.message);
      setIsSubmitting(false);
      return;
    }
    window.history.replaceState(null, "", window.location.pathname);
    onComplete();
  }

  return (
    <main className="grid min-h-screen place-items-center px-6 py-12">
      <div className="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-8 shadow-[0_18px_60px_rgba(15,23,42,0.09)]">
        <span className="grid size-12 place-items-center rounded-xl bg-teal-700 text-white">
          <KeyRound aria-hidden="true" size={24} />
        </span>
        <p className="mt-6 text-xs font-semibold uppercase tracking-[0.14em] text-teal-700">
          Account setup
        </p>
        <h1 className="mt-2 text-3xl font-semibold tracking-tight text-slate-950">
          Choose your password
        </h1>
        <p className="mt-2 text-sm leading-6 text-slate-500">
          Complete your invited QuickTrack dashboard account.
        </p>

        <form onSubmit={handleSubmit} className="mt-8 space-y-5">
          <label className="block">
            <span className="mb-2 block text-sm font-semibold text-slate-700">Password</span>
            <input
              type="password"
              autoComplete="new-password"
              required
              minLength={10}
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              className="h-11 w-full rounded-lg border border-slate-200 px-3 text-sm outline-none focus:border-teal-500 focus:ring-2 focus:ring-teal-100"
            />
          </label>
          <label className="block">
            <span className="mb-2 block text-sm font-semibold text-slate-700">Confirm password</span>
            <input
              type="password"
              autoComplete="new-password"
              required
              minLength={10}
              value={confirmation}
              onChange={(event) => setConfirmation(event.target.value)}
              className="h-11 w-full rounded-lg border border-slate-200 px-3 text-sm outline-none focus:border-teal-500 focus:ring-2 focus:ring-teal-100"
            />
          </label>
          {error && (
            <p role="alert" className="rounded-lg bg-rose-50 px-3 py-2.5 text-sm text-rose-700">
              {error}
            </p>
          )}
          <button
            type="submit"
            disabled={isSubmitting}
            className="h-11 w-full rounded-lg bg-teal-700 text-sm font-semibold text-white transition hover:bg-teal-800 disabled:opacity-60"
          >
            {isSubmitting ? "Saving password…" : "Complete account setup"}
          </button>
        </form>
      </div>
    </main>
  );
}
