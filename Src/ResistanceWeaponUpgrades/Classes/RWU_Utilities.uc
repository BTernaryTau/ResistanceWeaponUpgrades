// Loads the default config file and modifies reward templates to randomly add weapon upgrades to reward soldiers

class RWU_Utilities extends Object;

struct UpgradeSettings
{
	var name Upgrade;
	var int Weight;
	
	structdefaultproperties
	{
		Weight = 1;
	}
};

static function bool IsListed(name DataName)
{
	local int i;

	for (i = 0; i < class'RWU_MCMListener'.default.ResistanceUpgrades.Length; i++)
	{
		if (class'RWU_MCMListener'.default.ResistanceUpgrades[i].Upgrade == DataName)
			return true;
	}

	return false;
}

static function bool DoesUpgradeTierExist(array<X2WeaponUpgradeTemplate> TemplateArray, int Tier)
{
	local int i;

	for (i = 0; i < TemplateArray.Length; i++)
	{
		if (TemplateArray[i].Tier == Tier)
			return true;
	}

	return false;
}

static function int GetUpgradeWeight(name DataName)
{
	local int i;

	for (i = 0; i < class'RWU_MCMListener'.default.ResistanceUpgrades.Length; i++)
	{
		if (class'RWU_MCMListener'.default.ResistanceUpgrades[i].Upgrade == DataName)
		{
			return class'RWU_MCMListener'.default.ResistanceUpgrades[i].Weight;
		}
	}

	`REDSCREEN("GetUpgradeWeight was called for an upgrade not found in ResistanceUpgrades", true, 'ResistanceWeaponUpgrades');
	`LOG("GetUpgradeWeight was called for an upgrade not found in ResistanceUpgrades", true, 'ResistanceWeaponUpgrades');

	return 0;
}

static function int GetDefaultUpgradeWeight(name DataName, int Tier)
{
	local int i;

	for (i = 0; i < class'RWU_Defaults'.default.ResistanceUpgrades.Length; i++)
	{
		if (class'RWU_Defaults'.default.ResistanceUpgrades[i].Upgrade == DataName)
		{
			return class'RWU_Defaults'.default.ResistanceUpgrades[i].Weight;
		}
	}

	if (Tier < 0 || Tier > 2)
		return 1;

	return 3 - Tier;
}

static function GiveNonCouncilSoldierReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;

	History = `XCOMHISTORY;

	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	NewGameState.AddStateObject(XComHQ);	

	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	if (UnitState == none)
	{
		UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', RewardState.RewardObjectReference.ObjectID));
		NewGameState.AddStateObject(UnitState);
	}
		
	`assert(UnitState != none);

	if (UnitState.GetMyTemplate().bIsSoldier)
	{
		UnitState.ApplyBestGearLoadout(NewGameState);

		// Here's the new part
		AddRandomUpgrade(NewGameState, UnitState);
		//AddGrimyLootItem(NewGameState, UnitState);
	}

	if (bOrder)
	{
		XComHQ.OrderStaff(UnitState.GetReference(), OrderHours);
	}
	else
	{
		XComHQ.AddToCrew(NewGameState, UnitState);
		XComHQ.HandlePowerOrStaffingChange(NewGameState);
	}

	NewGameState.AddStateObject(UnitState);
}

static function AddRandomUpgrade(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local array<name> WeightedUpgradeArray;
	local int Random, i, j;

	Random = `SYNC_RAND_STATIC(100);

	if (Random < class'RWU_MCMListener'.default.UpgradeChance)
	{
		for (i = 0; i < class'RWU_MCMListener'.default.ResistanceUpgrades.Length; i++)
		{
			for (j = 0; j < class'RWU_MCMListener'.default.ResistanceUpgrades[i].Weight; j++)
				WeightedUpgradeArray.AddItem(class'RWU_MCMListener'.default.ResistanceUpgrades[i].Upgrade);
		}

		Random = `SYNC_RAND_STATIC(WeightedUpgradeArray.Length);

		AddUpgrade(NewGameState, UnitState, WeightedUpgradeArray[Random]);
	}
}

static function AddUpgrade(XComGameState NewGameState, XComGameState_Unit UnitState, name UpgradeName)
{
	local XComGameState_Item PrimaryWeapon;
	local X2WeaponUpgradeTemplate WeaponUpgrade;

	PrimaryWeapon = UnitState.GetPrimaryWeapon();

	WeaponUpgrade = X2WeaponUpgradeTemplate(class'X2ItemTemplateManager'.static.GetItemTemplateManager().FindItemTemplate(UpgradeName));
	
	if (WeaponUpgrade.CanApplyUpgradeToWeapon(PrimaryWeapon))
	{
		PrimaryWeapon.ApplyWeaponUpgradeTemplate(WeaponUpgrade);
		UnitState.AddItemToInventory(PrimaryWeapon, eInvSlot_PrimaryWeapon, NewGameState);
	}
	else
	{
		`REDSCREEN("Unable to apply weapon upgrade" @ UpgradeName, true, 'ResistanceWeaponUpgrades');
		`LOG("Unable to apply weapon upgrade" @ UpgradeName, true, 'ResistanceWeaponUpgrades');
	}
}

/*static function AddGrimyLootItem(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local XComGameState_Item PrimaryWeapon;
	local LWTuple GrimyTuple;
	local LWTValue ItemTemplate;
	//local int Random;

	//Random = RAND(100);

	//if (Random < GrimyPrimaryChance)
	//{

	ItemTemplate.kind = LWTVObject;
	ItemTemplate.o = UnitState.GetPrimaryWeapon().GetMyTemplate();

	GrimyTuple = new class'LWTuple';
	GrimyTuple.Id = 'GrimyLootItemTemplate';
	GrimyTuple.Data.AddItem(ItemTemplate);

	`XEVENTMGR.TriggerEvent('RequestGrimyLootItem', GrimyTuple);

	if (GrimyTuple.Data.Length < 2)
	{
		`REDSCREEN("Received no response to GrimyLootItemTemplate LWTuple", true, 'ResistanceWeaponUpgrades');
		`LOG("Received no response to GrimyLootItemTemplate LWTuple", true, 'ResistanceWeaponUpgrades');

		AddRandomUpgrade(NewGameState, UnitState);
		return;
	}
	else if (GrimyTuple.Data[1].kind != LWTVObject || XComGameState_Item(GrimyTuple.Data[1].o) == none)
	{
		`REDSCREEN("Received invalid response to GrimyLootItemTemplate LWTuple", true, 'ResistanceWeaponUpgrades');
		`LOG("Received invalid response to GrimyLootItemTemplate LWTuple", true, 'ResistanceWeaponUpgrades');

		AddRandomUpgrade(NewGameState, UnitState);
		return;
	}

	PrimaryWeapon = XComGameState_Item(GrimyTuple.Data[1].o);

	UnitState.AddItemToInventory(PrimaryWeapon, eInvSlot_PrimaryWeapon, NewGameState);
	//}
}*/