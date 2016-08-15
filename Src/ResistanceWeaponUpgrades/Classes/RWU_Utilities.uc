// Loads the default config file and modifies reward templates to randomly add weapon upgrades to reward soldiers

class RWU_Utilities extends Object;

static function bool IsEnabled(name DataName)
{
	return class'RWU_MCMListener'.default.ResistanceUpgrades.Find(DataName) != INDEX_NONE;
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
	/*local float Random, TotalWeight, CumulativeChance, CumulativeWeight;
	
	CumulativeChance = 0;
	CumulativeWeight = 0;

	Random = RandRange(0, 100);

	// Not sure if RandRange is inclusive or exclusive; treating it as inclusive just in case
	while (Random == 100)
		Random = RandRange(0, 100);

	if (Random < (CumulativeChance+=default.BasicUpgradePercentChance))
	{
		TotalWeight = default.BasicLaserSightWeight + default.BasicScopeWeight + default.BasicExpandedMagazineWeight + default.BasicHairTriggerWeight + default.BasicAutoLoaderWeight + default.BasicStockWeight + default.BasicRepeaterWeight;

		Random = RandRange(0, TotalWeight);

		while (Random == TotalWeight)
			Random = RandRange(0, TotalWeight);

		if (Random < (CumulativeWeight+=default.BasicLaserSightWeight))
			AddUpgrade(NewGameState, UnitState, 'CritUpgrade_Bsc');

		else if (Random < (CumulativeWeight+=default.BasicScopeWeight))
			AddUpgrade(NewGameState, UnitState, 'AimUpgrade_Bsc');

		else if (Random < (CumulativeWeight+=default.BasicExpandedMagazineWeight))
			AddUpgrade(NewGameState, UnitState, 'ClipSizeUpgrade_Bsc');

		else if (Random < (CumulativeWeight+=default.BasicHairTriggerWeight))
			AddUpgrade(NewGameState, UnitState, 'FreeFireUpgrade_Bsc');

		else if (Random < (CumulativeWeight+=default.BasicAutoLoaderWeight))
			AddUpgrade(NewGameState, UnitState, 'ReloadUpgrade_Bsc');

		else if (Random < (CumulativeWeight+=default.BasicStockWeight))
			AddUpgrade(NewGameState, UnitState, 'MissDamageUpgrade_Bsc');

		else if (Random < (CumulativeWeight+=default.BasicRepeaterWeight))
			AddUpgrade(NewGameState, UnitState, 'FreeKillUpgrade_Bsc');
	}
	else if (Random < (CumulativeChance+=default.AdvancedUpgradePercentChance))
	{
		TotalWeight = default.AdvancedLaserSightWeight + default.AdvancedScopeWeight + default.AdvancedExpandedMagazineWeight + default.AdvancedHairTriggerWeight + default.AdvancedAutoLoaderWeight + default.AdvancedStockWeight + default.AdvancedRepeaterWeight;

		Random = RandRange(0, TotalWeight);

		while (Random == TotalWeight)
			Random = RandRange(0, TotalWeight);

		if (Random < (CumulativeWeight+=default.AdvancedLaserSightWeight))
			AddUpgrade(NewGameState, UnitState, 'CritUpgrade_Adv');

		else if (Random < (CumulativeWeight+=default.AdvancedScopeWeight))
			AddUpgrade(NewGameState, UnitState, 'AimUpgrade_Adv');

		else if (Random < (CumulativeWeight+=default.AdvancedExpandedMagazineWeight))
			AddUpgrade(NewGameState, UnitState, 'ClipSizeUpgrade_Adv');

		else if (Random < (CumulativeWeight+=default.AdvancedHairTriggerWeight))
			AddUpgrade(NewGameState, UnitState, 'FreeFireUpgrade_Adv');

		else if (Random < (CumulativeWeight+=default.AdvancedAutoLoaderWeight))
			AddUpgrade(NewGameState, UnitState, 'ReloadUpgrade_Adv');

		else if (Random < (CumulativeWeight+=default.AdvancedStockWeight))
			AddUpgrade(NewGameState, UnitState, 'MissDamageUpgrade_Adv');

		else if (Random < (CumulativeWeight+=default.AdvancedRepeaterWeight))
			AddUpgrade(NewGameState, UnitState, 'FreeKillUpgrade_Adv');
	}
	else if (Random < (CumulativeChance+=default.SuperiorUpgradePercentChance))
	{
		TotalWeight = default.SuperiorLaserSightWeight + default.SuperiorScopeWeight + default.SuperiorExpandedMagazineWeight + default.SuperiorHairTriggerWeight + default.SuperiorAutoLoaderWeight + default.SuperiorStockWeight + default.SuperiorRepeaterWeight;

		Random = RandRange(0, TotalWeight);

		while (Random == TotalWeight)
			Random = RandRange(0, TotalWeight);

		if (Random < (CumulativeWeight+=default.SuperiorLaserSightWeight))
			AddUpgrade(NewGameState, UnitState, 'CritUpgrade_Sup');

		else if (Random < (CumulativeWeight+=default.SuperiorScopeWeight))
			AddUpgrade(NewGameState, UnitState, 'AimUpgrade_Sup');

		else if (Random < (CumulativeWeight+=default.SuperiorExpandedMagazineWeight))
			AddUpgrade(NewGameState, UnitState, 'ClipSizeUpgrade_Sup');

		else if (Random < (CumulativeWeight+=default.SuperiorHairTriggerWeight))
			AddUpgrade(NewGameState, UnitState, 'FreeFireUpgrade_Sup');

		else if (Random < (CumulativeWeight+=default.SuperiorAutoLoaderWeight))
			AddUpgrade(NewGameState, UnitState, 'ReloadUpgrade_Sup');

		else if (Random < (CumulativeWeight+=default.SuperiorStockWeight))
			AddUpgrade(NewGameState, UnitState, 'MissDamageUpgrade_Sup');

		else if (Random < (CumulativeWeight+=default.SuperiorRepeaterWeight))
			AddUpgrade(NewGameState, UnitState, 'FreeKillUpgrade_Sup');
	}*/
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
		`REDSCREEN("Unable to apply weapon upgrade" @ string(UpgradeName), true, 'ResistanceWeaponUpgrades');
		`LOG("Unable to apply weapon upgrade" @ string(UpgradeName), true, 'ResistanceWeaponUpgrades');
	}
}

static function AddGrimyLootItem(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	local XComGameState_Item PrimaryWeapon;
	local LWTuple GrimyTuple;
	local LWTValue ItemTemplate;
	//local int Random;

	/*Random = RAND(100);

	if (Random < GrimyPrimaryChance)
	{*/

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
}

static function int GetUpgradeWeight(name DataName)
{
	local name UpgradeName;
	local int Weight;

	Weight = 0;

	foreach class'RWU_MCMListener'.default.ResistanceUpgrades(UpgradeName)
	{
		if (UpgradeName == DataName)
		{
			Weight++;
		}
	}

	return Weight;
}