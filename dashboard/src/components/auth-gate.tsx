"use client";

import { useEffect, useState } from "react";
import type { Session } from "@supabase/supabase-js";

import { EquipmentDashboard } from "@/components/equipment-dashboard";
import { SetPasswordForm } from "@/components/set-password-form";
import { SignInForm } from "@/components/sign-in-form";
import { getSupabaseBrowserClient } from "@/lib/supabase";

export function AuthGate() {
  const [session, setSession] = useState<Session | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [requiresPasswordSetup, setRequiresPasswordSetup] = useState(false);

  useEffect(() => {
    const client = getSupabaseBrowserClient();
    if (!client) {
      const timer = window.setTimeout(() => setIsLoading(false), 0);
      return () => window.clearTimeout(timer);
    }

    const authFlow = new URLSearchParams(window.location.hash.slice(1)).get(
      "type",
    );
    void client.auth.getSession().then(({ data }) => {
      setSession(data.session);
      setRequiresPasswordSetup(
        authFlow === "invite" ||
          authFlow === "recovery" ||
          Boolean(
            data.session?.user.invited_at &&
              data.session.user.user_metadata.quicktrack_password_set !== true,
          ),
      );
      setIsLoading(false);
    });
    const { data } = client.auth.onAuthStateChange((event, nextSession) => {
      setSession(nextSession);
      if (event === "PASSWORD_RECOVERY") setRequiresPasswordSetup(true);
      setIsLoading(false);
    });

    return () => data.subscription.unsubscribe();
  }, []);

  if (isLoading) {
    return (
      <main className="grid min-h-screen place-items-center">
        <div className="size-8 animate-spin rounded-full border-2 border-teal-600 border-t-transparent" />
      </main>
    );
  }

  if (!session) return <SignInForm />;

  if (requiresPasswordSetup) {
    return (
      <SetPasswordForm onComplete={() => setRequiresPasswordSetup(false)} />
    );
  }

  return (
    <EquipmentDashboard
      userEmail={session.user.email ?? "Authorised user"}
      onSignOut={async () => {
        await getSupabaseBrowserClient()?.auth.signOut();
      }}
    />
  );
}
