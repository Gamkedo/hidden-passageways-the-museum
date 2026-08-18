@abstract
class_name SaveableResource
extends Resource

# Abstract class to handle saving a Resource as a ConfigFile
# ! NOTE ! 
# Saving Resources directly can lead to script injection because Resources
# directly reference (and execute) a script file. Hence why this uses ConfigFile
# as a serialization tool, which then the implementing class must define logic
# for serialization (both directions) to apply it to the game at run time.

@abstract
func handle_loaded_file(file: ConfigFile) -> void

@abstract
func serialize() -> ConfigFile


func load_from_file(directory_path: String, file_name: String) -> void:
	var full_path := directory_path + file_name
	var file_exists := FileAccess.file_exists(full_path)
	if file_exists:
		var loaded_file := ConfigFile.new()
		loaded_file.load(full_path)
		print("[%s] Load status = %s" % [resource_name, loaded_file != null])
		if loaded_file != null:
			handle_loaded_file(loaded_file)

func save_to_file(directory_path: String, file_name: String) -> void:
	ensure_save_directory_exists(directory_path)
	
	var serialized_data := serialize()
	
	var full_path := directory_path + file_name
	# Wipes the current file contents, then we'll write it all in
	var save_status := serialized_data.save(full_path)
	
	print("[%s] Save status = %s" % [resource_name, save_status])
	if save_status != Error.OK:
		printerr("[%s] Failed to save input binds to file!" % [resource_name])

func ensure_save_directory_exists(directory_path: String) -> void:
	var save_dir_exists := DirAccess.dir_exists_absolute(directory_path)
	if not save_dir_exists:
		DirAccess.make_dir_recursive_absolute(directory_path)
