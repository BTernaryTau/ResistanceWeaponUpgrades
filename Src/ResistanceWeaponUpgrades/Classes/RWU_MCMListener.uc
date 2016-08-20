// Creates and handles the settings page if MCM is installed

class RWU_MCMListener extends UIScreenListener config(ResistanceWeaponUpgrades) dependson(RWU_Utilities);

`include(ResistanceWeaponUpgrades/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(ResistanceWeaponUpgrades/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config int ConfigVersion;

var config int UpgradeChance;

var config bool GrimyMode;

var config array<UpgradeSettings> ResistanceUpgrades;

var string ChanceDropdownValue;

var MCM_API_Dropdown ChanceDropdown;

var array<string> UpgradeDropdownValues;

var array<MCM_API_Dropdown> UpgradeDropdowns;

var array<X2WeaponUpgradeTemplate> TemplateArray;

var localized string ModName, GeneralGroupName;
var localized string BasicUpgradesGroupName, AdvancedUpgradesGroupName, SuperiorUpgradesGroupName;
var localized string PrototypeUpgradesGroupName, OtherUpgradesGroupName;
var localized string ChanceDropdownName, ChanceDropdownDesc, UpgradeDropdownDesc;

event OnInit(UIScreen Screen)
{
	`MCM_API_Register(Screen, ClientModCallback);
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
	local XComGameState_Item DummyWeapon;
	local array<string> DropdownOptionsLong;
	local array<string> DropdownOptionsShort;
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

	for (i = 0; i <= 100; i++)
		DropdownOptionsLong.AddItem(string(i));

	for (i = 0; i <= 10; i++)
		DropdownOptionsShort.AddItem(string(i));
	
	ChanceDropdown = General.AddDropdown('RWUChanceDropdown', ChanceDropdownName, ChanceDropdownDesc, DropdownOptionsLong, ChanceDropdownValue, ChanceDropdownSaveHandler);

	UpgradeDropdowns.Length = 0;

	for (i = 0; i < TemplateArray.Length; i++)
	{
		switch (TemplateArray[i].Tier)
		{
			case 0:
				UpgradeDropdowns.AddItem(BasicUpgrades.AddDropdown(name('RWUUpgradeDropdown_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeDropdownDesc, DropdownOptionsShort, UpgradeDropdownValues[i], UpgradeDropdownSaveHandler));
				break;
			case 1:
				UpgradeDropdowns.AddItem(AdvancedUpgrades.AddDropdown(name('RWUUpgradeDropdown_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeDropdownDesc, DropdownOptionsShort, UpgradeDropdownValues[i], UpgradeDropdownSaveHandler));
				break;
			case 2:
				UpgradeDropdowns.AddItem(SuperiorUpgrades.AddDropdown(name('RWUUpgradeDropdown_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeDropdownDesc, DropdownOptionsShort, UpgradeDropdownValues[i], UpgradeDropdownSaveHandler));
				break;
			case 3:
				UpgradeDropdowns.AddItem(PrototypeUpgrades.AddDropdown(name('RWUUpgradeDropdown_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeDropdownDesc, DropdownOptionsShort, UpgradeDropdownValues[i], UpgradeDropdownSaveHandler));
				break;
			default:
				UpgradeDropdowns.AddItem(OtherUpgrades.AddDropdown(name('RWUUpgradeDropdown_' $ i), TemplateArray[i].GetItemFriendlyNameNoStats(), UpgradeDropdownDesc, DropdownOptionsShort, UpgradeDropdownValues[i], UpgradeDropdownSaveHandler));
		}
	}

	Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'RWU_Defaults'.default.ConfigVersion, default.ConfigVersion)

simulated function LoadSavedSettings()
{
	local int i;

	UpgradeDropdownValues.Length = 0;

	LoadUserConfig(TemplateArray);
	
	ChanceDropdownValue = string(UpgradeChance);

	for (i = 0; i < TemplateArray.Length; i++)
	{
		UpgradeDropdownValues.AddItem(string(class'RWU_Utilities'.static.GetUpgradeWeight(TemplateArray[i].DataName)));
	}
}

`MCM_API_BasicDropdownSaveHandler(ChanceDropdownSaveHandler, ChanceDropdownValue)

simulated function UpgradeDropdownSaveHandler(MCM_API_Setting Dropdown, string DropdownValue)
{
	local int index;
	
	index = int(GetRightMost(Dropdown.GetName()));

	UpgradeDropdownValues[index] = DropdownValue;
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	local UpgradeSettings Settings;
	local int i;

	ResistanceUpgrades.Length = 0;

	UpgradeChance = int(ChanceDropdownValue);

	for (i = 0; i < UpgradeDropdownValues.Length; i++)
	{
		Settings.Upgrade = TemplateArray[i].DataName;
		Settings.Weight = int(UpgradeDropdownValues[i]);
		ResistanceUpgrades.AddItem(Settings);
	}
	
    ConfigVersion = `MCM_CH_GetCompositeVersion();
	SaveConfig();

	// Allow proper garbage collection of UI elements
	ChanceDropdown = none;
	UpgradeDropdowns.Length = 0;
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	local int i;

	ChanceDropdown.SetValue(string(class'RWU_Defaults'.default.UpgradeChance), true);

	for (i = 0; i < UpgradeDropdowns.Length; i++)
		UpgradeDropdowns[i].SetValue(string(class'RWU_Utilities'.static.GetDefaultUpgradeWeight(TemplateArray[i].DataName, TemplateArray[i].Tier)), true);
}

simulated function RevertButtonClicked(MCM_API_SettingsPage Page)
{
	// Allow proper garbage collection of UI elements
	ChanceDropdown = none;
	UpgradeDropdowns.Length = 0;
}

static function LoadUserConfig(array<X2WeaponUpgradeTemplate> TempArray)
{
	local XComGameState_Item DummyWeapon;
	local UpgradeSettings Settings;
	local int UserConfigVersion, DefaultConfigVersion, i, j;
	local bool Valid;

	UserConfigVersion = default.ConfigVersion;
	DefaultConfigVersion = class'RWU_Defaults'.default.ConfigVersion;

	if (UserConfigVersion < DefaultConfigVersion && !UpdateUserConfigValues(UserConfigVersion))
	{
		return;
	}

	if (TempArray.Length == 0)
	{
		TempArray = class'X2ItemTemplateManager'.static.GetItemTemplateManager().GetAllUpgradeTemplates();

		// Set up the dummy weapon
		DummyWeapon = new class'XComGameState_Item';
		DummyWeapon.InventorySlot = eInvSlot_PrimaryWeapon;

		// Remove templates that aren't for primary weapons
		for (i = 0; i < TempArray.Length; i++)
		{
			if (!TempArray[i].CanApplyUpgradeToWeaponFn(new class'X2WeaponUpgradeTemplate', DummyWeapon, 0))
			{
				TempArray.Remove(i, 1);
				i--;
			}
		}
	}

	// Update ResistanceUpgrades to reflect the addition and removal of valid upgrades
	for (i = 0; i < TempArray.Length; i++)
	{
		if (!class'RWU_Utilities'.static.IsListed(TempArray[i].DataName))
		{
			`LOG("Adding new weapon upgrade template" @ TempArray[i].DataName @ "to ResistanceUpgrades", true, 'ResistanceWeaponUpgrades');
			Settings.Upgrade = TempArray[i].DataName;
			Settings.Weight = class'RWU_Utilities'.static.GetDefaultUpgradeWeight(TempArray[i].DataName, TempArray[i].Tier);
			default.ResistanceUpgrades.AddItem(Settings);
		}
	}

	for (i = 0; i < default.ResistanceUpgrades.Length; i++)
	{
		Valid = false;

		for (j = 0; j < TempArray.Length; j++)
		{
			if (TempArray[j].DataName == default.ResistanceUpgrades[i].Upgrade)
				Valid = true;
		}

		if (!Valid)
		{
			`LOG("Removing weapon upgrade template" @ default.ResistanceUpgrades[i].Upgrade @ "from ResistanceUpgrades", true, 'ResistanceWeaponUpgrades');
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
	ScreenClass = class'MCM_OptionsScreen'
}