local function FavoritesGetSprite()
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	local self = {}
	self.version = "1.0"
	self.name = "FavoritesGetSprite"
	self.author = "snuxy-pk"
	self.description = "Extension that downloads the sprites from pokemondb of your favorites."
	self.github = "snuxy-pk/FavoritesGetSprite"
	self.url = string.format("https://github.com/snuxy-pk/FavoritesGetSprite.git", self.github or "")

	local SAVED_DATA_PATH = FileManager.getCustomFolderPath() .. "favorites"
	local SAVED_CONFIG_PATH = SAVED_DATA_PATH .. FileManager.slash .. "config.ini"
	local SAVED_SPRITE_PATH = SAVED_DATA_PATH .. FileManager.slash .. "sprites" .. FileManager.slash                                           -- default download folder for sprites
	local FAVORITES = Main.MetaSettings.tracker.Startup_favorites
	local CHECKED_FAVORITES = false

	function self.configureOptions()
		--[[ WIP
		show current save directory of sprites
		add option to run checkFavorites on current favorites in case something didnt work
		add ooption to choose download path of sprites, default will be in extention folder
		]]
	end

	function self.checkForUpdates()
		-- Update the pattern below to match your version. You can check what this looks like by visiting the latest release url on your repo
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github or "")
		local downloadUrl = string.format("%s/releases/latest", self.url or "")
		local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end -- if current version is *older* than online version
		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern,
			compareFunc)
		return isUpdateAvailable, downloadUrl
	end

	function self.downloadAndInstallUpdate()
		local extensionFilenameKey = "FavoritesGetSprite" -- REPLACE WITH FILENAME OF EXTENSION
		local success = TrackerAPI.updateExtension(extensionFilenameKey)
		return success
	end

	-- Executed only once: When the extension is enabled by the user, and/or when the Tracker first starts up, after it loads all other required files and code
	function self.startup()
		if (FAVORITES ~= nil or " " or "") and (CHECKED_FAVORITES == false) then
			if self.readConfig() then
				local checked = self.checkFavorites()
				if checked then
					CHECKED_FAVORITES = true
				end
			else
				print("Could not parse config.ini, does it exist?")
			end
		else
			print("No Favorites set")
		end
	end

	function self.checkFavorites()
		local spriteDownloadUrl = nil
		local baseUrl = "https://img.pokemondb.net/sprites/" -- base url for sprites CDN from pokemondb
		local spriteType = "normal" -- can be changed in options if want shiny or backs -WIP-
		print("Checking favorites: "..FAVORITES)
		for str in string.gmatch(FAVORITES, "[^,]+") do
			local gameGen = self.getGen(str)
			local pokemonName = self.getPokemonName(tonumber(str))
			spriteDownloadUrl = string.format("%s%s/%s/%s.png", baseUrl, gameGen, spriteType, pokemonName)
			if not FileManager.fileExists(string.format("%s%s.png", SAVED_SPRITE_PATH .. FileManager.slash, pokemonName)) then -- check if the srites already exist
				if self.downloadSprite(spriteDownloadUrl, string.format("%s%s.png", SAVED_SPRITE_PATH, pokemonName)) then
					print(string.format("Sprite for Favorite: %s download success, from: %s ", pokemonName, spriteDownloadUrl))
				else
					print(string.format("Sprite for Favorite: %s could NOT download from: %s", pokemonName, spriteDownloadUrl))
				end
			else
				print(string.format("Sprite %s exists already", pokemonName))
			end
		end
		return true
	end

	function self.readConfig()
		local config = nil
		local file = io.open(SAVED_CONFIG_PATH)
		if file ~= nil then
			config = Inifile.parse(file:read("*a"), "memory")
			io.close(file)
		end
		if config.settings.Sprite_download_path then
			if config.settings.Sprite_download_path ~= "default" then
				SAVED_SPRITE_PATH = config.settings.Sprite_download_path
			end
		end
		return true
	end

	-- run curl to download the sprite resource
	function self.downloadSprite(downloadUrl, downloadLocation)
		local downloadSpriteCommand = string.format('curl -s %s -o %s', downloadUrl, downloadLocation)
		Utils.tempDisableBizhawkSound()
		local success, output = FileManager.tryOsExecute(downloadSpriteCommand)
		Utils.tempEnableBizhawkSound()
		if not success then
			return false
		else
			return true
		end
	end

	function self.getPokemonName(id)
		if Resources.Game.PokemonNames[id] then
			return string.lower(Resources.Game.PokemonNames[id])
		end
	end

	function self.getGen(id)
		if GameSettings.game == 3 then
			--for pokemondb, if pokemon is above the base gen1 id, then it will only be in ruby saphire or emerald sprites
			if tonumber(id) <= 151 then
				return "firered-leafgreen"
			elseif tonumber(id) > 151 then
				return "ruby-sapphire"
			end
		elseif GameSettings.game == 2 then
			if tonumber(id) > 151 then
				return "emerald"
			end
		elseif GameSettings.game == 1 then
			return "ruby-sapphire"
		end
	end

	-- Executed only once: When the extension is disabled by the user, necessary to undo any customizations, if able
	function self.unload()
		CHECKED_FAVORITES =false
		-- [ADD CODE HERE]
	end

	-- Executed once every 30 frames, after most data from game memory is read in
	function self.afterProgramDataUpdate() -- better way to do this? like check every time a metasetting is changed instead of game data?
		-- re-check if favorites have changed, 
		-- probably dont need since you can only change favorites at title screen of the rom
		--[[ local favoriteCheck = Main.MetaSettings.tracker.Startup_favorites
		if favoriteCheck ~= FAVORITES then
			print("Favorites change detected, checking ..")
			FAVORITES = favoriteCheck
			CHECKED_FAVORITES = false
			local checked = self.checkFavorites()
			if checked then
				CHECKED_FAVORITES = true
			end
		end ]]
	end
	return self
end
return FavoritesGetSprite
