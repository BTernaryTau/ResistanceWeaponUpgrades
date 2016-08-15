// Creates and handles the settings page if MCM is installed

class RWU_MCMListener extends UIScreenListener config(ResistanceWeaponUpgrades) dependson(RWU_Utilities);

`include(ResistanceWeaponUpgrades/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(ResistanceWeaponUpgrades/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config int ConfigVersion;

var config int UpgradeChance;

var config bool GrimyMode;

var config array<name> ResistanceUpgrades;

var array<string> UpgradeSpinnerValues;

var array<MCM_API_Spinner> UpgradeSpinners;

var array<X2WeaponUpgradeTemplate> TemplateArray;

var array<string> SpinnerOptions;

var localized string ModName, GeneralGroupName;
var localized string BasicUpgradesGroupName, AdvancedUpgradesGroupName, SuperiorUpgradesGroupName, PrototypeUpgradesGroupName, OtherUpgradesGroupName;
var localized string UpgradeSpinnerDesc;

event OnInit(UIScreen Screen)
{
	`MCM_API_Register(Screen, ClientModCallback);
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
	local XComGameState_Item DummyWeapon;
	local int i;

	local MCM_API_SettingsPage Page;
	local MCM_API_SettingsGroup General, BasicUpgrades, AdvancedUpgrades, SuperiorUpgrades, PrototypeUpgrades, OtherUpgrades;

	TemplateArray = class'X2ItemTemplateManager'.static.GetItemTemplateManager().GetAllUpgradeTemplates();

	// Set up the dummy weapon
	DummyWeapon = new class'XComGameState_Item';
	DummyWeapon.InventorySlot = eInvSlot_PrimaryWeapon;

	// Remove templates that aren't for primary weapons
	for (i = 0; i < TemplateArray.Length; i++)
	{
		if (!TemplateArray[i].CanApplyUpgradeToWeaponFn(new class'X2WeaponUpgradeTemplate', DummyWeapon, 0))
		{
			`LOG("Excluding weapon upgrade template" @ TemplateArray[i].DataName @ "from TemplateArray", true, 'ResistanceWeaponUpgrades');
			TemplateArray.Remove(i, 1);
			i--;
		}
		else
		{
			`LOG("Adding weapon upgrade template" @ TemplateArray[i].DataName @ "to TemplateArray", true, 'ResistanceWeaponUpgrades');
		}
	}

	LoadSavedSettings();

	Page = ConfigAPI.NewSettingsPage(ModName);
	Page.SetPageTitle(ModName);
	Page.SetSaveHandler(SaveButtonClicked);
	Page.SetCancelHandler(RevertButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);
	
	General = Page.AddGroup('RWUGeneralGroup', GeneralGroupName);

	if (class'RWU_Utilities'.static.DoesUpgradeTierExist(TemplateArray, 0))
		BasicUpgrades = Page.AddGroup('RWUBasicUpgradesGroup', BasicUpgradesGroupName);
	
	if (class'RWU_Utilities'.static.DoesUpgradeTierExist(TemplateArray, 1))
		AdvancedUpgrades = Page.AddGroup('RWUAdvancedUpgradesGroup', AdvancedUpgradesGroupName);
	
	if (class'RWU_Utilities'.static.DoesUpgradeTierExist(TemplateArray, 2))
		SuperiorUpgrades = Page.AddGroup('RWUSuperiorUpgradesGroup', SuperiorUpgradesGroupName);

	if (class'RWU_Utilities'.static.DoesUpgradeTierExist(TemplateArray, 3))
		PrototypeUpgrades = Page.AddGroup('RWUPrototypeUpgradesGroup', PrototypeUpgradesGroupName);

	for (i = 0; i < TemplateArray.Length; i++)
	{
		if (TemplateArray[i].Tier < 0 || TemplateArray[i].Tier > 3)
		{
			OtherUpgrades = Page.AddGroup('RWUOtherUpgradesGroup', OtherUpgradesGroupName);
			break;
		}
	}

	UpgradeSpinners.Length = 0;

	for (i = 0; i < TemplateArray.Length; i++)
	{
		switch (TemplateArray[i].Tier)
		{
			case 0:
				UpgradeSpinners.AddItem(BasicUpgrades.AddSpinner(name('RWUUpgradeSpinner_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeSpinnerDesc, SpinnerOptions, UpgradeSpinnerValues[i], UpgradeSpinnerSaveHandler));
				break;
			case 1:
				UpgradeSpinners.AddItem(AdvancedUpgrades.AddSpinner(name('RWUUpgradeSpinner_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeSpinnerDesc, SpinnerOptions, UpgradeSpinnerValues[i], UpgradeSpinnerSaveHandler));
				break;
			case 2:
				UpgradeSpinners.AddItem(SuperiorUpgrades.AddSpinner(name('RWUUpgradeSpinner_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeSpinnerDesc, SpinnerOptions, UpgradeSpinnerValues[i], UpgradeSpinnerSaveHandler));
				break;
			case 3:
				UpgradeSpinners.AddItem(PrototypeUpgrades.AddSpinner(name('RWUUpgradeSpinner_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeSpinnerDesc, SpinnerOptions, UpgradeSpinnerValues[i], UpgradeSpinnerSaveHandler));
				break;
			default:
				UpgradeSpinners.AddItem(OtherUpgrades.AddSpinner(name('RWUUpgradeSpinner_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeSpinnerDesc, SpinnerOptions, UpgradeSpinnerValues[i], UpgradeSpinnerSaveHandler));
		}
	}

	Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'RWU_Defaults'.default.ConfigVersion, default.ConfigVersion)

simulated function LoadSavedSettings()
{
	local int i;

	UpgradeSpinnerValues.Length = 0;

	/*class'RWU_MCMListener'.static.*/LoadUserConfig();
	
	for (i = 0; i < TemplateArray.Length; i++)
	{
		UpgradeSpinnerValues.AddItem(string(class'RWU_Utilities'.static.GetUpgradeWeight(TemplateArray[i].DataName)));
	}
}

simulated function UpgradeSpinnerSaveHandler(MCM_API_Setting Spinner, string SpinnerValue)
{
	local int index;
	
	index = int(GetRightMost(Spinner.GetName()));

	UpgradeSpinnerValues[index] = SpinnerValue;
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	local int i, j;

	ResistanceUpgrades.Length = 0;

	for (i = 0; i < UpgradeSpinnerValues.Length; i++)
	{
		for (j = 0; j < int(UpgradeSpinnerValues[i]); j++)
		{
			ResistanceUpgrades.AddItem(TemplateArray[i].DataName);
		}
	}
	
    ConfigVersion = `MCM_CH_GetCompositeVersion();
	SaveConfig();

	// Allow proper garbage collection of UI elements
	UpgradeSpinners.Length = 0;
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	local name UpgradeName;
	local int Weight, i;

	for (i = 0; i < UpgradeSpinners.Length; i++)
	{
		`LOG(TemplateArray[i].DataName, true, 'ResistanceWeaponUpgrades');

		Weight = 0;

		foreach class'RWU_Defaults'.default.ResistanceUpgrades(UpgradeName)
		{
			if (UpgradeName == TemplateArray[i].DataName)
			{
				Weight++;
				`LOG("Weight =" @ Weight, true, 'ResistanceWeaponUpgrades');
			}
		}

		`LOG(TemplateArray[i].DataName @ "has a weight of" @ Weight, true, 'ResistanceWeaponUpgrades');
		UpgradeSpinners[i].SetValue(string(Weight), true);
	}
}

simulated function RevertButtonClicked(MCM_API_SettingsPage Page)
{
	// Allow proper garbage collection of UI elements
	UpgradeSpinners.Length = 0;
}

static function LoadUserConfig()
{
	local array<X2WeaponUpgradeTemplate> TempArray;
	local array<name> NameArray;
	local XComGameState_Item DummyWeapon;
	local int UserConfigVersion, DefaultConfigVersion, i;

	UserConfigVersion = default.ConfigVersion;
	DefaultConfigVersion = class'RWU_Defaults'.default.ConfigVersion;

	if (UserConfigVersion < DefaultConfigVersion && !UpdateUserConfigValues(UserConfigVersion))
	{
		return;
	}

	TempArray = class'X2ItemTemplateManager'.static.GetItemTemplateManager().GetAllUpgradeTemplates();

	for (i = 0; i < TempArray.Length; i++)
	{
		NameArray.AddItem(TempArray[i].DataName);
	}

	// Set up the dummy weapon
	DummyWeapon = new class'XComGameState_Item';
	DummyWeapon.InventorySlot = eInvSlot_PrimaryWeapon;

	// Update ResistanceUpgrades to reflect the removal of valid upgrades
	for (i = 0; i < default.ResistanceUpgrades.Length; i++)
	{
		if (NameArray.Find(default.ResistanceUpgrades[i]) == INDEX_NONE)
		{
			`LOG("Removing weapon upgrade template" @ default.ResistanceUpgrades[i] @ "from ResistanceUpgrades", true, 'ResistanceWeaponUpgrades');
			default.ResistanceUpgrades.Remove(i, 1);
			i--;
		}
	}
	
	StaticSaveConfig();
}

static function bool UpdateUserConfigValues(out int UserConfigVersion)
{
	switch (UserConfigVersion)
	{
		case 0:
		case 1:
			default.ConfigVersion = 2;
			
			default.UpgradeChance = class'RWU_Defaults'.default.UpgradeChance;
			default.GrimyMode = class'RWU_Defaults'.default.GrimyMode;

			default.ResistanceUpgrades = class'RWU_Defaults'.default.ResistanceUpgrades;
			break;

		default:
			`REDSCREEN("Unknown user config version" @ string(UserConfigVersion) @ "cannot be updated", true, 'ResistanceWeaponUpgrades');
			`LOG("Unknown user config version " @ string(UserConfigVersion) @ "cannot be updated", true, 'ResistanceWeaponUpgrades');
			return false;
	}

	`LOG("Updated user config version" @ string(UserConfigVersion) @ "to version" @ string(default.ConfigVersion), true, 'ResistanceWeaponUpgrades');

	UserConfigVersion = default.ConfigVersion;

	return true;
}

defaultproperties
{
	SpinnerOptions = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10")

	ScreenClass = class'MCM_OptionsScreen'
}