// Loads the config file that contains any changes the user has made
// Credit goes to bountygiver for the original idea and Lucubration for the code (aside from mod-specific tweaks)

class ResistanceWeaponUpgrades_StoredConfig extends Object config(ResistanceWeaponUpgrades);

/*var config int ConfigVersion;

var config float BasicUpgradePercentChance;
var config float AdvancedUpgradePercentChance;
var config float SuperiorUpgradePercentChance;

var config float BasicLaserSightWeight;
var config float BasicScopeWeight;
var config float BasicExpandedMagazineWeight;
var config float BasicHairTriggerWeight;
var config float BasicAutoLoaderWeight;
var config float BasicStockWeight;
var config float BasicRepeaterWeight;

var config float AdvancedLaserSightWeight;
var config float AdvancedScopeWeight;
var config float AdvancedExpandedMagazineWeight;
var config float AdvancedHairTriggerWeight;
var config float AdvancedAutoLoaderWeight;
var config float AdvancedStockWeight;
var config float AdvancedRepeaterWeight;

var config float SuperiorLaserSightWeight;
var config float SuperiorScopeWeight;
var config float SuperiorExpandedMagazineWeight;
var config float SuperiorHairTriggerWeight;
var config float SuperiorAutoLoaderWeight;
var config float SuperiorStockWeight;
var config float SuperiorRepeaterWeight;

static function LoadUserConfig()
{
	local int UserConfigVersion, DefaultConfigVersion;

	UserConfigVersion = default.ConfigVersion;
	DefaultConfigVersion = class'X2StrategyElement_DefaultRewards_RWU'.default.ConfigVersion;

	// Perform any config versioning to make sure all values are stored in the user's config, even new default ones
	if (UserConfigVersion < DefaultConfigVersion)
	{
		while (UserConfigVersion < DefaultConfigVersion)
		{
			if (!UpdateUserConfigValues(UserConfigVersion))
			{
				// If the config versioning fails, return without saving over the user's config and without replacing default values
				return;
			}
		}

		// Once we've successfully performed any updates, save the user's config. The user's config should now be up-to-date with the latest version
		StaticSaveConfig();
	}

	// Replace the default values that will be used for adding weapon upgrades
	LoadUserConfigValues();
}

static function LoadUserConfigValues()
{
	// This will replace the default config values in memory with any from the user's config. The new values will be used for adding weapon upgrades.
	// This should always be kept up-to-date with the latest version
	class'X2StrategyElement_DefaultRewards_RWU'.default.BasicUpgradePercentChance = default.BasicUpgradePercentChance;
	class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedUpgradePercentChance = default.AdvancedUpgradePercentChance;
	class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorUpgradePercentChance = default.SuperiorUpgradePercentChance;

	class'X2StrategyElement_DefaultRewards_RWU'.default.BasicLaserSightWeight = default.BasicLaserSightWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.BasicScopeWeight = default.BasicScopeWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.BasicExpandedMagazineWeight = default.BasicExpandedMagazineWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.BasicHairTriggerWeight = default.BasicHairTriggerWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.BasicAutoLoaderWeight = default.BasicAutoLoaderWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.BasicStockWeight = default.BasicStockWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.BasicRepeaterWeight = default.BasicRepeaterWeight;

	class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedLaserSightWeight = default.AdvancedLaserSightWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedScopeWeight = default.AdvancedScopeWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedExpandedMagazineWeight = default.AdvancedExpandedMagazineWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedHairTriggerWeight = default.AdvancedHairTriggerWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedAutoLoaderWeight = default.AdvancedAutoLoaderWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedStockWeight = default.AdvancedStockWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedRepeaterWeight = default.AdvancedRepeaterWeight;

	class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorLaserSightWeight = default.SuperiorLaserSightWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorScopeWeight = default.SuperiorScopeWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorExpandedMagazineWeight = default.SuperiorExpandedMagazineWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorHairTriggerWeight = default.SuperiorHairTriggerWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorAutoLoaderWeight = default.SuperiorAutoLoaderWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorStockWeight = default.SuperiorStockWeight;
	class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorRepeaterWeight = default.SuperiorRepeaterWeight;

	//class'X2StrategyElement_DefaultRewards_RWU'.default.Test = default.Test;
}

static function bool UpdateUserConfigValues(out int UserConfigVersion)
{
	// Config versioning system. Each new config version should incrementally update the user config with only the new default values found in that version
	switch (UserConfigVersion)
	{
		case 0:
			default.ConfigVersion = 1;

			default.BasicUpgradePercentChance = class'X2StrategyElement_DefaultRewards_RWU'.default.BasicUpgradePercentChance;
			default.AdvancedUpgradePercentChance = class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedUpgradePercentChance;
			default.SuperiorUpgradePercentChance = class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorUpgradePercentChance;
			
			default.BasicLaserSightWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.BasicLaserSightWeight;
			default.BasicScopeWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.BasicScopeWeight;
			default.BasicExpandedMagazineWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.BasicExpandedMagazineWeight;
			default.BasicHairTriggerWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.BasicHairTriggerWeight;
			default.BasicAutoLoaderWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.BasicAutoLoaderWeight;
			default.BasicStockWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.BasicStockWeight;
			default.BasicRepeaterWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.BasicRepeaterWeight;
		
			default.AdvancedLaserSightWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedLaserSightWeight;
			default.AdvancedScopeWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedScopeWeight;
			default.AdvancedExpandedMagazineWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedExpandedMagazineWeight;
			default.AdvancedHairTriggerWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedHairTriggerWeight;
			default.AdvancedAutoLoaderWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedAutoLoaderWeight;
			default.AdvancedStockWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedStockWeight;
			default.AdvancedRepeaterWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.AdvancedRepeaterWeight;
			
			default.SuperiorLaserSightWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorLaserSightWeight;
			default.SuperiorScopeWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorScopeWeight;
			default.SuperiorExpandedMagazineWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorExpandedMagazineWeight;
			default.SuperiorHairTriggerWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorHairTriggerWeight;
			default.SuperiorAutoLoaderWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorAutoLoaderWeight;
			default.SuperiorStockWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorStockWeight;
			default.SuperiorRepeaterWeight = class'X2StrategyElement_DefaultRewards_RWU'.default.SuperiorRepeaterWeight;

			//default.Test = class'X2StrategyElement_DefaultRewards_RWU'.default.Test;
			break;

		default:
			`REDSCREEN("Unknown user config version" @ string(UserConfigVersion) @ "cannot be updated", true, 'ResistanceWeaponUpgrades');
			`LOG("Unknown user config version " @ string(UserConfigVersion) @ "cannot be updated", true, 'ResistanceWeaponUpgrades');
			return false;
	}

	`LOG("Updated user config version" @ string(UserConfigVersion) @ "to version" @ string(default.ConfigVersion), true, 'ResistanceWeaponUpgrades');

	UserConfigVersion = default.ConfigVersion;

	return true;
}*/