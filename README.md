# FavoritesGetSprite

Extension that downloads the sprites from pokemondb of your favorites.

### Requirements:
Ironmon-Tracker v.9.0.0 or higher

### Notes:
* You must have an internet connection for this to work!
* Currently only works for gen 3 roms: ruby-sapphire-emerald-firered-leafgreen
* This can be usefull for automating stream setup displays of your favorites.
* Extension was made by wanted feature for [IdleCrisp](https://twitch.tv/IdleCrisp), along with my curiosity to learn lua.

### Work in progress:
* add option to download any sprite in options
* add option to choose download location, by default it downloads to extension_folder/favorites/sprites/
* add option to choose type of sprite: shiny, backs, etc.
* add error handleing for when not connected to the internet and this extension tries to download a sprite. Currently when attempting to curl the resource and if no resource, it still downloads the response output as the .png image when its not the correct resource. (harmless and doesnt break anything, just will provide a false positive giving a success on downloading the image)
* add more generations

### Proof of concept:

On load of extention and tracker:
![favorites_sprites_downloaded](https://github.com/user-attachments/assets/7e4abec9-618d-4e96-af31-c8e581522214)

If sprite download in download directory exists already, it will skip it.
![favorites_sprites__existed](https://github.com/user-attachments/assets/62f644f3-7868-4f6a-86dd-2b65de59fcae)

