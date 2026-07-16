export interface Equipment {
  id: string;
  assetNumber: string;
  name: string;
  category: string;
  ownerWardId: string | null;
  ownerWardName: string | null;
  currentWardId: string | null;
  currentWardName: string | null;
  updatedAt: string;
}

export interface Ward {
  id: string;
  name: string;
}

export interface EquipmentRow {
  id: string;
  asset_number: string;
  name: string;
  category: string;
  owner_ward_id: string | null;
  current_ward_id: string | null;
  updated_at: string;
  owner_ward: { name: string } | { name: string }[] | null;
  current_ward: { name: string } | { name: string }[] | null;
}
