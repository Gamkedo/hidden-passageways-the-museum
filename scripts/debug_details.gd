class_name DebugUI extends RichTextLabel

## Submit text to be displayed on the screen. BBCode is allowed.
## Just call [method entry], supply a unique string name for your data, and the text to display.
## Update your text exactly the same. To clear your entry, call [method remove].

static var entries: Dictionary[StringName, String]
static var _dirty: bool = false

var rtl: RichTextLabel = self ## could manage more nodes later

func _process(_delta: float) -> void:
	if _dirty:
		refresh()

func refresh() -> void:
	if not rtl: return
	rtl.clear()
	var t: String = ""
	for e in entries:
		t += "\n" + entries[e]
	t.trim_prefix("\n")
	rtl.text = t


static func entry(entry_uid: StringName, entry_data: String) -> void:
	entries[entry_uid] = entry_data
	_dirty = true
	
static func remove(entry_uid: StringName) -> void:
	if entry_uid in entries.keys():
		entries.erase(entry_uid)
	else:
		push_warning("Entry %s not found in DebugUI entries: %s" % [entry_uid, entries.keys()])
	_dirty = true

static func sort(how: Callable) -> Array:
	var values: Array[String] = entries.values()
	values.sort_custom(how)
	return values
