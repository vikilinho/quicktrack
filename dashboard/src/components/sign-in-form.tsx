"use client";

import { useState, type FormEvent } from "react";
import { Activity, LockKeyhole } from "lucide-react";

import { getSupabaseBrowserClient } from "@/lib/supabase";

export function SignInForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isResetMode, setIsResetMode] = useState(false);
  const [resetSent, setResetSent] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const client = getSupabaseBrowserClient();
    if (!client) {
      setError("Supabase environment variables have not been configured.");
      return;
    }

    setIsSubmitting(true);
    setError(null);
    const result = await client.auth.signInWithPassword({ email, password });
    if (result.error) {
      setError(result.error.message);
      setIsSubmitting(false);
    }
  }

  async function handlePasswordReset(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const client = getSupabaseBrowserClient();
    if (!client) {
      setError("Supabase environment variables have not been configured.");
      return;
    }

    setIsSubmitting(true);
    setError(null);
    const result = await client.auth.resetPasswordForEmail(email, {
      redirectTo: window.location.origin,
    });
    setIsSubmitting(false);
    if (result.error) {
      setError(result.error.message);
      return;
    }
    setResetSent(true);
  }

  return (
    <main className="grid min-h-screen place-items-center px-6 py-12">
      <div className="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-8 shadow-[0_18px_60px_rgba(15,23,42,0.09)]">
        <span className="grid size-12 place-items-center rounded-xl bg-teal-700 text-white shadow-sm shadow-teal-900/20">
          <Activity aria-hidden="true" size={25} />
        </span>
        <p className="mt-6 text-xs font-semibold uppercase tracking-[0.14em] text-teal-700">
          WardFind dashboard
        </p>
        <h1 className="mt-2 text-3xl font-semibold tracking-tight text-slate-950">
          {isResetMode ? "Reset your password" : "Sign in to continue"}
        </h1>
        <p className="mt-2 text-sm leading-6 text-slate-500">
          {isResetMode
            ? "We’ll send a secure password-reset link to your dashboard email."
            : "Equipment locations and movement history are restricted to authorised staff."}
        </p>

        <form
          onSubmit={isResetMode ? handlePasswordReset : handleSubmit}
          className="mt-8 space-y-5"
        >
          <label className="block">
            <span className="mb-2 block text-sm font-semibold text-slate-700">Email address</span>
            <input
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              className="h-11 w-full rounded-lg border border-slate-200 px-3 text-sm outline-none transition focus:border-teal-500 focus:ring-2 focus:ring-teal-100"
            />
          </label>
          {!isResetMode && (
            <label className="block">
              <span className="mb-2 block text-sm font-semibold text-slate-700">Password</span>
              <input
                type="password"
                autoComplete="current-password"
                required
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                className="h-11 w-full rounded-lg border border-slate-200 px-3 text-sm outline-none transition focus:border-teal-500 focus:ring-2 focus:ring-teal-100"
              />
            </label>
          )}
          {resetSent && (
            <p role="status" className="rounded-lg bg-emerald-50 px-3 py-2.5 text-sm text-emerald-700">
              Open Email to Reset Password
            </p>
          )}
          {error && (
            <p role="alert" className="rounded-lg bg-rose-50 px-3 py-2.5 text-sm text-rose-700">
              {error}
            </p>
          )}
          <button
            type="submit"
            disabled={isSubmitting}
            className="inline-flex h-11 w-full items-center justify-center gap-2 rounded-lg bg-teal-700 px-4 text-sm font-semibold text-white transition hover:bg-teal-800 disabled:cursor-not-allowed disabled:opacity-60"
          >
            <LockKeyhole aria-hidden="true" size={16} />
            {isSubmitting
              ? isResetMode
                ? "Sending reset link…"
                : "Signing in…"
              : isResetMode
                ? "Send reset link"
                : "Sign in securely"}
          </button>
          <button
            type="button"
            onClick={() => {
              setIsResetMode((current) => !current);
              setError(null);
              setResetSent(false);
            }}
            className="w-full text-center text-sm font-semibold text-teal-700 hover:text-teal-900"
          >
            {isResetMode ? "Back to sign in" : "Forgot password?"}
          </button>
        </form>
      </div>
    </main>
  );
}
