"use client";

import { useCallback, useEffect, useState } from "react";

import { demoEquipment, demoWards } from "@/lib/mock-data";
import {
  getSupabaseBrowserClient,
  hasSupabaseConfig,
} from "@/lib/supabase";
import type { Equipment, EquipmentRow, Ward } from "@/lib/types";

const equipmentSelect = `
  id,
  asset_number,
  name,
  category,
  owner_ward_id,
  current_ward_id,
  updated_at,
  owner_ward:wards!equipments_owner_ward_id_fkey(name),
  current_ward:wards!equipments_current_ward_id_fkey(name)
`;

function relationName(
  relation: { name: string } | { name: string }[] | null,
) {
  return Array.isArray(relation) ? relation[0]?.name ?? null : relation?.name ?? null;
}

function mapEquipment(row: EquipmentRow): Equipment {
  return {
    id: row.id,
    assetNumber: row.asset_number,
    name: row.name,
    category: row.category,
    ownerWardId: row.owner_ward_id,
    ownerWardName: relationName(row.owner_ward),
    currentWardId: row.current_ward_id,
    currentWardName: relationName(row.current_ward),
    updatedAt: row.updated_at,
  };
}

export function useEquipment() {
  const configured = hasSupabaseConfig();
  const [equipment, setEquipment] = useState<Equipment[]>(
    configured ? [] : demoEquipment,
  );
  const [wards, setWards] = useState<Ward[]>(configured ? [] : demoWards);
  const [isLoading, setIsLoading] = useState(configured);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [lastRefreshedAt, setLastRefreshedAt] = useState<Date | null>(null);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    const client = getSupabaseBrowserClient();
    if (!client) return;

    setIsRefreshing(true);
    setError(null);
    try {
      const [equipmentResult, wardsResult] = await Promise.all([
        client.from("equipments").select(equipmentSelect).order("asset_number"),
        client.from("wards").select("id, name").order("display_order"),
      ]);

      if (equipmentResult.error || wardsResult.error) {
        setError(
          equipmentResult.error?.message ??
            wardsResult.error?.message ??
            "Could not load equipment.",
        );
        return;
      }

      setEquipment(
        (equipmentResult.data as unknown as EquipmentRow[]).map(mapEquipment),
      );
      setWards(wardsResult.data as Ward[]);
      setLastRefreshedAt(new Date());
    } catch (refreshError) {
      setError(
        refreshError instanceof Error
          ? refreshError.message
          : "Could not load equipment.",
      );
    } finally {
      setIsLoading(false);
      setIsRefreshing(false);
    }
  }, []);

  useEffect(() => {
    if (!configured) return;
    const client = getSupabaseBrowserClient();
    if (!client) return;

    const initialRefresh = window.setTimeout(() => void refresh(), 0);
    const channel = client
      .channel("equipment-dashboard")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "equipments" },
        () => void refresh(),
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "wards" },
        () => void refresh(),
      )
      .subscribe();

    return () => {
      window.clearTimeout(initialRefresh);
      void client.removeChannel(channel);
    };
  }, [configured, refresh]);

  return {
    configured,
    equipment,
    wards,
    isLoading,
    isRefreshing,
    lastRefreshedAt,
    error,
    refresh,
  };
}
