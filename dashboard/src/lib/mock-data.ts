import type { Equipment, Ward } from "@/lib/types";

export const demoWards: Ward[] = [
  { id: "ward-1", name: "Ward 1" },
  { id: "ward-3", name: "Ward 3" },
  { id: "ward-4", name: "Ward 4" },
  { id: "ward-5", name: "Ward 5" },
  { id: "ward-6", name: "Ward 6" },
  { id: "ward-7", name: "Ward 7" },
  { id: "ward-9", name: "Ward 9" },
  { id: "amau", name: "AMAU" },
  { id: "ccu", name: "CCU" },
  { id: "icu-itu", name: "ICU / ITU" },
];

const minutesAgo = (minutes: number) =>
  new Date(Date.now() - minutes * 60_000).toISOString();

export const demoEquipment: Equipment[] = [
  {
    id: "equipment-1",
    assetNumber: "EQ-BLADDER-001",
    name: "Bladder Scanner A",
    category: "Scanner",
    ownerWardId: "ward-1",
    ownerWardName: "Ward 1",
    currentWardId: "ward-1",
    currentWardName: "Ward 1",
    updatedAt: minutesAgo(8),
  },
  {
    id: "equipment-2",
    assetNumber: "EQ-INFUSION-001",
    name: "Infusion Pump 1",
    category: "Pump",
    ownerWardId: "icu-itu",
    ownerWardName: "ICU / ITU",
    currentWardId: "icu-itu",
    currentWardName: "ICU / ITU",
    updatedAt: minutesAgo(14),
  },
  {
    id: "equipment-3",
    assetNumber: "EQ-VENT-001",
    name: "Ventilator 1",
    category: "Ventilator",
    ownerWardId: "icu-itu",
    ownerWardName: "ICU / ITU",
    currentWardId: "amau",
    currentWardName: "AMAU",
    updatedAt: minutesAgo(20),
  },
  {
    id: "equipment-4",
    assetNumber: "EQ-ECG-001",
    name: "ECG Monitor 1",
    category: "Monitor",
    ownerWardId: "amau",
    ownerWardName: "AMAU",
    currentWardId: "amau",
    currentWardName: "AMAU",
    updatedAt: minutesAgo(47),
  },
  {
    id: "equipment-5",
    assetNumber: "EQ-ULTRASOUND-001",
    name: "Portable Ultrasound 1",
    category: "Scanner",
    ownerWardId: "ward-3",
    ownerWardName: "Ward 3",
    currentWardId: null,
    currentWardName: null,
    updatedAt: minutesAgo(132),
  },
];
